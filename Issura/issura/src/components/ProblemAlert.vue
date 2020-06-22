<template>
    <div>
        <div class="row justify-content-center">
            <i class="fas fa-exclamation-triangle fa-3x" style="color: #EED202"></i>
        </div>
        <div class="row justify-content-center">
            <p>This resource does not exist or there was a network error</p>
        </div>
        <div class="row justify-content-center">
            <button class="btn btn-outline-warning" v-on:click="refresh">Retry</button>
        </div>
    </div>
</template>

<script>
    export default {
        name: "ProblemAlert",
        data() {
            return {}
        },
        methods: {
            refresh() {
                this.$emit('retry')
            }
        }
    }
</script>

<style scoped>
</style>
