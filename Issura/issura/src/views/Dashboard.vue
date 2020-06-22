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
            <div class="row">
                <div class="col">
                    <div class="row justify-content-between mb-4">
                        <div class="col">
                            <h4>Issues Assigned To You</h4>
                        </div>
                    </div>
                    <div class="row row-cols-1">
                        <div class="col">
                            <IssueCard v-for="issue in assignedIssues" v-bind:key="issue.id" v-bind:issue="issue"/>
                        </div>
                    </div>
                </div>
                <div class="col">
                    <div class="row justify-content-between mb-4">
                        <div class="col">
                            <h4>Your Issues (Unassigned)</h4>
                        </div>
                    </div>
                    <div class="row row-cols-1">
                        <div class="col">
                            <IssueCard v-for="issue in unassignedIssues" v-bind:key="issue.id" v-bind:issue="issue"/>
                        </div>
                    </div>
                </div>
            </div>
        </template>
        <ProblemAlert v-if="!loading && !loadSuccess" v-on:retry="loadData"></ProblemAlert>
    </div>
</template>

<script>
    import { fetchUserIssues } from '../mixins/restMixins';
    import IssueCard from "../components/IssueCard";
    import ProblemAlert from "../components/ProblemAlert";

    export default {
        name: "Dashboard",
        components: {ProblemAlert, IssueCard},
        mixins: [fetchUserIssues],
        data() {
            return {
                issues: [],
                loading: true,
                loadSuccess: false
            }
        },
        computed: {
            assignedIssues: function () {
                return this.issues.filter(i => i.assigneeId === this.$store.getters.user.id)
            },
            unassignedIssues: function () {
                return this.issues.filter(i => i.assigneeId == null)
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
            }
        }
    }
</script>

<style scoped>
</style>
