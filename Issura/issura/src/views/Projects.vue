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
                    <h2>Projects</h2>
                </div>
                <div class="col col-auto">
                    <button class="btn btn-primary" v-on:click="$refs.projectFormModal.show()">Create New</button>
                </div>
            </div>
            <div class="row">
                <div class="col">
                    <table class="table">
                        <thead>
                            <tr>
                                <th scope="col">Name</th>
                                <th scope="col">Description</th>
                                <th scope="col">Status</th>
                                <th scope="col">Owner Id</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr v-for="project in projects" v-bind:key="project.id">
                                <td><router-link v-bind:to="'/project/'+project.id">{{ project.name }}</router-link></td>
                                <td>{{ project.description }}</td>
                                <td>{{ project.status }}</td>
                                <td>{{ project.ownerId }}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </template>
        <ProjectForm  id="projectFormModal" ref="projectFormModal" v-on:project-created="projectFormProjectCreated"/>
        <ProblemAlert v-if="!loading && !loadSuccess" v-on:retry="loadData"></ProblemAlert>
    </div>
</template>

<script>
    import {fetchUserProjects, fetchUsers} from '../mixins/restMixins'
    import ProjectForm from "../components/ProjectForm";
    import ProblemAlert from "../components/ProblemAlert";
    
    export default {
        name: "Projects",
        components: {ProblemAlert, ProjectForm},
        mixins: [fetchUserProjects, fetchUsers],
        data() {
            return {
                projects: [],
                users: [],
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
                this.fetchUserProjects(this.$store.getters.user.id).then(data => {
                    this.projects = data;
                    return this.fetchUsers();
                }).then(data => {
                    this.users = data;
                    this.loadSuccess = true;
                    this.loading = false;
                }).catch(() => {
                    this.loadSuccess = false;
                    this.loading = false;
                });
            },
            projectFormProjectCreated(project) {
                this.projects.push(project);
            }
        }
    }
</script>

<style scoped>
</style>
