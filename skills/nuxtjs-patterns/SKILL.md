---
name: nuxtjs-patterns
description: Nuxt best practices, Vue Composition API, routing patterns, and data fetching strategies. Use when building Nuxt applications.
---

# Nuxt Patterns

## Project Structure

```
nuxt-app/
├── pages/                  # File-based routing
│   ├── index.vue
│   ├── (auth)/             # Route group notation (Nuxt 3)
│   │   ├── login.vue
│   │   └── register.vue
│   └── dashboard/
│       ├── index.vue
│       └── [id].vue        # Dynamic route
├── components/             # Auto-imported components
├── composables/            # Auto-imported composables (hooks)
├── server/
│   └── api/
│       └── test.ts         # Nitro API routes
├── layouts/                # Layouts
├── app.vue                 # Main entrypoint
└── nuxt.config.ts          # Nuxt configuration
```

## Composition API

### Basic Component

```vue
<template>
  <div>
    <h1>{{ title }}</h1>
    <button @click="increment">Count: {{ count }}</button>
  </div>
</template>

<script setup lang="ts">
// Variables are implicitly returned to the template
const title = ref('Dashboard')
const count = ref(0)

const increment = () => {
  count.value++
}
</script>
```

## Data Fetching

### Server Fetching (useFetch)

```vue
<script setup lang="ts">
// Fetches data on the server side and passes it to the client
const { data: users, pending, error } = await useFetch('/api/users')
</script>

<template>
  <div v-if="pending">Loading...</div>
  <div v-else-if="error">Error: {{ error.message }}</div>
  <ul v-else>
    <li v-for="user in users" :key="user.id">{{ user.name }}</li>
  </ul>
</template>
```

### Advanced Data Fetching (useAsyncData)

```vue
<script setup lang="ts">
const { data, refresh } = await useAsyncData(
  'unique-key',
  () => $fetch('/api/complex')
)
</script>
```

## State Management (Pinia)

```ts
// stores/counter.ts
export const useCounterStore = defineStore('counter', () => {
  const count = ref(0)
  const doubleCount = computed(() => count.value * 2)
  
  function increment() {
    count.value++
  }

  return { count, doubleCount, increment }
})
```

## Protected Routes (Middleware)

```ts
// middleware/auth.ts
export default defineNuxtRouteMiddleware((to, from) => {
  const user = useSupabaseUser()
  
  if (!user.value) {
    return navigateTo('/login')
  }
})
```

Usage in component:

```vue
<script setup lang="ts">
definePageMeta({
  middleware: 'auth'
})
</script>
```
