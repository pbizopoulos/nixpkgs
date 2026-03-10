<script setup lang="ts">
import { createClient } from "@supabase/supabase-js";
import { ref } from "vue";
const postgresUrl = import.meta.env.VITE_POSTGRES_URL || "";
const postgresKey = import.meta.env.VITE_POSTGRES_ANON_KEY || "";
const _postgres = createClient(postgresUrl, postgresKey);
const message = ref("Hello, Vue with Postgres!");
</script>
<template>
  <div>
    <h1>{{ message }}</h1>
  </div>
</template>
