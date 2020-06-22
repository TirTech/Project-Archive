<template>
    <div class="row">
        <div class="col-12">
            <form class="needs-validation" ref="commentForm" v-bind:class="{ 'was-validated': validated}">
                <div class="form-group">
                    <label for="commentText">Comment</label>
                    <textarea class="form-control" id="commentText" v-model="text" required/>
                </div>
            </form>
        </div>
        <div class="col"></div>
        <div class="col-auto">
            <button type="button" class="btn btn-primary mr-1" v-on:click="submitForm">Post</button>
            <button type="button" class="btn btn-primary" v-on:click="cancelForm">Cancel</button>
        </div>
    </div>
</template>

<script>
    import {createComment, updateComment} from "../mixins/restMixins";

    export default {
        name: "CommentForm",
        mixins: [createComment, updateComment],
        data() {
            return {
                text: "",
                validated: false
            }
        },
        props: {
            projectId: {
                type: Number,
                required: true
            },
            issueId: {
                type: Number,
                required: true
            },
            comment: {
                type:Object,
                required: false
            }
        },
        mounted() {
            if (this.comment != null) {
                this.text = this.comment.text
            }
        },
        methods: {
            submitForm() {
                if (!this.$refs.commentForm.checkValidity()) {
                    this.validated = true;
                    return;
                }
                if (this.comment != null) {
                    this.updateComment(this.projectId, this.issueId, this.comment.id, this.text).then(() => {
                        this.$emit('comment-updated');
                        this.$emit('form-closed')
                    });
                } else {
                    this.createComment(this.projectId, this.issueId, this.text, this.$store.getters.user.id).then(data => {
                        this.$emit('comment-created',data);
                        this.$emit('form-closed')
                    });
                }
            },
            cancelForm() {
                this.$emit('form-closed')
            }
        }
    }
</script>

<style scoped>
</style>
