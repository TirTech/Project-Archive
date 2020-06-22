<template>
    <div>
        <template v-if="!mini">
            <div class="card mb-4 shadow-sm">
                <div class="card-body">
                    <h5 class="card-title">{{ this.issue.title }}</h5>
                    <div class="container-fluid">
                        <div class="row">
                            <div class="col">
                                <span v-if="this.issue.type === 'BUG'"><i class="fas fa-bug"/> Bug</span>
                                <span v-if="this.issue.type === 'FEA'" ><i class="fas fa-bolt"/> Feature</span>
                                <span v-if="this.issue.type === 'TSK'" ><i class="fas fa-tasks" /> Task</span>
                                <span v-if="this.issue.type === 'OTR'"><i class="fas fa-wrench" /> Other</span>
                                <h6 v-if="status != null">Status:
                                    <span class="badge text-dark" v-bind:style="'background-color: '+this.status.color ">{{ this.status.name }}</span>
                                </h6>
                                <h6>Created: {{ this.issue.dateCreated }}</h6>
                            </div>
                            <div class="col-8">
                                Description: {{ this.issue.description }}
                            </div>
                            <div class="col-2 position-static">
                                <button class="btn btn-secondary stretched-link" v-on:click="viewIssue">View
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </template>
        <template v-if="mini">
            <div class="row border border-secondary rounded p-1 ml-0">
                <div class="col">
                    <span v-if="this.issue.type === 'BUG'"><i class="fas fa-bug"/></span>
                    <span v-if="this.issue.type === 'FEA'" ><i class="fas fa-bolt"/></span>
                    <span v-if="this.issue.type === 'TSK'" ><i class="fas fa-tasks" /></span>
                    <span v-if="this.issue.type === 'OTR'"><i class="fas fa-wrench" /></span>
                    {{ this.issue.title }}
                </div>
                <div class="col" v-if="status != null">
                    Status:
                    <span class="badge text-dark" v-bind:style="'background-color: '+this.status.color ">{{ this.status.name }}</span>
                </div>
                <div class="col-auto position-static">
                    <button class="btn btn-secondary stretched-link btn-sm py-0 px-1"
                            v-on:click="viewIssue">View
                    </button>
                </div>
            </div>
        </template>
    </div>
</template>

<script>

    import {fetchIssueStatus} from "../mixins/restMixins";

    export default {
        mixins: [fetchIssueStatus],
        data() {
            return {
                status: null
            }
        },
        props: {
            mini: {
                type: Boolean
            },
            issue: {
                type: Object,
                required: true
            }
        },
        mounted() {
            this.fetchIssueStatus(this.issue.statusId).then(data => {
                this.status = data;
            })
        },
        methods: {
            viewIssue() {
                this.$router.push('/project/' + this.issue.projectId + '/issue/' + this.issue.id)
            }
        }
    }
</script>

