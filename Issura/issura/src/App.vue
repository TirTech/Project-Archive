<template>
    <div id="app" class=".container-fluid">
        <link v-bind:href="publicPath+'bootstrap_darkly.min.css'" rel="stylesheet" v-if="darkChecked">
        <link v-bind:href="publicPath+'bootstrap.min.css'" rel="stylesheet" v-if="!darkChecked">
        <nav class="navbar navbar-expand navbar-dark bg-dark sticky-top" v-if="$store.getters.isAuthenticated">
            <router-link to="/" class="navbar-brand">Issura</router-link>
            <ul class="navbar-nav mr-auto">
                <li class="nav-item">
                    <router-link class="nav-link" to="/home">Home</router-link>
                </li>
                <li class="nav-item">
                    <router-link class="nav-link" to="/projects">Projects</router-link>
                </li>
                <li class="nav-item">
                    <router-link class="nav-link" to="/issues">Issues</router-link>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#" v-on:click="logOut">Log Out</a>
                </li>
            </ul>
            <span class="text-white px-2" v-if="!nicknameFormShown">
                    {{ $store.getters.user.nickname }} ({{ $store.getters.user.username }})
                    <i class="fas fa-edit pl-2 clickable" v-on:click="showNicknameForm"></i>
                </span>
            <form class="form-inline">
                <input type="text" class="form-control" id="nickname" v-model="nickname" v-if="nicknameFormShown"/>
                <button class="btn btn-outline-success btn-sm" v-if="nicknameFormShown" v-on:click="setNickname" >Save</button>
                <div class="custom-control custom-switch">
                    <input type="checkbox" class="custom-control-input" id="darkSwitch" v-model="darkChecked">
                    <label class="custom-control-label text-white" for="darkSwitch">Dark Mode</label>
                </div>
            </form>
        </nav>
        <router-view />
    </div>
</template>

<script>
    import {updateUser} from "./mixins/restMixins";

    export default {
        name: "App",
        mixins: [updateUser],
        data() {
            return {
                darkChecked: false,
                publicPath: process.env.BASE_URL,
                nicknameFormShown: false,
                nickname: ""
            }
        },
        mounted() {
            this.$store.dispatch('checkDarkMode').then(res => {
                this.darkChecked = res;
            });
        },
        watch: {
            darkChecked: function (nv, ov) {
                this.$store.dispatch('setDarkMode', nv)
            }
        },
        methods: {
            logOut() {
                this.$store.dispatch('logOut').then(result => {
                    console.log(result);
                    this.$router.push('/login')
                });
            },
            setNickname() {
                this.nicknameFormShown = false;
                this.updateUser(this.nickname, this.$store.getters.user.id).then(() => {
                    this.$store.dispatch("syncUser");
                })
            },
            showNicknameForm() {
                this.nickname = this.$store.getters.user.nickname;
                this.nicknameFormShown = true;
            }
        }
    }
</script>
