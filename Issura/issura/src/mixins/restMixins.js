import axios from 'axios'

// -------- DELETES ---------------

const simpleDelete = function (url) {
    return axios.delete(url).then(response => {
        return response.status
    }).catch(reason => {
        console.log("Delete Failed: " + reason);
        throw new Error(reason)
    })
};

export const deleteComment = {
    methods: {
        deleteComment(projectId, issueId, commentId) {
            return simpleDelete('projects/' + projectId + '/issues/' + issueId + '/comments/' + commentId)
        }
    }
};

export const deleteLinkedIssue = {
    methods: {
        deleteLinkedIssue(projectId, issueId, linkedIssueId) {
            return simpleDelete('projects/' + projectId + '/issues/' + issueId + '/linkedIssues/' + linkedIssueId)
        }
    }
};

export const deleteIssueStatus = {
    methods: {
        deleteIssueStatus(issueStatusId) {
            return simpleDelete('issueStatuses/' + issueStatusId)
        }
    }
};

export const deleteProjectMember = {
    methods: {
        deleteProjectMember(projectMemberId) {
            return simpleDelete('projectMembers/' + projectMemberId)
        }
    }
};

// -------- PUTS -------------------

const simplePut = function (url, data) {
    return axios.put(url, data).then(() => {
        return true
    }).catch(reason => {
        console.log("Update failed: " + reason);
        throw new Error(reason)
    })
};

export const updateProject = {
    methods: {
        updateProject(id, name, description, status, ownerId) {
            return simplePut("projects/" + id, {
                name: name,
                description: description,
                status: status,
                ownerId: ownerId
            });
        }
    }
};

export const updateIssue = {
    methods: {
        updateIssue(title, description, statusId, assigneeId, projectId, type, issueId) {
            return simplePut("projects/" + projectId + "/issues/" + issueId, {
                title: title,
                description: description,
                statusId: statusId,
                assigneeId: assigneeId,
                type: type,
                projectId: projectId
            });
        }
    }
};

export const updateComment = {
    methods: {
        updateComment(projectId, issueId, commentId, text) {
            return simplePut('projects/' + projectId + '/issues/' + issueId + '/comments/' + commentId, {
                text: text
            })
        }
    }
};

export const updateUser = {
    methods: {
        updateUser(nickname, userId) {
            return simplePut("users/" + userId, {nickname: nickname})
        }
    }
};

export const updateIssueStatus = {
    methods: {
        updateIssueStatus(projectId, issueStatusId, color, name) {
            return simplePut("issueStatuses/" + issueStatusId, {
                projectId: projectId,
                color: color,
                name: name
            })
        }
    }
};

// -------- FETCH SINGLE ------------

const simpleGetS = function (url) {
    return axios.get(url).then(response => {
        return response.data
    }).catch(reason => {
        if (reason.response.status === 404) {
            console.log("Resource did not exist: " + reason);
        } else {
            console.error("Fetch Failed: " + reason);
        }
        throw new Error(reason)
    })
};

export const fetchUser = {
    methods: {
        fetchUser(userId) {
            return simpleGetS('users/' + userId);
        }
    }
};

export const fetchIssue = {
    methods: {
        fetchIssue(projectId, issueId) {
            return simpleGetS('projects/' + projectId + '/issues/' + issueId);
        }
    }
};

export const fetchProject = {
    methods: {
        fetchProject(id) {
            return simpleGetS('projects/' + id)
        }
    }
};

export const fetchIssueStatus = {
    methods: {
        fetchIssueStatus(id) {
            return simpleGetS('issueStatuses/' + id)
        }
    }
};

// -------- FETCH COLLECTION --------

const simpleGetC = function (url) {
    return axios.get(url).then(response => {
        return response.data
    }).catch(reason => {
        console.error("Fetch Failed: " + reason);
        throw new Error(reason)
    })
};

export const fetchUsers = {
    methods: {
        fetchUsers() {
            return simpleGetC('users')
        }
    }
};

export const fetchIssues = {
    methods: {
        fetchIssues(projectId) {
            return simpleGetC('projects/' + projectId + '/issues')
        }
    }
};

export const fetchUserIssues = {
    methods: {
        fetchUserIssues(id) {
            return simpleGetC('users/' + id + '/issues')
        }
    }
};

export const fetchUserProjects = {
    methods: {
        fetchUserProjects(userId) {
            return simpleGetC('users/' + userId + '/projects')
        }
    }
};

export const fetchProjects = {
    methods: {
        fetchProjects() {
            return simpleGetC('projects')
        }
    }
};

export const fetchComments = {
    methods: {
        fetchComments(projectId, issueId) {
            return simpleGetC('projects/' + projectId + '/issues/' + issueId + '/comments')
        }
    }
};

export const fetchLinkedIssues = {
    methods: {
        fetchLinkedIssues(projectId, issueId) {
            return simpleGetC('projects/' + projectId + '/issues/' + issueId + '/linkedIssues')
        }
    }
};

// -------- CREATE ------------------

const simpleCreate = function (url, data) {
    return axios.post(url, data).then(response => {
        return axios.get(response.data.uri)
    }).then(response => {
        return response.data;
    }).catch(reason => {
        console.log("Create failed: " + reason);
        throw new Error(reason)
    })
};

export const createIssue = {
    methods: {
        createIssue(title, description, statusId, creatorId, assigneeId, projectId, type) {
            return simpleCreate("projects/" + projectId + "/issues", {
                title: title,
                description: description,
                statusId: statusId,
                creatorId: creatorId,
                assigneeId: assigneeId,
                type: type,
                projectId: projectId
            })
        }
    }
};

export const createComment = {
    methods: {
        createComment(projectId, issueId, text, creatorId) {
            return simpleCreate('projects/' + projectId + '/issues/' + issueId + '/comments', {
                issueId: issueId,
                text: text,
                creatorId: creatorId,
            })
        }
    }
};

export const createLinkedIssue = {
    methods: {
        createLinkedIssue(projectId, issueId, otherIssue, firstDependant) {
            return simpleCreate("projects/" + projectId + "/issues/" + issueId + "/linkedIssues", {
                parentIssueId: firstDependant ? otherIssue : issueId,
                childIssueId: firstDependant ? issueId : otherIssue
            })
        }
    }
};

export const createIssueStatus = {
    methods: {
        createIssueStatus(projectId, typeCode, color, name) {
            return simpleCreate("issueStatuses", {
                projectId: projectId,
                typeCode: typeCode,
                color: color,
                name: name
            })
        }
    }
};

export const createProjectMember = {
    methods: {
        createProjectMember(projectId, userId) {
            return simpleCreate("projectMembers", {
                projectId: projectId,
                userId: userId
            })
        }
    }
};

// -------- OTHER -------------------

export const fetchUsersForProject = {
    methods: {
        fetchUsersForProject(projectId) {
            let params = {
                project: projectId
            };
            return axios.get('projectMembers', {params: params}).then(response => {
                let data = response.data;
                let revMap = new Map();
                data.forEach(pm => revMap.set(pm.userId, pm.id));
                let requests = data.map(pm => {
                    return axios.get('users/' + pm.userId);
                });
                return Promise.all(requests).then(responses => {
                    return responses.map(r => {
                        let res = r.data;
                        res["projectMemberId"] = revMap.get(res.id);
                        return res;
                    })
                })
            }).catch(reason => {
                console.error("Error retrieving users: " + reason);
                throw new Error(reason)
            })
        }
    }
};

export const createProject = {
    methods: {
        createProject(name, description, status, ownerId) {
            let data = {
                name: name,
                description: description,
                status: status,
                ownerId: ownerId
            };
            let result = null;
            return axios.post("projects", data).then(response => {
                return axios.get(response.data.uri)
            }).then(response => {
                result = response.data;
                return axios.post("projectMembers", {projectId: response.data.id, userId: ownerId})
            }).then(response => {
                return {projectMember: response.data.uri, project: result}
            }).catch(reason => {
                console.log("Create failed: " + reason);
                throw new Error(reason)
            })
        }
    }
};

export const fetchIssueStatuses = {
    methods: {
        fetchIssueStatuses(projectId, type) {
            let params = {};
            if (projectId != null && projectId >= 0) {
                params.project = projectId
            }
            if (type && type.trim().length !== 0) {
                params.type = type
            }
            return axios.get('issueStatuses', {params: params}).then(response => {
                return response.data
            }).catch(reason => {
                console.error("Error retrieving Issue Statuses: " + reason);
                throw new Error(reason)
            })
        }
    }
};

export const fetchLinkedIssuesFlattened = {
    methods: {
        fetchLinkedIssuesFlattened(projectId, issueId) {
            return axios.get('projects/' + projectId + '/issues/' + issueId + '/linkedIssues').then(response => {
                let linkedIssues = response.data;
                if (linkedIssues.length === 0) return [];
                let resMap = new Map();
                let res = [];
                for (const li of linkedIssues) {
                    if (li.parentIssueId === issueId) {
                        resMap.set(li.childIssueId, {isDependant: true, id: li.id});
                        res.push(axios.get('projects/' + projectId + '/issues/' + li.childIssueId))
                    } else {
                        resMap.set(li.parentIssueId, {isDependant: false, id: li.id});
                        res.push(axios.get('projects/' + projectId + '/issues/' + li.parentIssueId))
                    }
                }

                return Promise.all(res).then(responses => {
                    return responses.map(r => {
                        let data = r.data;
                        data["isDependant"] = resMap.get(data.id)["isDependant"];
                        data["linkedIssueId"] = resMap.get(data.id)["id"];
                        return data;
                    });
                }).catch(reason => {
                    console.error("Error fetching issue during linked issue flatten: " + reason);
                    throw new Error(reason)
                });
            }).catch(reason => {
                console.error("Error retrieving linked issues: " + reason);
                throw new Error(reason)
            })
        }
    }
};
