import Vue from 'vue'
import Vuex from 'vuex'
import axios from 'axios';

Vue.use(Vuex);

export default new Vuex.Store({
    state: {
        user: null,
        loggedIn: false,
        darkMode: false
    },
    mutations: {
        SET_USER(state, user) {
            state.user = user
        },
        SET_LOGGED_IN(state, status) {
            state.loggedIn = status
        },
        SET_DARK_MODE(state, status) {
            state.darkMode = status
        }
    },
    actions: {
        setDarkMode(context, state) {
            context.commit('SET_DARK_MODE', state);
            let d = new Date();
            d.setTime(d.getTime() + (365 * 24 * 60 * 60 * 1000));
            let expires = "expires="+d.toUTCString();
            document.cookie = 'issura_dark_mode=' + state + ";" + expires + ';path=/';
        },
        checkDarkMode(context) {
            let name = "issura_dark_mode=";
            let ca = document.cookie.split(';');
            let i = 0;
            for (i = 0; i < ca.length; i++) {
                let c = ca[i].trimStart();
                if (c.indexOf(name) === 0) {
                    context.commit('SET_DARK_MODE', c.substring(name.length) === 'true');
                    return c.substring(name.length) === 'true';
                }
            }
            return false;
        },
        checkLoggedIn(context) {
            return axios.get('signin').then(response => {
                let userId = response.data['id'];
                return axios.get('users/' + userId)
            }).then(response => {
                context.commit('SET_USER', response.data);
                context.commit('SET_LOGGED_IN', true);
                return true;
            }).catch(reason => {
                console.log("Not logged in: " + reason);
                return false
            })
        },
        logIn(context, payload) {
            return axios.post('signin', payload).then(response => {
                context.commit('SET_LOGGED_IN', true);
                let userId = response.data['id'];
                return axios.get('users/' + userId)
            }).then(response => {
                context.commit('SET_USER', response.data);
                return true;
            }).catch(reason => {
                console.error(reason.response)
            })
        },
        syncUser(context) {
          return axios.get("users/"+context.state.user.id).then(response => {
              context.commit('SET_USER', response.data);
              return true
          })
        },
        logOut(context) {
            return axios.delete('signin').then(() => {
                context.commit('SET_LOGGED_IN', false);
                context.commit('SET_USER', null);
                return true;
            }).catch(reason => {
                console.error(reason.response);
                return false;
            })
        }
    },
    getters: {
        isAuthenticated(state) {
            return state.loggedIn
        }
        ,
        user(state) {
            return state.user
        },
        darkModeOn(state) {
            return state.darkMode
        }
    },
    modules: {}
})
