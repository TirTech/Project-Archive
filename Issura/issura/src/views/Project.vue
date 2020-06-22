<template>
    <div class="m-3">
        <div class="row align-items-center justify-content-center h-100" v-if="loading">
            <div class="spinner-border text-primary">
                <span class="sr-only">Loading...</span>
            </div>
        </div>
        <template v-if="!loading && loadSuccess">
            <div class="row justify-content-between mb-4 ">
                <div class="col-auto">
                    <h2>{{ this.project.name }}</h2>
                </div>
                <div class="col col-auto ">
                    <template v-if="userIsOwner">
                        <button class="btn btn-sm btn-outline-primary mx-1" v-on:click="$refs.projectFormModal.show()" >Edit</button>
                        <button class="btn btn-sm btn-outline-primary mx-1" v-on:click="viewIssueStatuses">Issue Statuses</button>
                    </template>
                    <button class="btn btn-primary mx-1" v-on:click="$refs.issueFormModal.show()">Create Issue</button>
                </div>
            </div>
            <div class="row shadow-sm p-3 mb-3 rounded">
                <div class="col-auto">
                    <div class="row ">
                        <div class="col-auto">
                            <h6>Status:
                                <span class="badge badge-success" v-if="this.project.status === 'OPN'">Open</span>
                                <span class="badge badge-danger" v-if="this.project.status === 'CLS'">Closed</span>
                                <span class="badge badge-secondary" v-if="this.project.status === 'INA'">Inactive</span>
                            </h6>
                        </div>
                    </div>
                    <div class="row ">
                        <div class="col-auto">
                            Owner: {{ this.owner.nickname }} ({{ this.owner.username }})
                        </div>
                    </div>
                </div>
                <div class="col">
                    Description: {{ this.project.description }}
                </div>
            </div>
            <div class="row row-cols-1 shadow-sm p-3 mb-3 rounded" v-if="projectMembers != null && projectMembers.length > 0">
                <div class="col">
                    <div class="row justify-content-between">
                        <div class="col-auto">
                            <h3>Project Members:</h3>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-4" v-for="member in projectMembers" v-bind:key="member.id">
                            {{ member.nickname }} ({{ member.username }}) <i class="fas fa-trash-alt pl-2 text-danger clickable" v-on:click="projectMemberDelete(member)" v-if="member.id !== owner.id"/>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-auto">
                            <button class="btn btn-sm btn-outline-primary mx-1" v-on:click="$refs.projectMemberFormModal.show()">Add Members</button>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row row-cols-1 shadow-sm p-3 mb-3 rounded ">
                <div class="col">
                    <h3>Issues:</h3>
                    <IssueCard v-for="issue in issues" v-bind:issue="issue" v-bind:key="issue.id"/>
                </div>
            </div>
            <ProjectForm  id="projectFormModal" ref="projectFormModal" v-bind:project="project" v-on:project-updated="projectFormProjectUpdated"/>
            <IssueForm  id="issueFormModal" ref="issueFormModal" v-bind:project-id-prop="project.id" v-on:issue-created="issueFormIssueCreated"/>
            <ProjectMemberForm id="projectMemberFormModal" ref="projectMemberFormModal" v-bind:project-id="this.project.id" v-on:projectMember-created="projectMemberFormMemberCreated"/>
        </template>
        <ProblemAlert v-if="!loading && !loadSuccess" v-on:retry="loadData"></ProblemAlert>
    </div>
</template>

<script>
    import {deleteProjectMember, fetchIssues, fetchProject, fetchUser, fetchUsersForProject} from '../mixins/restMixins'
    import ProjectForm from "../components/ProjectForm";
    import ProblemAlert from "../components/ProblemAlert";
    import IssueCard from "../components/IssueCard";
    import IssueForm from "../components/IssueForm";
    import ProjectMemberForm from "../components/ProjectMemberForm";

    export default {
        name: "Project",
        components: {ProjectMemberForm, IssueForm, IssueCard, ProblemAlert, ProjectForm},
        mixins: [fetchProject, fetchUser, fetchIssues, fetchUsersForProject, deleteProjectMember],
        data() {
            return {
                project: null,
                loading: true,
                owner: null,
                issues: null,
                userIsOwner: false,
                loadSuccess: false,
                projectMembers: null
            }
        },
        mounted() {
            this.loadData()
        },
        methods: {
            loadData() {
                this.loading = true;
                this.fetchProject(this.$route.params.id).then(data => {
                    this.project = data;
                    return this.fetchUser(data.ownerId)
                }).then(data => {
                    this.owner = data;
                    if (this.owner.id === this.$store.getters.user.id) {
                        this.userIsOwner = true
                    }
                    return this.fetchIssues(this.$route.params.id)
                }).then(data => {
                    this.issues = data;
                    if (!this.userIsOwner) {
                        this.loading = false;
                        this.loadSuccess = true;
                    } else {
                        this.fetchUsersForProject(this.$route.params.id).then(data => {
                            this.projectMembers = data;
                            this.loadSuccess = true;
                            this.loading = false;
                        }).catch(() => {
                            this.loadSuccess = false;
                            this.loading = false;
                        })
                    }
                }).catch(() => {
                    this.loadSuccess = false;
                    this.loading = false;
                });
            },
            issueFormIssueCreated(issue) {
                if (this.issues == null) {
                    this.issues = []
                }
                this.issues.push(issue)
            },
            projectFormProjectUpdated() {
                this.loadData();
            },
            projectMemberFormMemberCreated() {
                this.fetchUsersForProject(this.$route.params.id).then(data => {
                    this.projectMembers = data;
                })
            },
            viewIssueStatuses() {
                this.$router.push('/project/'+this.project.id+"/issueStatuses")
            },
            projectMemberDelete(member) {
                if (!confirm("Are you sure you want to delete this project member?")) return;
                this.deleteProjectMember(member.projectMemberId).then(() => {
                    this.projectMembers = this.projectMembers.filter(m => m.id !== member.id)
                })
            }
        }
    }
</script>

<style scoped>
</style>
