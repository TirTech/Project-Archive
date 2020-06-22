<template>
    <div>
        <transition name="fade">
            <div class="modal show modalShown" v-if="shown">
                <div class="modal-dialog modal-dialog-centered">
                    <div class="modal-content">
                        <div class="modal-header">
                            <slot name="header"></slot>
                        </div>
                        <div class="modal-body">
                            <form class="needs-validation" ref="modalForm" v-bind:class="{ 'was-validated': validated}">
                                <slot name="form"></slot>
                            </form>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" v-on:click="hide">Close</button>
                            <button type="button" class="btn btn-primary" v-on:click="save">Save changes</button>
                        </div>
                    </div>
                </div>
            </div>
        </transition>
        <transition name="fade">
            <div v-if="shown" class="modal-backdrop fade show"></div>
        </transition>
    </div>
</template>

<script>
    export default {
        name: "Modal",
        data() {
            return {
                shown: false,
                validated: false
            }
        },
        methods: {
            show() {
                this.shown = true;
            },
            hide() {
                this.shown = false;
            },
            save() {
                if (this.$refs.modalForm.checkValidity()) {
                    this.$emit('save');
                }
                this.validated = true;
            }
        }
    }
</script>

<style scoped>
</style>
