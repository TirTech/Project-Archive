# SQL Schema and Data Considerations
   This doc outlines the database format and what will be required when performing CRUD (create, read, update, delete) operations on the database. Also included are user interaction senarios that require querying the database or considering the state of the app's data.

## Data Tables

| Table Name     | Column Name     | Type        | Nullable | References   | Data Source | Mutable | Note                                           |
| -------------- | --------------- | ----------- | -------- | ------------ | ----------- | ------- | ---------------------------------------------- |
| user           | id              | int         | False    | PK           | Auto Gen.   | False   |                                                |
|                | username        | varchar 50  | False    |              | First Login | False   | Used to login. From LDAP                       |
|                | nickname        | varchar 50  | True     |              |             | True    | What is shown to other users                   |
| project_member | id              | int         | False    | PK           | Auto Gen.   | False   | project_member is replaced, not modified       |
|                | project_id      | int         | False    | project      |             | False   |                                                |
|                | user_id         | int         | False    | user         |             | False   |                                                |
| project        | id              | int         | False    | PK           | Auto Gen.   | False   |                                                |
|                | name            | varchar 50  | False    |              |             | True    |                                                |
|                | description     | varchar 500 | True     |              |             | True    |                                                |
|                | status          | varchar 3   | False    |              | Enum        | True    | Whether the project is still going.            |
|                | owner_id        | int         | False    | user         |             | True    | Who owns the project. Is this transferrable?   |
| issue_status   | id              | int         | False    | PK           | Auto Gen.   | False   |                                                |
|                | name            | varchar 25  | False    |              |             | True    |                                                |
|                | color           | varchar 6   | False    |              |             | True    | Hex encoded color                              |
|                | project_id      | int         | True     | project      |             | False   |                                                |
|                | type            | varchar 3   | True     |              | Enum        | False   |                                                |
| issue          | id              | int         | False    | PK           | Auto Gen.   | False   |                                                |
|                | title           | varchar 100 | False    |              |             | True    |                                                |
|                | description     | varchar 500 | True     |              |             | True    |                                                |
|                | date_created    | timestamp   | False    |              | On Create   | False   |                                                |
|                | type            | varchar 3   | False    |              | Enum        | True    |                                                |
|                | status_id       | int         | False    | issue_status |             | True    |                                                |
|                | creator_id      | int         | False    | user         |             | False   |                                                |
|                | assignee_id     | int         | True     | user         |             | True    |                                                |
|                | project_id      | int         | False    | project      |             | True    | Can be moved between projects. Note migrations |
| comment        | id              | int         | False    | PK           | Auto Gen.   | False   |                                                |
|                | creator_id      | int         | False    | user         |             | False   |                                                |
|                | issue_id        | int         | False    | issue        |             | False   |                                                |
|                | text            | varchar 500 | False    |              |             | True    |                                                |
|                | date_created    | timestamp   | False    |              | On Create   | False   |                                                |
| linked_issue   | id              | int         | False    | PK           | Auto Gen.   | False   | linked_issue is replaced, not modified         |
|                | parent_issue_id | int         | False    | issue        |             | False   | Issue needed to be done first                  |
|                | child_issue_id  | int         | False    | issue        |             | False   | Issue needed to be done second                 |
|                |                 |             |          |              |             |         |                                                |

## Data Protections

### Deleting Dependant Entries
This conserns deleting projects and issue statuses. Since there is a required 3-way relation between issue statuses, their containing project, and the status of the issue (which is also tied to a project), deleting issue statuses or projects can leave issues/issue statuses in a broken state.

Comments and linked issues are deleted automatically if the issue they are attached to (or either issue in the case of linked issues) is/are deleted.

#### Delete an Issue Status
When deleting an issue status, the database must be checked to confirm that no issue holds this state. If such issues exists, prevent deletion and notify the user that such issues exist.

#### Delete a project
When deleting a project, all issues must be migrated and statuses deleted (as statuses cannot change projects). When deleting. verify there are no issues associated with this project. If such issues exist, notify the user of them and prevent deletion. After no issues exist, cascade the deletion to the issue statuses that are attached to this project.
