<template>
    <div class="card shadow-sm">
        <div class="card-body" v-if="this.user != null">
            <h6 class="card-title">{{ this.user.nickname }} ({{ this.user.username }})
                <span class="card-subtitle mb-2 text-muted">{{ this.comment.dateCreated}}</span>
                <i class="fas fa-edit pl-2 clickable" v-on:click="$emit('comment-edit')" v-if="user.id === $store.getters.user.id"></i>
                <i class="fas fa-trash-alt pl-2 text-danger clickable" v-on:click="$emit('comment-delete')" v-if="user.id === $store.getters.user.id"></i>
            </h6>
            
            <p class="card-text">{{ this.comment.text }}</p>
        </div>
    </div>
</template>

<script>
    import {fetchUser} from "../mixins/restMixins";

    export default {
        name: "CommentCard",
        mixins: [fetchUser],
        data() {
            return {
                user: null
            }
        },
        props: {
            comment: {
                type: Object,
                required: true
            }
        },
        mounted() {
            this.fetchUser(this.comment.creatorId).then(data => {
                this.user = data;
            })
        },
        methods: {
            example() {
                return null;
            }
        }
    }
</script>

<style scoped>
</style>
