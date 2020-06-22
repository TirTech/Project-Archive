<template>
    <Modal ref="modal" v-on:save="submitForm">
        <template v-slot:header>
            <h5 class="modal-title">Create Project</h5>
        </template>
        <template v-slot:form>
            <div class="form-group">
                <label for="projectName">Name</label>
                <input type="text" class="form-control" id="projectName" v-model="name" required/>
            </div>
            <div class="form-group">
                <label for="projectDescription">Description</label>
                <textarea class="form-control" id="projectDescription" v-model="description" required/>
            </div>
            <div class="form-group">
                <label for="projectStatus">Status</label>
                <select class="form-control custom-select" id="projectStatus" v-model="status" required>
                    <option value="OPN">Open</option>
                    <option value="CLS">Closed</option>
                    <option value="INA">Inactive</option>
                </select>
            </div>
        </template>
    </Modal>
</template>

<script>
    import {createProject, updateProject} from '../mixins/restMixins'
    import Modal from "./Modal";

    export default {
        name: "ProjectForm",
        components: {Modal},
        mixins: [createProject, updateProject],
        props: {
            project: {
                type: Object,
                required: false
            }
        },
        data() {
            return {
                name: "",
                description: "",
                status: "",
                ownerId: -1
            }
        },
        mounted() {
            this.loadData();
        },
        methods: {
            loadData() {
                if (this.project != null) {
                    this.name = this.project.name;
                    this.description = this.project.description;
                    this.status = this.project.status;
                    this.ownerId = this.project.ownerId;
                } else {
                    this.ownerId = this.$store.getters.user.id
                }
            },
            submitForm() {
                if (this.project != null) {
                    this.updateProject(this.project.id, this.name, this.description, this.status, this.ownerId).then(response => {
                        if (response) {
                            this.$emit('project-updated');
                            this.$refs.modal.hide();
                        }
                    });
                } else {
                    this.createProject(this.name, this.description, this.status, this.ownerId).then(response => {
                        this.$emit('project-created', response.project);
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
