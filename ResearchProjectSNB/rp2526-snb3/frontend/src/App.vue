<template>
  <div id="app">
    <nav class="navbar">
      <div class="nav-brand">
        <RouterLink to="/upload" class="brand-link">🔲 pxlcensor</RouterLink>
      </div>
      <div class="nav-links">
        <RouterLink to="/upload" class="nav-link" active-class="active">Upload</RouterLink>
        <RouterLink to="/gallery" class="nav-link" active-class="active">Gallery</RouterLink>
        <RouterLink to="/queue" class="nav-link" active-class="active">Queue</RouterLink>
      </div>
    </nav>

    <main class="container">
      <RouterView v-slot="{ Component }">
        <component
          :is="Component"
          v-bind="routeProps"
          @uploaded="handleUploaded"
          @select="handleImageSelect"
        />
      </RouterView>
      <ImageDetail v-if="selectedImage" :imageId="selectedImage" @close="selectedImage = null" />
    </main>
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import ImageDetail from './components/ImageDetail.vue'

const selectedImage = ref(null)
const route = useRoute()
const router = useRouter()
const routeProps = computed(() => {
  if (route.name === 'gallery') {
    return { pauseRefresh: Boolean(selectedImage.value) }
  }
  return {}
})

const handleUploaded = () => {
  router.push({ name: 'gallery' })
}

const handleImageSelect = (imageId) => {
  selectedImage.value = imageId
}

watch(() => route.name, () => {
  selectedImage.value = null
})
</script>

<style>
@import url('https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;500;600&family=Space+Grotesk:wght@500;600;700&display=swap');

:root {
  --color-ink: #1c1b1a;
  --color-muted: #5d5a55;
  --color-card: #ffffff;
  --color-accent: #2f6f6d;
  --color-accent-strong: #1e4d4a;
  --color-highlight: #f4b942;
  --color-border: rgba(28, 27, 26, 0.12);
}
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'IBM Plex Sans', 'Segoe UI', sans-serif;
  background:
    radial-gradient(circle at 10% 20%, #fff6e9 0%, transparent 45%),
    radial-gradient(circle at 80% 10%, #e9f4ff 0%, transparent 40%),
    linear-gradient(180deg, #f6f1e9 0%, #f5f6f2 45%, #eef2f7 100%);
  color: var(--color-ink);
}

h1, h2, h3, .brand-link {
  font-family: 'Space Grotesk', 'IBM Plex Sans', sans-serif;
}

#app {
  min-height: 100vh;
}

.navbar {
  background: rgba(255, 255, 255, 0.86);
  backdrop-filter: blur(14px);
  border-bottom: 1px solid rgba(28, 27, 26, 0.08);
  padding: 1rem 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.nav-brand {
  display: flex;
  align-items: center;
}

.nav-links {
  display: flex;
  gap: 1rem;
}

.brand-link {
  font-size: 1.6rem;
  font-weight: 700;
  color: var(--color-ink);
  text-decoration: none;
}

.nav-link {
  background: none;
  border: 1px solid transparent;
  padding: 0.5rem 1.1rem;
  cursor: pointer;
  border-radius: 999px;
  transition: background 0.2s ease, border-color 0.2s ease, color 0.2s ease;
  text-decoration: none;
  color: inherit;
  display: inline-flex;
  align-items: center;
}

.nav-link:hover {
  background: rgba(47, 111, 109, 0.08);
  border-color: rgba(47, 111, 109, 0.25);
}

.nav-link.active {
  background: var(--color-accent);
  color: white;
  border-color: var(--color-accent);
}

.container {
  max-width: 1200px;
  margin: 2.5rem auto;
  padding: 0 1.5rem 3rem;
}

.btn {
  background: linear-gradient(135deg, var(--color-accent), var(--color-accent-strong));
  color: white;
  border: 1px solid transparent;
  padding: 0.7rem 1.4rem;
  border-radius: 999px;
  cursor: pointer;
  font-size: 0.95rem;
  font-weight: 600;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
  box-shadow: 0 12px 25px rgba(47, 111, 109, 0.25);
}

.btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 16px 30px rgba(47, 111, 109, 0.3);
}

.btn:disabled {
  background: #cfd5d5;
  box-shadow: none;
  cursor: not-allowed;
}

.btn-secondary {
  background: white;
  color: var(--color-ink);
  border: 1px solid var(--color-border);
  box-shadow: none;
}

.status-badge {
  display: inline-block;
  padding: 0.25rem 0.6rem;
  border-radius: 999px;
  font-size: 0.8rem;
  font-weight: 600;
  text-transform: capitalize;
}

.status-uploaded { background: #e6f2ff; color: #2b6cb0; }
.status-queued { background: #fff5d6; color: #b36b00; }
.status-processing { background: #e9fbf4; color: #1f7a64; }
.status-done { background: #e8f5e9; color: #2e7d32; }
.status-failed { background: #ffe6e6; color: #b02b2b; }
</style>
