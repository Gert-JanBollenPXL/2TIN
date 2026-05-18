<template>
  <div class="gallery">
    <div class="gallery-header">
      <div>
        <h2>Processed Images</h2>
        <p class="gallery-subtitle">Review results, track status, and open details.</p>
      </div>
      <div class="filters">
        <span v-if="refreshing" class="refreshing">
          <span class="refreshing-spinner" aria-hidden="true"></span>
          Updated
        </span>
        <select v-model="filter" @change="scheduleLoadImages">
          <option value="">All Images</option>
          <option value="done">Completed</option>
          <option value="processing">Processing</option>
          <option value="queued">Queued</option>
          <option value="failed">Failed</option>
        </select>
        <button class="btn" @click="loadImages">Refresh</button>
      </div>
    </div>

    <div v-if="loading" class="loading">Loading images...</div>
    
    <div v-else-if="images.length === 0" class="empty">
      <p>No images found. Upload some images to get started!</p>
    </div>

    <div v-else class="image-grid" :class="{ 'initial-load': animateOnLoad }">
        <div 
          v-for="(image, index) in images" 
          :key="image.id"
          class="image-card"
          :class="[{ 'is-processing': ['processing', 'queued'].includes(image.status) }, `status-${image.status}`]"
          role="button"
          tabindex="0"
          @click="$emit('select', image.id)"
          @keydown.enter="$emit('select', image.id)"
          @keydown.space.prevent="$emit('select', image.id)"
          :style="animateOnLoad ? { animationDelay: `${index * 40}ms` } : {}"
        >
        <div class="image-container">
          <div class="card-overlay">
            <span class="view-cta">View</span>
          </div>
          <img 
            v-if="image.processed_url" 
            :src="image.processed_url"
            :alt="`Processed ${image.id}`"
            loading="lazy"
          />
          <div v-else class="placeholder">
            <span v-if="image.status === 'processing'">🔄 Processing...</span>
            <span v-else-if="image.status === 'queued'">⏳ Queued</span>
            <span v-else-if="image.status === 'failed'">❌ Failed</span>
            <span v-else>📸 Uploaded</span>
          </div>
          
          <!-- DELETE BUTTON -->
          <button 
            class="delete-btn" 
            @click.stop="deleteImage(image.id)"
            title="Delete this image"
            aria-label="Delete image"
          >
            ✕
          </button>
        </div>
        <div class="image-info">
          <span class="status-badge" :class="`status-${image.status}`">
            {{ image.status }}
          </span>
          <span class="date">{{ formatDate(image.created_at) }}</span>
        </div>
      </div>
    </div>

    <div v-if="showPagination" class="pagination">
      <button 
        class="btn btn-secondary" 
        @click="prevPage" 
        :disabled="page === 1"
      >
        Previous
      </button>
      <span>Page {{ page }} of {{ totalPages }}</span>
      <button 
        class="btn btn-secondary" 
        @click="nextPage"
        :disabled="page >= totalPages"
      >
        Next
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch, computed } from 'vue'
import { imagesApi } from '@/api/images'

const props = defineProps({
  pauseRefresh: {
    type: Boolean,
    default: false
  }
})

const images = ref([])
const loading = ref(false)
const refreshing = ref(false)
const initialLoad = ref(true)
const animateOnLoad = ref(false)
const imageSignature = ref('')
const filter = ref('')
const page = ref(1)
const pageSize = 12
const totalPages = ref(1)
const showPagination = computed(() => !loading.value && (images.value.length > 0 || page.value > 1))
let refreshInterval = null
let loadController = null
let filterTimeout = null
let refreshIndicatorTimeout = null
let animationTimeout = null
let isTabHidden = false

const handleVisibilityChange = () => {
  isTabHidden = document.hidden
  if (isTabHidden && refreshInterval) {
    clearInterval(refreshInterval)
  }
  if (!isTabHidden && !props.pauseRefresh) {
    loadImages()
    startAutoRefresh()
  }
}

const buildSignature = (items) => items
  .map((image) => [
    image.id,
    image.status,
    image.processed_url || '',
    image.created_at || ''
  ].join('|'))
  .join(';')

const loadImages = async () => {
  if (initialLoad.value) {
    loading.value = true
  }
  if (loadController) {
    loadController.abort()
  }
  loadController = new AbortController()
  try {
    const params = {
      page: page.value,
      pageSize
    }
    if (filter.value) {
      params.status = filter.value
    }
    
    const response = await imagesApi.list(params, { signal: loadController.signal })
    const nextImages = response.data.images
    totalPages.value = response.data.totalPages || 1
    const nextSignature = buildSignature(nextImages)
    const hasChanges = nextSignature !== imageSignature.value
    images.value = nextImages
    imageSignature.value = nextSignature
    if (!initialLoad.value && hasChanges) {
      refreshing.value = true
      if (refreshIndicatorTimeout) {
        clearTimeout(refreshIndicatorTimeout)
      }
      refreshIndicatorTimeout = setTimeout(() => {
        refreshing.value = false
      }, 1200)
    }
  } catch (err) {
    if (err?.name !== 'CanceledError' && err?.code !== 'ERR_CANCELED') {
      console.error('Failed to load images:', err)
    }
  } finally {
    if (initialLoad.value) {
      loading.value = false
      initialLoad.value = false
      animateOnLoad.value = true
      if (animationTimeout) {
        clearTimeout(animationTimeout)
      }
      animationTimeout = setTimeout(() => {
        animateOnLoad.value = false
      }, 600)
    }
  }
}

const startAutoRefresh = () => {
  if (refreshInterval) {
    clearInterval(refreshInterval)
  }
  if (!props.pauseRefresh && !isTabHidden) {
    refreshInterval = setInterval(loadImages, 5000)
  }
}

const prevPage = () => {
  if (page.value > 1) {
    page.value--
    loadImages()
  }
}

const nextPage = () => {
  page.value++
  loadImages()
}

const scheduleLoadImages = () => {
  if (filterTimeout) {
    clearTimeout(filterTimeout)
  }
  filterTimeout = setTimeout(() => {
    page.value = 1
    loadImages()
  }, 350)
}

const formatDate = (dateString) => {
  const date = new Date(dateString)
  return date.toLocaleDateString() + ' ' + date.toLocaleTimeString()
}

const deleteImage = async (imageId) => {
  if (!confirm('Are you sure you want to delete this image? This will remove all files and cannot be undone.')) {
    return
  }
  
  try {
    await imagesApi.delete(imageId)
    // Remove from local array immediately for better UX
    images.value = images.value.filter(img => img.id !== imageId)
  } catch (err) {
    console.error('Failed to delete image:', err)
    alert('Failed to delete image. Please try again.')
  }
}

onMounted(() => {
  loadImages()
  // Auto-refresh every 5 seconds
  startAutoRefresh()
  document.addEventListener('visibilitychange', handleVisibilityChange)
})

watch(() => props.pauseRefresh, (isPaused) => {
  if (isPaused) {
    if (refreshInterval) {
      clearInterval(refreshInterval)
    }
  } else {
    loadImages()
    startAutoRefresh()
  }
})

onUnmounted(() => {
  if (refreshInterval) {
    clearInterval(refreshInterval)
  }
  if (filterTimeout) {
    clearTimeout(filterTimeout)
  }
  if (refreshIndicatorTimeout) {
    clearTimeout(refreshIndicatorTimeout)
  }
  if (animationTimeout) {
    clearTimeout(animationTimeout)
  }
  document.removeEventListener('visibilitychange', handleVisibilityChange)
  if (loadController) {
    loadController.abort()
  }
})
</script>

<style scoped>
.gallery {
  padding: 2rem 0;
}

.gallery-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.gallery-subtitle {
  margin-top: 0.35rem;
  color: var(--color-muted);
  font-size: 0.95rem;
}

.filters {
  display: flex;
  gap: 1rem;
  align-items: center;
}

.filters select {
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  background: white;
}

.refreshing {
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
  font-size: 0.85rem;
  color: var(--color-muted);
  min-width: 90px;
}

.refreshing-spinner {
  width: 12px;
  height: 12px;
  border: 2px solid #c8d3d3;
  border-top-color: var(--color-accent);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(6px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes shimmer {
  0% {
    transform: translateX(-100%);
  }
  100% {
    transform: translateX(100%);
  }
}

.loading, .empty {
  text-align: center;
  padding: 4rem;
  background: var(--color-card);
  border-radius: 12px;
}

.image-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 1.5rem;
}

.image-grid.initial-load .image-card {
  animation: fadeIn 0.35s ease both;
}

.image-card {
  background: var(--color-card);
  border-radius: 16px;
  overflow: hidden;
  cursor: pointer;
  transition: transform 0.25s ease, box-shadow 0.25s ease;
  border: 1px solid rgba(28, 27, 26, 0.08);
  box-shadow: 0 10px 30px rgba(30, 30, 30, 0.08);
}

.image-card:hover {
  transform: translateY(-6px);
  box-shadow: 0 18px 40px rgba(30, 30, 30, 0.12);
}

.image-container {
  width: 100%;
  height: 200px;
  background: #eef1f4;
  position: relative;
}

.image-card.is-processing .image-container::after {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(120deg, transparent 20%, rgba(255, 255, 255, 0.55) 40%, transparent 60%);
  animation: shimmer 1.4s infinite;
}

.image-container img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  image-orientation: from-image;
}

.card-overlay {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(18, 26, 27, 0.45);
  opacity: 0;
  transition: opacity 0.2s ease;
  pointer-events: none;
}

.image-card:hover .card-overlay,
.image-card:focus-visible .card-overlay {
  opacity: 1;
}

.view-cta {
  padding: 0.35rem 0.9rem;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.92);
  color: #1c1b1a;
  font-weight: 600;
  font-size: 0.85rem;
}

.delete-btn {
  position: absolute;
  top: 8px;
  right: 8px;
  width: 30px;
  height: 30px;
  border: none;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.95);
  color: #d64545;
  font-size: 16px;
  font-weight: bold;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
  box-shadow: 0 2px 4px rgba(0,0,0,0.2);
}

.delete-btn:hover {
  background: #e74c3c;
  color: white;
  transform: scale(1.1);
}

.placeholder {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
  font-size: 1.2rem;
  color: var(--color-muted);
}

.image-info {
  padding: 1rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.date {
  font-size: 0.75rem;
  color: var(--color-muted);
}

.pagination {
  margin-top: 2rem;
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 1rem;
}
</style>
