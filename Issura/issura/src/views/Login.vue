<template>
    <div class="row align-items-center justify-content-center vh-100 no-gutters">
        <form class="shadow p-3 text-left w-25" v-if="!loading">
            <h1 class="text-center mb-1"> ISSURA </h1>
            <h5 class="text-center">Please Log In</h5>
            <div class="form-group">
                <label for="formLoginUsername">Username</label>
                <input class="form-control" id="formLoginUsername" type="text" v-model="username">
            </div>
            <div class="form-group">
                <label for="formLoginPassword">Password</label>
                <input class="form-control" id="formLoginPassword" type="password" v-model="password">
            </div>
            <h6 class="text-danger" v-if="error">Username or password was incorrect</h6>
            <button class="btn btn-outline-primary btn-block" v-on:click="doAuthenticate">Log In</button>
        </form>
        <div class="spinner-border text-primary" v-if="loading">
            <span class="sr-only">Loading...</span>
        </div>
    </div>
</template>

<script>
    export default {
        name: "Login",
        data() {
            return {
                username: '',
                password: '',
                loading: true,
                error: false
            }
        },
        mounted() {
            if (this.$store.isAuthenticated) {
                this.$router.push('/home')
            } else {
                this.$store.dispatch("checkLoggedIn").then(result => {
                    if (result) {
                        this.$router.push('/home')
                    } else {
                        this.loading = false
                    }
                })
            }
        },
        methods: {
            doAuthenticate() {
                this.$store.dispatch('logIn',{username: this.username, password: this.password}).then(result => {
                    console.log(result);
                    if (result === true) {
                        this.error = false;
                        this.$router.push('/home')
                    } else {
                        this.error = true
                    }
                })
            }
        }
    }
</script>

<style scoped>

</style>
