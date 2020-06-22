<template>
    <Modal ref="modal" v-on:save="submitForm">
        <template v-slot:header>
            <h5 class="modal-title">Add Project Member</h5>
        </template>
        <template v-slot:form>
            <div class="form-group" v-if="users != null">
                <label for="projectMemberMember">New Member</label>
                <select class="form-control custom-select" id="projectMemberMember" v-model="userId" required>
                    <option v-for="user in users" v-bind:key="user.id" v-bind:value="user.id">{{ user.nickname }}
                                                                                              ({{ user.username }})
                    </option>
                </select>
            </div>
        </template>
    </Modal>
</template>

<script>
    import {createProjectMember, fetchUsers, fetchUsersForProject} from "../mixins/restMixins";
    import Modal from "./Modal";

    export default {
        name: "ProjectMemberForm",
        components: {Modal},
        mixins: [fetchUsers, createProjectMember, fetchUsersForProject],
        data() {
            return {
                userId: -1,
                users: []
            }
        },
        props: {
            projectId: {
                type: Number,
                required: true
            }
        },
        mounted() {
            this.loadData();
        },
        methods: {
            loadData() {
                this.fetchUsers().then(data => {
                    this.users = data;
                    return this.fetchUsersForProject(this.projectId)
                }).then(data => {
                    let existing = data.map(u => u.id);
                    this.users = this.users.filter(u => !existing.includes(u.id))
                });
            },
            submitForm() {
                this.createProjectMember(this.projectId, this.userId).then(response => {
                    this.$emit('projectMember-created', response);
                    this.$refs.modal.hide();
                })
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
