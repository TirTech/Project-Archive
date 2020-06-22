<template>
    <div class="m-3">
        <div class="row align-items-center justify-content-center h-100" v-if="loading">
            <div class="col col-auto">
                <div class="spinner-border text-primary">
                    <span class="sr-only">Loading...</span>
                </div>
            </div>
        </div>
        <template v-if="!loading && loadSuccess">
            <div class="row justify-content-between mb-4">
                <div class="col">
                    <h2>Issue Statuses for {{ this.project.name }}</h2>
                </div>
                <div class="col col-auto">
                    <button class="btn btn-primary" v-on:click="$refs.issueStatusFormModal.show()">Create New</button>
                </div>
            </div>
            <div class="row">
                <div class="col">
                    <table class="table">
                        <thead>
                            <tr>
                                <th scope="col">Name</th>
                                <th scope="col">Color</th>
                                <th scope="col">Type Association</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr v-for="status in issueStatuses" v-bind:key="status.id">
                                <td>{{ status.name }} <i class="fas fa-edit pl-2 clickable" v-on:click="issueStatusEdit(status)" v-if="status.projectId != null"></i></td>
                                <td><span class="badge text-dark" v-bind:style="'background-color: '+ status.color ">{{ status.color }}</span></td>
                                <td>
                                    <span v-if="status.typeCode === 'BUG'"><i class="fas fa-bug"/> Bug</span>
                                    <span v-if="status.typeCode === 'FEA'" ><i class="fas fa-bolt"/> Feature</span>
                                    <span v-if="status.typeCode === 'TSK'" ><i class="fas fa-tasks" /> Task</span>
                                    <span v-if="status.typeCode === 'OTR'"><i class="fas fa-wrench" /> Other</span>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
            <IssueStatusForm  id="issueStatusFormModal" ref="issueStatusFormModal" v-bind:project-id="this.$route.params.projectId | asInt" v-on:issueStatus-created="issueStatusFormStatusCreated" v-on:issueStatus-updated="issueStatusFormStatusUpdated" v-bind:issue-status="issueStatusFormIssueStatus"/>
        </template>
        <ProblemAlert v-if="!loading && !loadSuccess" v-on:retry="loadData"></ProblemAlert>
    </div>
</template>

<script>
    import {fetchIssueStatuses, fetchProject} from '../mixins/restMixins'
    import IssueStatusForm from "../components/IssueStatusForm";
    import ProblemAlert from "../components/ProblemAlert";

    export default {
        name: "IssueStatus",
        components: {ProblemAlert, IssueStatusForm},
        mixins: [fetchIssueStatuses, fetchProject],
        data() {
            return {
                issueStatuses: [],
                project: null,
                loading: true,
                loadSuccess: false,
                issueStatusFormIssueStatus: null
            }
        },
        filters: {
          asInt(num) {
              return parseInt(num);
          }
        },
        mounted() {
            this.loadData();
        },
        methods: {
            loadData() {
                this.fetchIssueStatuses(this.$route.params.projectId).then(data => {
                    this.issueStatuses = data;
                    return this.fetchProject(this.$route.params.projectId);
                }).then(data => {
                    this.project = data;
                    this.loading = false;
                    this.loadSuccess = true;
                }).catch(() => {
                    this.loading = false;
                    this.loadSuccess = false;
                });
            },
            issueStatusFormStatusCreated(status) {
                this.issueStatuses.push(status)
            },
            issueStatusFormStatusUpdated() {
                this.loadData()
            },
            issueStatusEdit(status) {
                this.issueStatusFormIssueStatus = status;
                this.$refs.issueStatusFormModal.show()
            }
        }
    }
</script>

<style scoped>
</style>
