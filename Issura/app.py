#!/usr/bin/env python3
from functools import wraps

import pymysql.cursors
from flask import Flask, jsonify, abort, request, make_response, session
from flask_restful import reqparse, Resource, Api
from flask_session import Session
from ldap3 import Server, Connection
import ldap3.core.exceptions

import settings

app = Flask(__name__, static_url_path='/static', static_folder='issura/dist')
app.secret_key = settings.SECRET_KEY
app.config['SESSION_TYPE'] = 'filesystem'
app.config['SESSION_COOKIE_NAME'] = 'issura_session'
app.config['SESSION_COOKIE_DOMAIN'] = settings.APP_HOST
Session(app)
api = Api(app)


####################################################################################
#
# Error handlers
#
@app.errorhandler(400)  # decorators to add to 400 response
def bad_request(error):
    return make_response(jsonify({'status': 'Bad request'}), 400)


@app.errorhandler(404)  # decorators to add to 404 response
def not_found(error):
    return make_response(jsonify({'status': 'Resource not found'}), 404)

@app.after_request
def add_header(r):
    r.headers["Cache-Control"] = "no-cache, no-store, must-revalidate, max-age=0"
    r.headers["Pragma"] = "no-cache"
    r.headers["Expires"] = "0"
    return r

####################################################################################
#
# Helper Methods
#
def connect_to_DB():
    """Creates a connection to the database and returns the connection object"""
    return pymysql.connect(
        settings.DB_HOST,
        settings.DB_USER,
        settings.DB_PASSWD,
        settings.DB_DATABASE,
        charset='utf8mb4',
        cursorclass=pymysql.cursors.DictCursor)


def Post(f):
    """Performs database calls to create a record using the procedure and parameters
    returned by the wrapped function"""
    @wraps(f)
    def wrapper(*args, **kwds):
        proc, pargs = f(*args, **kwds)
        rows = dbRequest(proc, pargs)
        row = rows[0]
        uri = str(request.url) + '/' + str(row['LAST_INSERT_ID()'])
        return make_response(jsonify({'uri': uri}), 201)  # successful resource creation
    return wrapper


def Get(f):
    """Performs database calls to read one or many records using the procedure and parameters
    returned by the wrapped function"""
    @wraps(f)
    def wrapper(*args, **kwds):
        proc, pargs = f(*args, **kwds)
        rows = dbRequest(proc, pargs)
        return make_response(jsonify(rows), 200)
    return wrapper

def GetSingular(f):
    """Performs database calls to read one records using the procedure and parameters
    returned by the wrapped function"""
    @wraps(f)
    def wrapper(*args, **kwds):
        proc, pargs = f(*args, **kwds)
        rows = dbRequest(proc, pargs)
        rows = rows[0] if rows is not None and len(rows) > 0 else None
        if rows is not None:
            return make_response(jsonify(rows), 200)
        else:
            return make_response("Resource not found", 404)
    return wrapper


def Delete(f):
    """Performs database calls to delete a record using the procedure and parameters
    returned by the wrapped function"""
    @wraps(f)
    def wrapper(*args, **kwds):
        proc, pargs = f(*args, **kwds)
        dbRequest(proc, pargs)
        return make_response('', 204)
    return wrapper


def Put(f):
    """Performs database calls to update a record using the procedure and parameters
    returned by the wrapped function"""
    @wraps(f)
    def wrapper(*args, **kwds):
        proc, pargs = f(*args, **kwds)
        dbRequest(proc, pargs)
        return make_response('', 204)
    return wrapper


def dbRequest(proc, pargs):
    """Performs database calls using the procedure and parameters given. Will
    commit all changes and ensure connection closure"""
    cursor = None
    dbConnection = None
    rows = None
    try:
        dbConnection = connect_to_DB()
        cursor = dbConnection.cursor()
        if pargs is None:
            cursor.callproc(proc)
        else:
            cursor.callproc(proc, pargs)
        rows = cursor.fetchall()
        dbConnection.commit()
    except pymysql.err.IntegrityError as e:
        app.logger.info(e)
        if request.method == "POST" or request.method == "PUT":
            abort(409, 'The resource references foreign resources that do not exist.')
        elif request.method == "DELETE":
            abort(409, 'The resource has dependants and cannot be deleted.')
        else:
            abort(409, 'Unknown conflict. Please retry the request and verify the resources referenced exist.')
    except:
        abort(500)
    finally:
        if cursor:
            cursor.close()
        if dbConnection:
            dbConnection.close()
    return rows


def request_contains(lst):
    """Checks if the request contains the required keys"""
    if not request.json:
        abort(make_response(jsonify("The request did not contain a JSON body"), 400))
    body = request.json
    for item in lst:
        if item not in body:
            abort(make_response(jsonify("The request did not contain the key " + item), 400))  # bad request
            break


def request_dict(lst, initial=None) -> dict:
    """Extracts the values with the given keys from a request. Values will be
    inserted into a blank dictionary or initial if provided"""
    if initial is None:
        initial = {}
    request_contains(lst)
    data = initial
    body = request.json
    for item in lst:
        if type(body[item]) == str and len(body[item]) == 0:
            data[item] = None
        else:
            data[item] = body[item]
    return data


def is_project_member(f):
    """Checks if the logged in user is a member of the project specified in the URL"""
    @wraps(f)
    def wrapper(*args, **kwds):
        projId = request.view_args['projId']
        rows = dbRequest('getProjectMembersByProjectIdAndUserId', [projId, session['uid']])
        if len(rows) == 0:
            rows = dbRequest('getProjectById', [projId])
            if rows[0]['ownerId'] != session['uid']:
                abort(403, 'You must be a member of this project to access this resouce')
        return f(*args, **kwds)
    return wrapper


def is_logged_in_user(f):
    """Checks if the logged in user is the user specified in the URL"""
    @wraps(f)
    def wrapper(*args, **kwds):
        userId = request.view_args['userId']
        if userId != session['uid']:
            abort(403)
        return f(*args, **kwds)
    return wrapper


def is_project_owner(f):
    """Checks if the logged in user is the owner of the project specified in the URL"""
    @wraps(f)
    def wrapper(*args, **kwds):
        projId = request.view_args['projId']
        rows = dbRequest('getProjectById', [projId])
        if len(rows) != 1:
            abort(404)
        elif rows[0]['ownerId'] is not session['uid']:
            abort(403)
        return f(*args, **kwds)
    return wrapper


def is_logged_in(f):
    """Checks if the user is logged in"""
    @wraps(f)
    def wrapper(*args, **kwds):
        if 'uid' not in session:
            abort(403)
        return f(*args, **kwds)
    return wrapper


####################################################################################
#
# Static Endpoints and Authentication
#
class Root(Resource):
    def get(self):
        return app.send_static_file('index.html')


class SignIn(Resource):

    def post(self):
        if not request.json:
            abort(400)  # bad request
        # Parse the json
        parser = reqparse.RequestParser()
        request_params = None
        response = {}
        try:
            # Check for required attributes in json document, create a dictionary
            parser.add_argument('username', type=str, required=True)
            parser.add_argument('password', type=str, required=True)
            request_params = parser.parse_args()
        except:
            abort(400)  # bad request

        # Already logged in

        ldapConnection = None
        try:
            ldapServer = Server(host=settings.LDAP_HOST)
            ldapConnection = Connection(ldapServer,
                                        raise_exceptions=True,
                                        user='uid=' + request_params['username'] + ', ou=People,ou=fcs,o=unb',
                                        password=request_params['password'])
            ldapConnection.open()
            ldapConnection.start_tls()
            ldapConnection.bind()
            # Check to see if the user is already in the database
            userdata = dbRequest('getUserByUsername', [request_params['username']])
            if len(userdata) > 0:
                # User is in the database
                response = {'status': 'Logged in with existing user',
                            'id': userdata[0]['id']}
                session['uid'] = userdata[0]['id']
                responseCode = 201
            else:
                # User is not in the database: add them
                userdata = dbRequest('createUser', [request_params['username'], request_params['username']])
                response = {'status': 'Logged in with new user',
                            'id': userdata[0]['LAST_INSERT_ID()']}
                session['uid'] = userdata[0]['LAST_INSERT_ID()']
                responseCode = 201
        except ldap3.core.exceptions.LDAPException as e:
            print(e)
            response = {'status': 'Access denied'}
            responseCode = 403
        finally:
            if ldapConnection is not None:
                ldapConnection.unbind()

        return make_response(jsonify(response), responseCode)

    def get(self):
        if 'uid' in session:
            return make_response(jsonify({'id': session['uid']}), 200)
        else:
            return make_response('User is not logged in', 403)

    def delete(self):
        if 'uid' in session:
            session.pop('uid')
        return make_response('', 204)


####################################################################################
#
# API Endpoints
#
class Users(Resource):
    method_decorators = [is_logged_in]

    @Get
    def get(self):
        search_query = request.args.get('search', None, type=str)
        if search_query is not None:
            if len(search_query.strip()) == 0:
                abort(400, 'Query parameter cannot be blank')
            else:
                return 'getUsersByNamesLike', [f'%{search_query}%']
        else:
            return 'getUsers', None

    @Post
    def post(self):
        data = request_dict(['username', 'nickname'])
        return 'createUser', list(data.values())


class User(Resource):
    method_decorators = [is_logged_in]

    @GetSingular
    def get(self, userId):
        return 'getUserById', [userId]

    @is_logged_in_user
    @Delete
    def delete(self, userId):
        return 'deleteUser', [userId]

    @is_logged_in_user
    @Put
    def put(self, userId):
        data = request_dict(['nickname'], {'id': userId})
        return 'updateUser', list(data.values())


class UserProjects(Resource):
    method_decorators = [is_logged_in]

    @Get
    def get(self, userId):
        return 'getProjectsByUserId', [userId]


class UserIssues(Resource):
    method_decorators = [is_logged_in]

    @Get
    def get(self, userId):
        return 'getIssuesByUserId', [userId]


class Projects(Resource):
    method_decorators = [is_logged_in]

    @Get
    def get(self):
        search_query = request.args.get('search', None, type=str)
        if search_query is not None:
            if len(search_query.strip()) == 0:
                abort(400, 'Query parameter cannot be blank')
            else:
                return 'searchProjects', [f'%{search_query}%']
        else:
            return 'getProjects', None

    @Post
    def post(self):
        data = request_dict(['name', 'description', 'status', 'ownerId'])
        return 'createProject', list(data.values())


class Project(Resource):
    method_decorators = [is_logged_in]

    @GetSingular
    def get(self, projId):
        return 'getProjectById', [projId]

    @is_project_owner
    @Delete
    def delete(self, projId):
        return 'deleteProject', [projId]

    @is_project_owner
    @Put
    def put(self, projId):
        data = request_dict(['name', 'description', 'status', 'ownerId'], {'projectId': projId})
        return 'updateProject', list(data.values())


class Issues(Resource):
    method_decorators = [is_logged_in, is_project_member]

    @Get
    def get(self, projId):
        if len(request.args) > 0:
            params = {
                'title': '%'+request.args.get('title', '', str)+'%',
                'description': '%'+request.args.get('description', '', str)+'%',
                'type': '%'+request.args.get('type', '', str)+'%',
                'statusId': request.args.get('statusId', None, int),
                'creatorId': request.args.get('creatorId', None, int),
                'assigneeId': request.args.get('assigneeId', None, int),
                'projectId': projId}
            return 'searchIssues', list(params.values())
        else:
            return 'getIssuesByProjectId', [projId]

    @Post
    def post(self, projId):
        data = request_dict(['title', 'description', 'type', 'statusId', 'creatorId', 'assigneeId'])
        data['projectId'] = projId
        return 'createIssue', list(data.values())


class Issue(Resource):
    method_decorators = [is_logged_in, is_project_member]

    @GetSingular
    def get(self, projId, issueId):
        return 'getIssueById', [issueId]

    @Delete
    def delete(self, projId, issueId):
        return 'deleteIssue', [issueId]

    @Put
    def put(self, projId, issueId):
        data = request_dict(['title', 'description', 'type', 'statusId', 'assigneeId'], {'issueId': issueId})
        return 'updateIssue', list(data.values())


class LinkedIssues(Resource):
    method_decorators = [is_logged_in, is_project_member]

    @Get
    def get(self, projId, issueId):
        return 'getLinkedIssuesByIssueId', [issueId]

    @Post
    def post(self, projId, issueId):
        data = request_dict(['parentIssueId', 'childIssueId'])
        return 'createLinkedIssue', list(data.values())


class LinkedIssue(Resource):
    method_decorators = [is_logged_in, is_project_member]

    @GetSingular
    def get(self, projId, issueId, linkedIssueId):
        return 'getLinkedIssueById', [linkedIssueId]

    @Delete
    def delete(self, projId, issueId, linkedIssueId):
        return 'deleteLinkedIssueById', [linkedIssueId]


class Comments(Resource):
    method_decorators = [is_logged_in, is_project_member]

    @Get
    def get(self, projId, issueId):
        return 'getCommentsByIssueId', [issueId]

    @Post
    def post(self, projId, issueId):
        data = request_dict(['creatorId', 'text'])
        data['issueId'] = issueId
        return 'createComment', list(data.values())


class Comment(Resource):
    method_decorators = [is_logged_in, is_project_member]

    @GetSingular
    def get(self, projId, issueId, commentId):
        return 'getCommentById', [commentId]

    @Delete
    def delete(self, projId, issueId, commentId):
        rows = dbRequest('getCommentById', [commentId])
        if len(rows) != 1:
            abort(404)
        elif rows[0]['creatorId'] is not session['uid']:
            abort(403)
        return 'deleteComment', [commentId]

    @Put
    def put(self, projId, issueId, commentId):
        rows = dbRequest('getCommentById', [commentId])
        if len(rows) != 1:
            abort(404)
        elif rows[0]['creatorId'] is not session['uid']:
            abort(403)
        data = request_dict(['text'], {'id': commentId})
        return 'updateComment', list(data.values())


class IssueStatuses(Resource):
    method_decorators = [is_logged_in]

    @Get
    def get(self):
        if len(request.args) > 0:
            type = request.args.get('type', None, str)
            params = {
                'project': request.args.get('project', None, int),
                'type': ('%'+type+'%') if type is not None else None
            }
            return 'getIssueStatusByProjectAndType', list(params.values())
        else:
            return 'getIssueStatuses', None

    @Post
    def post(self):
        data = request_dict(['name', 'color', 'projectId', 'typeCode'])
        return 'createIssueStatus', list(data.values())


class IssueStatus(Resource):
    method_decorators = [is_logged_in]

    @GetSingular
    def get(self, issueStatusId):
        return 'getIssueStatusById', [issueStatusId]

    @Delete
    def delete(self, issueStatusId):
        return 'deleteIssueStatusById', [issueStatusId]

    @Put
    def put(self, issueStatusId):
        data = request_dict(['name', 'color'], {'id': issueStatusId})
        return 'updateIssueStatus', list(data.values())


class ProjectMembers(Resource):
    method_decorators = [is_logged_in]

    @Get
    def get(self):
        if len(request.args) > 0:
            params = {
                'project': request.args.get('project', None, int)
            }
            return 'getProjectMembersByProjectId', list(params.values())
        else:
            return 'getProjectMembers', None

    @Post
    def post(self):
        data = request_dict(['projectId', 'userId'])
        rows = dbRequest('getProjectById', [data['projectId']])
        if len(rows) != 1:
            abort(404)
        elif rows[0]['ownerId'] is not session['uid']:
            abort(403)
        return 'createProjectMember', list(data.values())


class ProjectMember(Resource):
    method_decorators = [is_logged_in]

    @GetSingular
    def get(self, projectMemberId):
        return 'getProjectMemberById', [projectMemberId]

    @Delete
    def delete(self, projectMemberId):
        return 'deleteProjectMemberById', [projectMemberId]


####################################################################################
#
# Identify/create endpoints and endpoint objects
#
# Generic
api.add_resource(Root, '/')
api.add_resource(SignIn, '/signin')

# User
api.add_resource(Users, '/users')
api.add_resource(User, '/users/<int:userId>')

# User => Project
api.add_resource(UserProjects, '/users/<int:userId>/projects')

# User => Issue
api.add_resource(UserIssues, '/users/<int:userId>/issues')

# Project
api.add_resource(Projects, '/projects')
api.add_resource(Project, '/projects/<int:projId>')

# Project => Issue
api.add_resource(Issues, '/projects/<int:projId>/issues')
api.add_resource(Issue, '/projects/<int:projId>/issues/<int:issueId>')

# Project => Issue => Linked Issue
api.add_resource(LinkedIssues, '/projects/<int:projId>/issues/<int:issueId>/linkedIssues')
api.add_resource(LinkedIssue, '/projects/<int:projId>/issues/<int:issueId>/linkedIssues/<int:linkedIssueId>')

# Project => Issue => Comment
api.add_resource(Comments, '/projects/<int:projId>/issues/<int:issueId>/comments')
api.add_resource(Comment, '/projects/<int:projId>/issues/<int:issueId>/comments/<int:commentId>')

# Issue Status
api.add_resource(IssueStatuses, '/issueStatuses')
api.add_resource(IssueStatus, '/issueStatuses/<int:issueStatusId>')

# Project Member
api.add_resource(ProjectMembers, '/projectMembers')
api.add_resource(ProjectMember, '/projectMembers/<int:projectMemberId>')
#############################################################################
if __name__ == '__main__':
    context = ('cert.pem', 'key.pem')
    app.run(host=settings.APP_HOST,
            port=settings.APP_PORT,
            ssl_context=context,
            debug=settings.APP_DEBUG)
