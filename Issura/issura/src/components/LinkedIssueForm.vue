<template>
    <Modal ref="modal" v-on:save="submitForm">
        <template v-slot:header>
            <h5 class="modal-title">Create Linked Issue</h5>
        </template>
        <template v-slot:form>
            <div class="form-group">
                <label for="linkedIssueFirstDependant">Relationship</label>
                <select class="form-control custom-select" id="linkedIssueFirstDependant" v-model="firstDependant" required>
                    <option value="true">dependent of</option>
                    <option value="false">dependee of</option>
                </select>
            </div>
            <div class="form-group">
                <label for="linkedIssueIssue">Issue</label>
                <select class="form-control custom-select" id="linkedIssueIssue" v-model="linkedIssue" required>
                    <option v-for="issue in issues" v-bind:key="issue.id" v-bind:value="issue.id">{{ issue.title}}</option>
                </select>
            </div>
        </template>
    </Modal>
</template>

<script>
    import {createLinkedIssue, fetchIssues, fetchLinkedIssues} from '../mixins/restMixins'
    import Modal from "./Modal";

    export default {
        name: "LinkedIssueForm",
        components: {Modal},
        mixins: [createLinkedIssue, fetchIssues, fetchLinkedIssues],
        props: {
            issue: {
                type: Object,
                required: true
            }
        },
        data() {
            return {
                linkedIssue: null,
                firstDependant: false,
                issues: null
            }
        },
        methods: {
            loadData() {
                this.fetchIssues(this.issue.projectId).then(data => {
                    this.issues = data.filter(i => i.id !== this.issue.id);
                    return this.fetchLinkedIssues(this.issue.projectId,this.issue.id)
                }).then(data => {
                    let alreadyLinked = data.map(i => i.parentIssueId === this.issue.id ? i.childIssueId : i.parentIssueId);
                    this.issues = this.issues.filter(i => !alreadyLinked.includes(i.id))
                });
            },
            submitForm() {
                this.createLinkedIssue(this.issue.projectId, this.issue.id, this.linkedIssue, this.firstDependant).then(response => {
                    this.$emit('linkedIssue-created', response);
                    this.$refs.modal.hide();
                });
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
