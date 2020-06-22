import Vue from 'vue'
import VueRouter from 'vue-router'
import store from '../store/index'

Vue.use(VueRouter);

const routes = [
    {
        path: '/home',
        name: 'home',
        alias: '/',
        component: () => import('../views/Dashboard.vue'),
        meta: {
            requiresAuth: true
        }
    },{
        path: '/login',
        name: 'login',
        component: () => import('../views/Login.vue'),
        meta: {
            requiresAuth: false
        }
    },{
        path: '/projects',
        name: 'projects',
        component: () => import('../views/Projects.vue'),
        meta: {
            requiresAuth: true
        }
    },{
        path: '/issues',
        name: 'issues',
        component: () => import('../views/Issues.vue'),
        meta: {
            requiresAuth: true
        }
    },{
        path: '/project/:id',
        name: 'project',
        component: () => import('../views/Project.vue'),
        meta: {
            requiresAuth: true
        }
    },{
        path: '/project/:projectId/issue/:id',
        name: 'issue',
        component: () => import('../views/Issue.vue'),
        meta: {
            requiresAuth: true
        }
    },{
        path: '/project/:projectId/issueStatuses',
        name: 'issueStatus',
        component: () => import('../views/IssueStatus.vue'),
        meta: {
            requiresAuth: true
        }
    },{
        path: '*',
        name: '404',
        component: () => import('../views/Error404.vue'),
        meta: {
            requiresAuth: false
        }
    },
];

const router = new VueRouter({
    routes
});

router.beforeEach((to, from, next) => {
    if(to.matched.some(path => path.meta.requiresAuth) && !store.getters.isAuthenticated) {
        next('/login');
    } else {
        next()
    }
});

export default router
