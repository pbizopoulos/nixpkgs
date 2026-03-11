<script setup lang="ts">
import { createClient } from "@supabase/supabase-js";
import { ref } from "vue";
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || "";
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY || "";
const _supabase = createClient(supabaseUrl, supabaseKey);
const message = ref("Hello, Vue with Supabase!");
</script>
<template>
  <div>
    <h1>{{ message }}</h1>
    <p><a href="/auth.html">Open Supabase Auth UI</a></p>
  </div>
</template>
