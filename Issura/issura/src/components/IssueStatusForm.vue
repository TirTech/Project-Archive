<template>
    <Modal ref="modal" v-on:save="submitForm">
        <template v-slot:header>
            <h5 class="modal-title">Create Issue Status</h5>
        </template>
        <template v-slot:form>
                <div class="form-group">
                    <label for="issueStatusName">Name</label>
                    <input type="text" class="form-control" id="issueStatusName" v-model="name" required />
                </div>
                <div class="form-group">
                    <label for="issueStatusColor">Color</label>
                    <input class="form-control" type="color" id="issueStatusColor" v-model="color" required/>
                </div>
                <div class="form-group" v-if="issueStatus == null">
                    <label for="issueStatusTypeCode">Type Association</label>
                    <select class="form-control custom-select" id="issueStatusTypeCode" v-model="typeCode">
                        <option value="BUG">Bug</option>
                        <option value="FEA">Feature</option>
                        <option value="TSK">Task</option>
                        <option value="OTR">Other</option>
                    </select>
                </div>
        </template>
    </Modal>
</template>

<script>
    import {createIssueStatus, updateIssueStatus} from "../mixins/restMixins";
    import Modal from "./Modal";

    export default {
        name: "IssueStatusForm",
        components: {Modal},
        mixins: [createIssueStatus, updateIssueStatus],
        props: {
            projectId: {
                type: Number,
                required: true
            },
            issueStatus: {
                type: Object,
                required: false
            }
        },
        watch: {
          issueStatus: function () {
              if (this.issueStatus != null) {
                  this.name = this.issueStatus.name;
                  this.color = this.issueStatus.color;
                  this.typeCode = this.issueStatus.typeCode;
              }
          }
        },
        data() {
            return {
                name: null,
                color: "#000000",
                typeCode: null
            }
        },
        methods: {
            submitForm() {
                if (this.issueStatus == null) {
                    this.createIssueStatus(this.projectId, this.typeCode, this.color, this.name).then(response => {
                        this.$emit('issueStatus-created', response);
                        this.$refs.modal.hide();
                    });
                } else {
                    this.updateIssueStatus(this.projectId, this.issueStatus.id, this.color, this.name).then(response => {
                        this.$emit('issueStatus-updated', response);
                        this.$refs.modal.hide();
                    });
                }
            },
            show() {
                this.$refs.modal.show();
            }
        }
    }
</script>

<style scoped>
</style>
