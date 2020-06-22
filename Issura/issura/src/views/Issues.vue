<template>
    <div class="m-4">
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
                    <h2>Your Issues</h2>
                </div>
                <div class="col col-auto">
                    <button class="btn btn-primary" v-on:click="$refs.issueFormModal.show()">Create New</button>
                </div>
            </div>
            <div class="row row-cols-1">
                <div class="col">
                    <IssueCard v-for="issue in issues" v-bind:key="issue.id" v-bind:issue="issue"/>
                </div>
            </div>
        </template>
        <IssueForm  id="issueFormModal" ref="issueFormModal" v-on:issue-created="issueFormIssueCreated"/>
        <ProblemAlert v-if="!loading && !loadSuccess" v-on:retry="loadData"></ProblemAlert>
    </div>
</template>

<script>
    import { fetchUserIssues } from '../mixins/restMixins'
    import IssueForm from "../components/IssueForm";
    import IssueCard from "../components/IssueCard";
    import ProblemAlert from "../components/ProblemAlert";

    export default {
        name: "issues",
        components: {ProblemAlert, IssueCard, IssueForm},
        mixins: [fetchUserIssues],
        data() {
            return {
                issues: [],
                loading: true,
                loadSuccess: false
            }
        },
        mounted() {
            this.loadData();
        },
        methods: {
            loadData() {
                this.loading = true;
                this.fetchUserIssues(this.$store.getters.user.id).then(data => {
                    this.issues = data;
                    this.loadSuccess = true;
                    this.loading = false;
                }).catch(() => {
                    this.loadSuccess = false;
                    this.loading = false;
                });
            },
            issueFormIssueCreated(issue) {
                this.issues.push(issue)
            }
        }
    }
</script>

<style scoped>
</style>
