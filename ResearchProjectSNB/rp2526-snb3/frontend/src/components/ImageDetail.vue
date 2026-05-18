<template>
  <div
    class="modal-overlay"
    @click.self="$emit('close')"
    @keydown.esc="$emit('close')"
    tabindex="0"
    ref="overlay"
  >
    <div class="modal" role="dialog" aria-modal="true" aria-labelledby="image-detail-title">
      <div class="modal-header">
        <h2 id="image-detail-title">Image Details</h2>
        <button class="close-btn" @click="$emit('close')" aria-label="Close image details">✕</button>
      </div>
      
      <div v-if="loading" class="loading">Loading...</div>
      
      <div v-else-if="image" class="modal-content">
        <div class="image-comparison">
          <div class="image-panel">
            <h3>Original</h3>
            <div class="image-container">
              <img 
                v-if="originalUrl && !originalError" 
                :src="originalUrl"
                alt="Original"
                @error="onOriginalError"
                @load="onOriginalLoad"
                ref="originalImg"
              />
              <div v-else class="placeholder">
                <span v-if="originalError">❌ Failed to load original</span>
                <span v-else-if="!originalUrl">📁 Original not available</span>
                <span v-else>📸 Loading original...</span>
              </div>
            </div>
          </div>
          
          <div class="image-panel">
            <h3>Processed</h3>
            <div class="image-container">
              <img 
                v-if="image.processed_url" 
                :src="image.processed_url"
                alt="Processed"
                @load="onProcessedLoad"
                ref="processedImg"
                loading="lazy"
              />
              <div v-else class="placeholder">
                <span v-if="image.status === 'processing'">🔄 Processing...</span>
                <span v-else-if="image.status === 'queued'">⏳ In Queue</span>
                <span v-else-if="image.status === 'failed'">❌ Processing Failed</span>
                <span v-else>⏳ Not processed yet</span>
              </div>
            </div>
          </div>
        </div>
        
        <div class="details">
          <h3>Information</h3>
          <div class="detail-grid">
            <div class="detail-item">
              <span class="label">Status:</span>
              <span class="status-badge" :class="`status-${image.status}`">
                {{ image.status }}
              </span>
            </div>
            <div class="detail-item">
              <span class="label">File Type:</span>
              <span>{{ image.mime }}</span>
            </div>
            <div class="detail-item">
              <span class="label">File Size:</span>
              <span>{{ formatBytes(image.bytes) }}</span>
            </div>
            <div v-if="originalDimensions" class="detail-item">
              <span class="label">Original Resolution:</span>
              <span>{{ originalDimensions }}</span>
            </div>
            <div v-if="processedDimensions" class="detail-item">
              <span class="label">Processed Resolution:</span>
              <span>{{ processedDimensions }}</span>
            </div>
            <div class="detail-item">
              <span class="label">SHA256:</span>
              <span class="hash">{{ image.sha256 ? image.sha256.substring(0, 16) + '...' : 'N/A' }}</span>
            </div>
            <div class="detail-item">
              <span class="label">Original Path:</span>
              <span class="path">{{ image.original_path || 'N/A' }}</span>
            </div>
            <div class="detail-item">
              <span class="label">Processed Path:</span>
              <span class="path">{{ image.processed_path || 'Not processed' }}</span>
            </div>
            <div class="detail-item">
              <span class="label">Processing Options:</span>
              <span>{{ formatProcessingOptions(image.processing_options) }}</span>
            </div>
            <div class="detail-item">
              <span class="label">Uploaded:</span>
              <span>{{ formatDate(image.created_at) }}</span>
            </div>
          </div>
        </div>
        
        <div v-if="image.events && image.events.length > 0" class="events">
          <h3>Processing Timeline</h3>
          <div class="timeline">
            <div v-for="event in image.events" :key="event.at" class="timeline-item">
              <div class="timeline-marker"></div>
              <div class="timeline-content">
                <div class="timeline-type">{{ formatEventType(event.type) }}</div>
                <div class="timeline-time">{{ formatDate(event.at) }}</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch } from 'vue'
import { imagesApi } from '@/api/images'
import { formatBytes } from '@/utils/format'

const props = defineProps({
  imageId: String
})

defineEmits(['close'])

const image = ref(null)
const loading = ref(true)
const originalUrl = ref('')
const originalError = ref(false)
const originalDimensions = ref('')
const processedDimensions = ref('')
const originalImg = ref(null)
const processedImg = ref(null)
const blobUrls = ref([]) // Track blob URLs for cleanup
const overlay = ref(null)
let loadController = null
let fetchController = null

const cancelRequests = () => {
  if (loadController) {
    loadController.abort()
  }
  if (fetchController) {
    fetchController.abort()
  }
}

const loadImage = async () => {
  if (!props.imageId) return
  
  try {
    loading.value = true
    originalError.value = false
    originalDimensions.value = ''
    processedDimensions.value = ''
    originalUrl.value = ''
    cancelRequests()
    loadController = new AbortController()
    
    const response = await imagesApi.get(props.imageId, { signal: loadController.signal })
    image.value = response.data
    
    if (response.data.original_url) {
      // For images with signed URLs that require headers, we need to fetch and convert to blob URL
      if (response.data.original_headers) {
        try {
          fetchController = new AbortController()
          const imageResponse = await fetch(response.data.original_url, {
            headers: response.data.original_headers,
            signal: fetchController.signal
          })
          
          if (imageResponse.ok) {
            const blob = await imageResponse.blob()
            const blobUrl = URL.createObjectURL(blob)
            blobUrls.value.push(blobUrl) // Track for cleanup
            originalUrl.value = blobUrl
          } else {
            console.error('Failed to fetch original image:', imageResponse.status, imageResponse.statusText)
            originalError.value = true
          }
        } catch (fetchError) {
          if (fetchError?.name !== 'AbortError') {
            console.error('Error fetching original image:', fetchError)
            originalError.value = true
          }
        }
      } else {
        originalUrl.value = response.data.original_url
      }
    }
  } catch (error) {
    if (error?.name !== 'CanceledError' && error?.code !== 'ERR_CANCELED') {
      console.error('Failed to load image:', error)
    }
  } finally {
    loading.value = false
  }
}

const onOriginalLoad = () => {
  if (originalImg.value) {
    const img = originalImg.value
    originalDimensions.value = `${img.naturalWidth} × ${img.naturalHeight} pixels`
  }
}

const onProcessedLoad = () => {
  if (processedImg.value) {
    const img = processedImg.value
    processedDimensions.value = `${img.naturalWidth} × ${img.naturalHeight} pixels`
  }
}

const onOriginalError = (event) => {
  originalError.value = true
  console.error('Original image failed to load:', event)
  console.error('Failed URL was:', originalUrl.value)
}

const formatDate = (dateString) => {
  return new Date(dateString).toLocaleString()
}

const formatEventType = (type) => {
  const types = {
    'uploaded': 'Uploaded',
    'queued': 'Queued for Processing',
    'job_completed': 'Processing Completed'
  }
  return types[type] || type
}

const formatProcessingOptions = (options) => {
  if (!options) return 'Default settings'
  
  try {
    const opts = typeof options === 'string' ? JSON.parse(options) : options
    const parts = []
    
    if (opts.method) {
      parts.push(`Method: ${opts.method}`)
    }
    
    if (opts.method === 'mosaic' && opts.mosaic_size) {
      parts.push(`Size: ${opts.mosaic_size}px`)
    }
    
    return parts.length > 0 ? parts.join(', ') : 'Default settings'
  } catch (e) {
    return 'Invalid options'
  }
}

// Cleanup blob URLs to prevent memory leaks
const cleanup = () => {
  cancelRequests()
  blobUrls.value.forEach(url => {
    URL.revokeObjectURL(url)
  })
  blobUrls.value = []
}

onMounted(() => {
  loadImage()
  if (overlay.value) {
    overlay.value.focus()
  }
})
onUnmounted(cleanup)
watch(() => props.imageId, () => {
  cleanup() // Clean up previous blob URLs
  loadImage()
})
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.8);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal {
  background: white;
  border-radius: 12px;
  width: 95vw;
  max-width: 1200px;
  height: 90vh;
  display: flex;
  flex-direction: column;
  box-shadow: 0 10px 30px rgba(0,0,0,0.3);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  border-bottom: 1px solid #eee;
  flex-shrink: 0;
}

.close-btn {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: #666;
  padding: 5px;
  border-radius: 50%;
  transition: background 0.2s;
}

.close-btn:hover {
  background: #f0f0f0;
}

.modal-content {
  padding: 20px;
  overflow-y: auto;
  flex: 1;
}

.image-comparison {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  margin-bottom: 30px;
}

.image-panel h3 {
  margin-bottom: 10px;
  text-align: center;
  color: #333;
  font-size: 18px;
}

.image-container {
  position: relative;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
  background: #f8f9fa;
}

.image-panel img {
  width: 100%;
  height: auto;
  max-height: 400px;
  object-fit: contain;
  display: block;
  image-orientation: from-image;
}

.image-info {
  text-align: center;
  margin-top: 8px;
  font-size: 14px;
  color: #666;
  font-weight: 500;
}

.placeholder {
  width: 100%;
  height: 200px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f5f5f5;
  border-radius: 8px;
  color: #666;
  font-size: 16px;
}

.details h3 {
  margin-bottom: 20px;
  color: #333;
  font-size: 20px;
  border-bottom: 2px solid #e9ecef;
  padding-bottom: 10px;
}

.detail-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 20px;
}

.detail-item {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding: 15px;
  background: #f8f9fa;
  border-radius: 8px;
  border-left: 4px solid #007bff;
}

.label {
  font-weight: 600;
  color: #495057;
  font-size: 14px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.hash, .path {
  font-family: 'Courier New', monospace;
  font-size: 13px;
  background: #e9ecef;
  padding: 4px 8px;
  border-radius: 4px;
  word-break: break-all;
}

.timeline {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.timeline-item {
  display: flex;
  align-items: center;
  gap: 15px;
}

.timeline-marker {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  background: #2196f3;
  flex-shrink: 0;
}

.timeline-content {
  flex: 1;
}

.timeline-type {
  font-weight: 600;
  margin-bottom: 2px;
}

.timeline-time {
  font-size: 14px;
  color: #666;
}

.loading {
  padding: 40px;
  text-align: center;
  color: #666;
}

@media (max-width: 768px) {
  .image-comparison {
    grid-template-columns: 1fr;
    gap: 15px;
  }
  
  .modal {
    width: 98vw;
    height: 95vh;
    margin: 0;
    border-radius: 8px;
  }
  
  .modal-content {
    padding: 15px;
  }
  
  .detail-grid {
    grid-template-columns: 1fr;
    gap: 15px;
  }
  
  .detail-item {
    padding: 12px;
  }
  
  .image-panel img {
    max-height: 250px;
  }
}

@media (max-width: 480px) {
  .modal-header {
    padding: 15px;
  }
  
  .modal-header h2 {
    font-size: 18px;
  }
  
  .close-btn {
    font-size: 20px;
  }
}
</style>
