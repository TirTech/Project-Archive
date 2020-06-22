<template>
    <Modal ref="modal" v-on:save="submitForm">
        <template v-slot:header>
            <h5 class="modal-title">Create Issue</h5>
        </template>
        <template v-slot:form>
            <div class="form-group">
                <label for="issueTitle">Title</label>
                <input type="text" class="form-control" id="issueTitle" v-model="title" required/>
            </div>
            <div class="form-group">
                <label for="issueDescription">Description</label>
                <textarea class="form-control" id="issueDescription" v-model="description" required/>
            </div>
            <div class="form-group" v-if="type != null">
                <label for="issueStatus">Status</label>
                <select class="form-control custom-select" id="issueStatus" v-model="statusId"
                        v-bind:disabled="statuses == null ||  statuses.length === 0" required>
                    <option v-for="status in statuses" v-bind:key="status.id"
                            v-bind:value="status.id">{{ status.name }}
                    </option>
                </select>
            </div>
            <div class="form-group">
                <label for="issueAssignee">Assignee</label>
                <select class="form-control custom-select" id="issueAssignee" v-model="assigneeId"
                        v-bind:disabled="users == null ||  users.length === 0">
                    <option value="" selected>Unassigned</option>
                    <option v-for="user in users" v-bind:key="user.id" v-bind:value="user.id">{{
                                                                                              user.nickname
                                                                                              }} ({{
                                                                                              user.username
                                                                                              }})
                    </option>
                </select>
            </div>
            <div class="form-group">
                <label for="issueType">Type</label>
                <select class="form-control custom-select" id="issueType" v-model="type" required>
                    <option value="BUG">Bug</option>
                    <option value="FEA">Feature</option>
                    <option value="TSK">Task</option>
                    <option value="OTR">Other</option>
                </select>
            </div>
            <div class="form-group" v-if="projectIdProp == null && issue == null">
                <label for="issueProjectId">Project</label>
                <select class="form-control custom-select" id="issueProjectId" v-model="projectId" required>
                    <option v-for="project in projects" v-bind:key="project.id"
                            v-bind:value="project.id">{{ project.name }}
                    </option>
                </select>
            </div>
        </template>
    </Modal>
</template>

<script>
    import {
        createIssue,
        fetchIssueStatuses,
        fetchUserProjects,
        fetchUsersForProject,
        updateIssue
    } from '../mixins/restMixins'
    import Modal from "./Modal";

    export default {
        name: "IssueForm",
        components: {Modal},
        mixins: [fetchUserProjects, createIssue, fetchUsersForProject, fetchIssueStatuses, updateIssue],
        props: {
            issue: {
                type: Object,
                required: false
            },
            projectIdProp: {
                type: Number,
                required: false
            }
        },
        data() {
            return {
                title: "",
                description: "",
                statusId: -1,
                assigneeId: -1,
                type: null,
                projectId: null,
                users: [],
                projects: [],
                statuses: []
            }
        },
        mounted() {
            this.loadData();
        },
        watch: {
            type: function () {
                this.fetchIssueStatuses(this.projectId, this.type).then(data => {
                    this.statuses = data
                });
                this.status = null
            },
            projectId: function () {
                if (this.projectId != null && this.projectId >= 0) {
                    this.fetchUsersForProject(this.projectId).then(data => {
                        this.users = data;
                    });
                }
                this.fetchIssueStatuses(this.projectId, this.type).then(data => {
                    this.statuses = data
                })
            }
        },
        methods: {
            loadData() {
                if (this.projectIdProp != null) {
                    this.projectId = this.projectIdProp
                }
                if (this.projectId != null && this.projectId >= 0) {
                    this.fetchUsersForProject(this.projectId).then(data => {
                        this.users = data;
                    });
                }
                this.fetchUserProjects(this.$store.getters.user.id).then(data => {
                    this.projects = data;
                });
                if (this.issue != null) {
                    this.title = this.issue.title;
                    this.description = this.issue.description;
                    this.assigneeId = this.issue.assigneeId;
                    this.type = this.issue.type;
                    this.projectId = this.issue.projectId;
                    this.statusId = this.issue.statusId;
                }
            },
            submitForm() {
                if (this.issue != null) {
                    this.updateIssue(this.title, this.description, this.statusId, this.assigneeId, this.projectId, this.type, this.issue.id).then(() => {
                        this.$emit('issue-updated');
                        this.$refs.modal.hide();
                    });
                } else {
                    this.createIssue(this.title, this.description, this.statusId, this.$store.getters.user.id, this.assigneeId, this.projectId, this.type).then(response => {
                        this.$emit('issue-created', response);
                        this.$refs.modal.hide();
                    });
                }
            },
            show() {
                this.loadData();
                this.$refs.modal.show();
            }
        }
    }
</script>

<style scoped>
</style>
