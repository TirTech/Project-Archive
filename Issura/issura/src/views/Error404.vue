<template>
    <div class="jumbotron jumbotron-fluid text-center m-3">
        <h1><i class="fas fa-map-signs"></i> 404</h1>
        <div class="lead">The page {{ this.$route.path }} does not exist.</div>
        <hr>
        <p>You might have entered a url incorrectly or used a broken bookmark. Try navigating using the links above or use the back button.</p>
    </div>
</template>

<script>
    export default {
        name: "Error404",
    }
</script>

<style scoped>
</style>
