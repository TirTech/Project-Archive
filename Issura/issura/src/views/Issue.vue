<template>
    <div class="m-4">
        <div class="row align-items-center justify-content-center h-100" v-if="loading">
            <div class="col">
                <div class="spinner-border text-primary">
                    <span class="sr-only">Loading...</span>
                </div>
            </div>
        </div>
        <template v-if="!loading && issue != null">
            <div class="row justify-content-between mb-4">
                <div class="col col-auto">
                    <h2>{{ this.issue.title }}</h2>
                </div>
                <div class="col col-auto">
                    <button class="btn btn-primary mr-2" v-on:click="$refs.issueFormModal.show()">Edit
                    </button>
                </div>
            </div>
            <div class="row shadow-sm p-3 mb-4 rounded">
                <div class="col">
                    <div class="row">
                        <div class="col">
                            <h6>Type:
                                <span v-if="this.issue.type === 'BUG'"><i class="fas fa-bug" /> Bug</span>
                                <span v-if="this.issue.type === 'FEA'"><i class="fas fa-bolt" /> Feature</span>
                                <span v-if="this.issue.type === 'TSK'"><i class="fas fa-tasks" /> Task</span>
                                <span v-if="this.issue.type === 'OTR'"><i class="fas fa-wrench" /> Other</span></h6>
                            <h6>Status:
                                <span class="badge text-dark" v-bind:style="'background-color: '+this.status.color ">{{ this.status.name }}</span>
                            </h6>
                            <h6>Creator: {{ this.creator.nickname }} ({{ this.creator.username }})</h6>
                            <h6 v-if="assignee != null">Assignee: {{ this.assignee.nickname }} ({{ this.assignee.username }})</h6>
                            <h6 v-if="assignee == null">Assignee: Unassigned</h6>
                            <h6>Created: {{ this.issue.dateCreated }}</h6>
                        </div>
                        <div class="col-8 ">
                            Description: {{ this.issue.description }}
                        </div>
                    </div>
                    <div class="row justify-content-between">
                        <div class="col">
                            <h6>Linked Issues</h6>
                        </div>
                    </div>
                    <div class="row justify-content-between pl-2" v-if="dependantIssues.length > 0">
                        <div class="col">
                            <p>Dependants:</p>
                        </div>
                    </div>
                    <template v-for="linkedIssue in dependantIssues" >
                        <div class="row align-items-center pl-2" v-bind:key="linkedIssue.id">
                            <div class="col-auto">
                                <IssueCard mini v-bind:issue="linkedIssue"></IssueCard>
                            </div>
                            <i class="fas fa-trash-alt pl-2 text-danger clickable" v-on:click="linkedIssueDelete(linkedIssue)"/>
                        </div>
                    </template>
                    <div class="row justify-content-between pl-2" v-if="dependeeIssues.length > 0">
                        <div class="col">
                            <p>Depends On:</p>
                        </div>
                    </div>
                    <template v-for="linkedIssue in dependeeIssues">
                        <div class="row align-items-center pl-2" v-bind:key="linkedIssue.id">
                            <div class="col-auto">
                                <IssueCard mini v-bind:issue="linkedIssue"></IssueCard>
                            </div>
                            <i class="fas fa-trash-alt pl-2 text-danger clickable" v-on:click="linkedIssueDelete(linkedIssue)"/>
                        </div>
                    </template>
                    <div class="row">
                        <div class="col">
                            
                            <button class="btn btn-outline-primary btn-sm mr-2" v-on:click="$refs.linkedIssueFormModal.show()">Link Issue</button>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row row-cols-1 mb-4">
                <div class="col">
                    <h5>Comments:</h5>
                </div>
                <div class="col mb-2">
                    <button class="btn btn-sm btn-outline-secondary" v-if="!showCommentBox"
                            v-on:click="showCommentBox = true">Add Comment
                    </button>
                    <CommentForm v-if="showCommentBox" v-bind:issue-id="issue.id" v-bind:project-id="issue.projectId"
                                 v-on:form-closed="commentFormClosed" v-bind:comment="commentBoxComment"
                                 v-on:comment-created="commentFormCommentCreated"
                                 v-on:comment-updated="commentFormCommentUpdated" />
                </div>
                <div class="col">
                    <CommentCard v-for="comment in comments" v-bind:comment="comment" v-bind:key="comment.id"
                                 v-on:comment-edit="commentCardEdit(comment)"
                                 v-on:comment-delete="commentCardDelete(comment)" />
                </div>
            </div>
            <IssueForm id="issueFormModal" ref="issueFormModal" v-bind:issue="issue"
                       v-on:issue-updated="issueFormIssueUpdated" />
            <LinkedIssueForm id="linkedIssueFormModal" ref="linkedIssueFormModal" v-bind:issue="issue"
                             v-on:linkedIssue-created="linkedIssueFormCreated" />
        </template>
        <ProblemAlert v-if="!loading && issue == null" v-on:retry="loadData"></ProblemAlert>
    </div>
</template>

<script>
    import {
        deleteComment,
        deleteLinkedIssue,
        fetchComments,
        fetchIssue,
        fetchIssueStatus,
        fetchLinkedIssuesFlattened,
        fetchUser
    } from '../mixins/restMixins'
    import ProblemAlert from "../components/ProblemAlert";
    import IssueForm from "../components/IssueForm";
    import CommentCard from "../components/CommentCard";
    import LinkedIssueForm from "../components/LinkedIssueForm";
    import IssueCard from "../components/IssueCard";
    import CommentForm from "../components/CommentForm";

    export default {
        name: "Issue",
        components: {CommentForm, IssueCard, LinkedIssueForm, CommentCard, IssueForm, ProblemAlert},
        mixins: [fetchComments, fetchLinkedIssuesFlattened, fetchUser, fetchIssueStatus, fetchIssue, deleteComment, deleteLinkedIssue],
        data() {
            return {
                issue: null,
                loading: true,
                creator: null,
                assignee: null,
                status: null,
                comments: null,
                linkedIssueIssues: null,
                showCommentBox: false,
                commentBoxComment: null
            }
        },
        mounted() {
            this.loadData()
        },
        watch: {
            $route() {
                this.loadData();
            }
        },
        computed: {
            dependantIssues: function() {
                return this.linkedIssueIssues.filter(i => i.isDependant)
            },
            dependeeIssues: function() {
                return this.linkedIssueIssues.filter(i => !i.isDependant)
            }
        },
        methods: {
            loadData() {
                this.loading = true;
                this.fetchIssue(this.$route.params.projectId, this.$route.params.id).then(data => {
                    this.issue = data;
                    let actions = [
                        this.fetchUser(this.issue.creatorId).then(data => this.creator = data),
                        this.fetchComments(this.$route.params.projectId, this.issue.id).then(data => this.comments = data),
                        this.fetchLinkedIssuesFlattened(this.$route.params.projectId, this.issue.id).then(data => this.linkedIssueIssues = data),
                        this.fetchIssueStatus(this.issue.statusId).then(data => this.status = data),
                    ];
                    if (this.issue.assigneeId != null) {
                        actions.push(this.fetchUser(this.issue.assigneeId).then(data => this.assignee = data))
                    } else {
                        this.assignee = null
                    }
                    Promise.all(actions)
                        .then(() => this.loading = false)
                        .catch(() => {
                            this.loading = false;
                            this.issue = null
                        });
                }).catch(() => {
                    this.loading = false;
                    this.issue = null
                });
            },
            issueFormIssueUpdated() {
                this.loadData();
            },
            linkedIssueFormCreated(linkedIssue) {
                if (this.linkedIssueIssues == null) {
                    this.linkedIssueIssues = []
                }
                let newIssueId = linkedIssue.parentIssueId === this.issue.id ? linkedIssue.childIssueId : linkedIssue.parentIssueId;
                this.fetchIssue(this.issue.projectId, newIssueId).then(data => {
                    let newIssue = data;
                    newIssue["linkedIssueId"] = linkedIssue.id;
                    newIssue["isDependant"] = linkedIssue.parentIssueId === this.issue.id;
                    this.linkedIssueIssues.push(newIssue);
                });
            },
            commentFormCommentCreated(comment) {
                if (this.comments == null) {
                    this.comments = []
                }
                this.comments.push(comment)
            },
            commentCardEdit(comment) {
                this.commentBoxComment = comment;
                this.showCommentBox = true;
            },
            commentCardDelete(comment) {
                if (!confirm("Are you sure you want to delete this comment?")) return;
                this.deleteComment(this.$route.params.projectId, this.issue.id, comment.id).then(response => {
                    this.comments = this.comments.filter(c => c.id !== comment.id);
                });
            },
            commentFormCommentUpdated() {
                this.fetchComments(this.$route.params.projectId, this.issue.id).then(data => this.comments = data);
            },
            commentFormClosed() {
                this.showCommentBox = false;
                this.commentBoxComment = null;
            },
            linkedIssueDelete(issue) {
                if (!confirm("Are you sure you want to delete this linked issue?")) return;
                this.deleteLinkedIssue(this.$route.params.projectId, this.issue.id, issue.linkedIssueId).then(() => {
                    this.linkedIssueIssues = this.linkedIssueIssues.filter(i => i.linkedIssueId !== issue.linkedIssueId)
                });
            }
        }
    }
</script>

<style scoped>
</style>
