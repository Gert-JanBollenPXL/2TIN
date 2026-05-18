<template>
  <div class="upload-container">
    <div class="upload-hero">
      <span class="hero-badge">Local-first privacy</span>
      <h2>Face anonymization without the fuss.</h2>
      <p>Drop a photo, pick a method, and let the processor handle the rest.</p>
    </div>
    <div class="mode-toggle">
      <label class="toggle">
        <input
          type="checkbox"
          v-model="batchMode"
          :disabled="batchRunning"
          @change="handleModeChange"
        />
        <span>Batch mode</span>
      </label>
      <span class="mode-hint">Up to 50 images, sequential uploads, manual start.</span>
    </div>
    <div 
      class="dropzone" 
      :class="{ 'dragging': isDragging }"
      @drop="handleDrop"
      @dragover.prevent="isDragging = true"
      @dragleave.prevent="isDragging = false"
    >
      <input 
        type="file" 
        ref="fileInput" 
        @change="handleFileSelect"
        accept="image/jpeg,image/jpg,image/png,image/webp"
        :multiple="batchMode"
        style="display: none"
      />
      
      <div v-if="batchMode" class="dropzone-content" @click="$refs.fileInput.click()">
        <div class="upload-icon">📦</div>
        <h2 v-if="batchQueue.length === 0">Drop up to 50 images or click to browse</h2>
        <h2 v-else>{{ batchQueue.length }} file(s) queued</h2>
        <p>Supports JPG, PNG, WebP up to 25MB</p>
        <span class="dropzone-cta">{{ batchQueue.length ? 'Add more files' : 'Select files' }}</span>
      </div>

      <div v-else-if="!file" class="dropzone-content" @click="$refs.fileInput.click()">
        <div class="upload-icon">📸</div>
        <h2>Drop image here or click to browse</h2>
        <p>Supports JPG, PNG, WebP up to 25MB</p>
      </div>

      <div v-else class="preview-container">
        <img :src="preview" alt="Preview" />
        <div class="file-info">
          <h3 :title="file.name">{{ displayFileName }}</h3>
          <p>{{ formatBytes(file.size) }}</p>
        </div>
      </div>
    </div>

    <!-- UNIFIED STATUS BOX - ONE BOX FOR EVERYTHING -->
    <div v-if="status && !batchMode" class="unified-status" :class="status">
      <div class="status-content">
        <div class="status-message">{{ statusMessage }}</div>
        <div v-if="progress && status !== 'success' && status !== 'error'" class="progress-container">
          <div class="progress-bar" :style="{ width: progress + '%' }"></div>
          <span class="progress-text">{{ progressText }}</span>
        </div>
        <div v-if="error && status === 'error'" class="error-message">{{ error }}</div>
      </div>
    </div>

    <div v-if="file || batchMode" class="processing-options">
      <h3>Processing Options</h3>
      
      <div class="option-group">
        <label for="method">Anonymization Method:</label>
        <select id="method" v-model="processingOptions.method">
          <option value="mosaic">Mosaic (Default)</option>
          <option value="blur">Blur</option>
          <option value="solid">Solid Black Box</option>
        </select>
      </div>

      <div v-if="processingOptions.method === 'mosaic'" class="option-group">
        <label for="mosaicSize">Mosaic Size:</label>
        <input 
          type="range" 
          id="mosaicSize" 
          v-model.number="processingOptions.mosaic_size" 
          min="5" 
          max="120" 
          step="5"
        />
        <span>{{ processingOptions.mosaic_size }}px</span>
        <small class="hint">Auto-calculated based on image size</small>
      </div>
    </div>

    <div v-if="file && !batchMode" class="actions">
      <button class="btn btn-secondary" @click="reset">Change Image</button>
      <button class="btn" @click="upload" :disabled="uploading">
        {{ uploading ? 'Uploading...' : 'Upload & Process' }}
      </button>
    </div>

    <div v-if="batchMode" class="batch-actions">
      <button class="btn" @click="startBatch" :disabled="!hasPending || batchRunning">
        {{ batchRunning ? 'Uploading...' : 'Start Uploads' }}
      </button>
      <button class="btn btn-secondary" @click="cancelBatch" :disabled="!hasPending && !batchRunning">
        Cancel Queue
      </button>
      <button class="btn btn-secondary" @click="clearCompleted" :disabled="!hasCompleted">
        Clear Completed
      </button>
    </div>

    <div v-if="batchMode && batchQueue.length > 0" class="batch-summary">
      <span>{{ batchCounts.pending }} pending</span>
      <span>{{ batchCounts.uploading }} uploading</span>
      <span>{{ batchCounts.success }} done</span>
      <span>{{ batchCounts.error }} failed</span>
      <span>{{ batchCounts.canceled }} canceled</span>
    </div>

    <div v-if="batchMode && batchError" class="batch-error">{{ batchError }}</div>

    <div v-if="batchMode && batchQueue.length > 0" class="batch-queue">
      <div v-for="item in batchQueue" :key="item.id" class="batch-row">
        <div class="batch-file">
          <span class="batch-name" :title="item.file.name">{{ truncateFileName(item.file.name, 48) }}</span>
          <span class="batch-size">{{ formatBytes(item.file.size) }}</span>
        </div>
        <div class="batch-status" :class="`status-${item.status}`">
          <span class="batch-status-text">{{ item.message || formatBatchStatus(item.status) }}</span>
          <div v-if="item.status === 'uploading'" class="batch-progress">
            <div class="batch-progress-bar" :style="{ width: item.progress + '%' }"></div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import axios from 'axios'
import { imagesApi } from '@/api/images'
import { formatBytes } from '@/utils/format'

const emit = defineEmits(['uploaded'])

const MAX_BATCH_FILES = 50

const isDragging = ref(false)
const file = ref(null)
const preview = ref(null)
const uploading = ref(false)
const progress = ref(0)
const progressText = ref('')
const error = ref(null)
const status = ref(null)
const statusMessage = ref('')
const fileInput = ref(null)
const batchMode = ref(false)
const batchQueue = ref([])
const batchRunning = ref(false)
const batchCancelRequested = ref(false)
const batchError = ref(null)

// Processing options with defaults
const processingOptions = ref({
  method: 'mosaic',
  mosaic_size: 20
})

const batchCounts = computed(() => {
  const counts = {
    total: batchQueue.value.length,
    pending: 0,
    uploading: 0,
    success: 0,
    error: 0,
    canceled: 0
  }
  batchQueue.value.forEach((item) => {
    if (counts[item.status] !== undefined) {
      counts[item.status] += 1
    }
  })
  return counts
})

const hasPending = computed(() => batchCounts.value.pending > 0)
const hasCompleted = computed(() => (
  batchCounts.value.success + batchCounts.value.error + batchCounts.value.canceled > 0
))

// Calculate smart mosaic size based on image dimensions and file size
const calculateSmartMosaicSize = async (file) => {
  return new Promise((resolve) => {
    const img = new Image()
    const objectUrl = URL.createObjectURL(file)
    img.onload = () => {
      URL.revokeObjectURL(objectUrl)
      // Calculate actual megapixels from image dimensions
      const megapixels = (img.width * img.height) / (1024 * 1024)
      
      let mosaicSize
      if (megapixels < 1) {
        mosaicSize = 15  // Small images (<1MP) - 15px
      } else if (megapixels < 4) {
        mosaicSize = 25  // Medium images (1-4MP) - 25px  
      } else if (megapixels < 8) {
        mosaicSize = 40  // Large images (4-8MP) - 40px
      } else if (megapixels < 16) {
        mosaicSize = 60  // Very large images (8-16MP) - 60px
      } else if (megapixels < 32) {
        mosaicSize = 80  // Ultra high-res images (16-32MP) - 80px
      } else {
        mosaicSize = 100 // Extremely high-res images (>32MP) - 100px
      }
      
      resolve(mosaicSize)
    }
    img.onerror = () => {
      URL.revokeObjectURL(objectUrl)
      // Fallback to file size estimation if image loading fails
      const estimatedMegapixels = file.size / (300 * 1024)
      if (estimatedMegapixels < 1) resolve(15)
      else if (estimatedMegapixels < 4) resolve(25) 
      else if (estimatedMegapixels < 8) resolve(40)
      else if (estimatedMegapixels < 16) resolve(60)
      else if (estimatedMegapixels < 32) resolve(80)
      else resolve(100)
    }
    img.src = objectUrl
  })
}

const handleDrop = (e) => {
  e.preventDefault()
  isDragging.value = false
  
  const files = Array.from(e.dataTransfer.files || [])
  if (files.length === 0) {
    return
  }
  if (batchMode.value) {
    addFiles(files)
    return
  }
  selectFile(files[0])
}

const handleFileSelect = (e) => {
  const files = Array.from(e.target.files || [])
  if (files.length === 0) {
    return
  }
  if (batchMode.value) {
    addFiles(files)
  } else {
    selectFile(files[0])
  }
  if (fileInput.value) {
    fileInput.value.value = ''
  }
}

const selectFile = async (selectedFile) => {
  if (batchMode.value) {
    addFiles([selectedFile])
    return
  }
  // Validate file type
  const validTypes = ['image/jpeg', 'image/png', 'image/webp']
  if (!validTypes.includes(selectedFile.type)) {
    error.value = 'Invalid file type. Please select a JPG, PNG, or WebP image.'
    return
  }

  // Validate file size (25MB)
  if (selectedFile.size > 25 * 1024 * 1024) {
    error.value = 'File too large. Maximum size is 25MB.'
    return
  }

  error.value = null
  file.value = selectedFile
  
  // Calculate smart mosaic size based on actual image dimensions
  const smartMosaicSize = await calculateSmartMosaicSize(selectedFile)
  
  processingOptions.value.mosaic_size = smartMosaicSize
  
  // Create preview
  const reader = new FileReader()
  reader.onload = (e) => {
    preview.value = e.target.result
  }
  reader.readAsDataURL(selectedFile)
}

const addFiles = (files) => {
  const validTypes = ['image/jpeg', 'image/png', 'image/webp']
  const errors = []
  const nextItems = []
  let remainingSlots = MAX_BATCH_FILES - batchQueue.value.length

  files.forEach((selectedFile) => {
    if (remainingSlots <= 0) {
      return
    }
    if (!validTypes.includes(selectedFile.type)) {
      errors.push(`Skipped ${selectedFile.name}: invalid file type.`)
      return
    }
    if (selectedFile.size > 25 * 1024 * 1024) {
      errors.push(`Skipped ${selectedFile.name}: file too large.`)
      return
    }
    nextItems.push({
      id: makeBatchId(),
      file: selectedFile,
      status: 'pending',
      progress: 0,
      message: ''
    })
    remainingSlots -= 1
  })

  if (files.length > nextItems.length && remainingSlots <= 0) {
    errors.push(`Batch limit reached (${MAX_BATCH_FILES} files).`)
  }

  if (nextItems.length > 0) {
    batchQueue.value = [...batchQueue.value, ...nextItems]
  }

  batchError.value = errors.length > 0 ? errors.slice(0, 2).join(' ') : null
}

const makeBatchId = () => {
  if (typeof crypto !== 'undefined' && crypto.randomUUID) {
    return crypto.randomUUID()
  }
  return `batch-${Date.now()}-${Math.random().toString(16).slice(2)}`
}

const formatBatchStatus = (statusValue) => {
  const labels = {
    pending: 'Pending',
    uploading: 'Uploading',
    success: 'Queued for processing',
    error: 'Failed',
    canceled: 'Canceled'
  }
  return labels[statusValue] || statusValue
}

const updateBatchItem = (id, updates) => {
  const index = batchQueue.value.findIndex((item) => item.id === id)
  if (index === -1) {
    return
  }
  batchQueue.value[index] = {
    ...batchQueue.value[index],
    ...updates
  }
}

const handleModeChange = () => {
  if (batchMode.value) {
    resetSingleState(true)
  } else {
    resetBatchState()
  }
}

const calculateSHA256 = async (file) => {
  const buffer = await file.arrayBuffer()
  const hashBuffer = await crypto.subtle.digest('SHA-256', buffer)
  const hashArray = Array.from(new Uint8Array(hashBuffer))
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('')
}

const upload = async () => {
  if (!file.value) {
    setStatus('error', 'No file selected')
    return
  }
  
  uploading.value = true
  setStatus('uploading', 'Starting upload...')
  progress.value = 0
  
  try {
    // Step 1: Calculate SHA256
    setStatus('uploading', 'Calculating file hash...', 10)
    const sha256 = await calculateSHA256(file.value)
    
    // Step 2: Initialize upload
    setStatus('uploading', 'Initializing upload...', 20)
    const initResponse = await imagesApi.uploadInit({
      filename: file.value.name,
      mime: file.value.type,
      bytes: file.value.size,
      sha256: sha256,
      processing_options: processingOptions.value
    })
    
    const { image_id, upload_url, upload_headers, duplicate, status, processed_path } = initResponse.data
    
    if (duplicate) {
      if (status === 'complete' && processed_path) {
        // Image already processed
        setStatus('success', 'Image already processed!', 100)
        emit('uploaded', image_id)
        setTimeout(() => {
          reset()
        }, 2000)
        return
      } else {
        // Image exists but not yet processed
        setStatus('uploading', 'Image already exists, processing...', 50)
      }
    } else {
      // Step 3: Upload file
      setStatus('uploading', 'Uploading image...', 30)
      
      await axios.put(upload_url, file.value, {
        headers: {
          ...upload_headers,
          'Content-Type': 'application/octet-stream'
        },
        onUploadProgress: (e) => {
          if (e.lengthComputable) {
            const uploadProgress = 30 + (e.loaded / e.total) * 40
            setStatus('uploading', 'Uploading image...', uploadProgress)
          }
        }
      })
    }
    
    // Step 4: Trigger processing
    setStatus('uploading', 'Starting face anonymization...', 80)
    
    await imagesApi.process(image_id, {
      pipeline: 'deface_boxes'
    })
    
    // Step 5: Complete - SUCCESSFUL UPLOAD!
    setStatus('success', 'Success', 100)
    emit('uploaded', image_id)
    
    // Show success for 1 second, then reset
    setTimeout(() => {
      reset()
    }, 1000)
    
  } catch (err) {
    console.error('Upload failed:', err)
    console.error('Error response:', err.response)
    
    const { message, details } = getUploadErrorDetails(err)
    setStatus('error', message, 100, details)
    
    // Show error for 3 seconds, then reset
    setTimeout(() => {
      reset()
    }, 3000)
  }
  
  uploading.value = false
}

const getUploadErrorDetails = (err) => {
  if (err.response?.status === 409) {
    return { message: 'Already Processed', details: null }
  }
  if (err.response?.data?.message) {
    return { message: 'Upload Failed', details: err.response.data.message }
  }
  if (err.response?.data?.error) {
    return { message: 'Upload Failed', details: err.response.data.error }
  }
  return { message: 'Upload Failed', details: err.message || 'Unknown error' }
}

// Helper function to set unified status
const setStatus = (type, message, progressValue = null, errorDetails = null) => {
  status.value = type
  statusMessage.value = message
  if (progressValue !== null) {
    progress.value = progressValue
  }
  if (type === 'uploading' && progressValue) {
    progressText.value = `${Math.round(progressValue)}%`
  } else {
    progressText.value = ''
  }
  error.value = errorDetails
}

const reset = () => {
  resetSingleState(false)
}

const resetSingleState = (keepOptions) => {
  file.value = null
  preview.value = null
  uploading.value = false
  progress.value = 0
  progressText.value = ''
  error.value = null
  status.value = null
  statusMessage.value = ''
  
  // Reset processing options to defaults
  if (!keepOptions) {
    processingOptions.value = {
      method: 'mosaic',
      mosaic_size: 20
    }
  }
  
  if (fileInput.value) {
    fileInput.value.value = ''
  }
}

const resetBatchState = () => {
  batchQueue.value = []
  batchRunning.value = false
  batchCancelRequested.value = false
  batchError.value = null
}

const startBatch = async () => {
  if (batchRunning.value || batchQueue.value.length === 0) {
    return
  }
  batchRunning.value = true
  batchCancelRequested.value = false
  batchError.value = null

  for (const item of batchQueue.value) {
    if (item.status !== 'pending') {
      continue
    }
    if (batchCancelRequested.value) {
      updateBatchItem(item.id, { status: 'canceled', message: 'Canceled' })
      continue
    }
    await uploadBatchItem(item)
  }

  batchRunning.value = false
}

const cancelBatch = () => {
  if (batchQueue.value.length === 0) {
    return
  }
  batchCancelRequested.value = true
  batchQueue.value = batchQueue.value.map((item) => {
    if (item.status === 'pending') {
      return { ...item, status: 'canceled', message: 'Canceled' }
    }
    return item
  })
}

const clearCompleted = () => {
  batchQueue.value = batchQueue.value.filter((item) => (
    item.status === 'pending' || item.status === 'uploading'
  ))
}

const uploadBatchItem = async (item) => {
  updateBatchItem(item.id, {
    status: 'uploading',
    message: 'Calculating hash...',
    progress: 5
  })

  try {
    const sha256 = await calculateSHA256(item.file)
    updateBatchItem(item.id, {
      message: 'Initializing upload...',
      progress: 15
    })

    const initResponse = await imagesApi.uploadInit({
      filename: item.file.name,
      mime: item.file.type,
      bytes: item.file.size,
      sha256: sha256,
      processing_options: processingOptions.value
    })

    const { image_id, upload_url, upload_headers, duplicate, status, processed_path } = initResponse.data

    if (duplicate) {
      if (status === 'complete' && processed_path) {
        updateBatchItem(item.id, {
          status: 'success',
          message: 'Already processed',
          progress: 100
        })
        emit('uploaded', image_id)
        return
      }
      updateBatchItem(item.id, {
        message: 'Already uploaded, processing...',
        progress: 55
      })
    } else {
      updateBatchItem(item.id, {
        message: 'Uploading image...',
        progress: 30
      })

      await axios.put(upload_url, item.file, {
        headers: {
          ...upload_headers,
          'Content-Type': 'application/octet-stream'
        },
        onUploadProgress: (e) => {
          if (e.lengthComputable) {
            const uploadProgress = 30 + (e.loaded / e.total) * 40
            updateBatchItem(item.id, {
              progress: Math.round(uploadProgress),
              message: 'Uploading image...'
            })
          }
        }
      })
    }

    updateBatchItem(item.id, {
      message: 'Starting face anonymization...',
      progress: 80
    })

    await imagesApi.process(image_id, {
      pipeline: 'deface_boxes'
    })

    updateBatchItem(item.id, {
      status: 'success',
      message: 'Queued for processing',
      progress: 100
    })
    emit('uploaded', image_id)
  } catch (err) {
    const { message, details } = getUploadErrorDetails(err)
    updateBatchItem(item.id, {
      status: 'error',
      message: details ? `${message}: ${details}` : message,
      progress: 100
    })
  }
}

const truncateFileName = (name, maxLength = 42) => {
  if (name.length <= maxLength) return name
  const start = name.slice(0, Math.max(20, maxLength - 16))
  const end = name.slice(-12)
  return `${start}...${end}`
}

const displayFileName = computed(() => {
  if (!file.value?.name) return ''
  return truncateFileName(file.value.name)
})
</script>

<style scoped>
.upload-container {
  max-width: 600px;
  margin: 0 auto;
}

.upload-hero {
  text-align: center;
  margin-bottom: 2rem;
}

.upload-hero h2 {
  font-size: 2rem;
  margin: 0.5rem 0 0.75rem;
}

.upload-hero p {
  color: var(--color-muted);
  font-size: 1rem;
}

.hero-badge {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  padding: 0.25rem 0.75rem;
  border-radius: 999px;
  background: rgba(47, 111, 109, 0.12);
  color: var(--color-accent-strong);
  font-weight: 600;
  font-size: 0.8rem;
  text-transform: uppercase;
  letter-spacing: 0.08em;
}

.mode-toggle {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem 1rem;
  align-items: center;
  justify-content: center;
  margin-bottom: 1.5rem;
}

.toggle {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 600;
  color: var(--color-ink);
}

.toggle input {
  width: 18px;
  height: 18px;
}

.mode-hint {
  color: var(--color-muted);
  font-size: 0.9rem;
}

.dropzone {
  border: 2px dashed rgba(47, 111, 109, 0.35);
  border-radius: 16px;
  padding: 3rem;
  text-align: center;
  transition: all 0.3s;
  background: var(--color-card);
  box-shadow: 0 12px 30px rgba(30, 30, 30, 0.08);
}

.dropzone.dragging {
  border-color: var(--color-accent);
  background: rgba(47, 111, 109, 0.08);
}

.dropzone-content {
  cursor: pointer;
}

.dropzone-cta {
  display: inline-flex;
  margin-top: 0.75rem;
  padding: 0.25rem 0.75rem;
  border-radius: 999px;
  background: rgba(47, 111, 109, 0.1);
  color: var(--color-accent-strong);
  font-weight: 600;
  font-size: 0.85rem;
}

.upload-icon {
  font-size: 4rem;
  margin-bottom: 1rem;
}

.preview-container {
  display: flex;
  align-items: center;
  gap: 2rem;
}

.preview-container img {
  width: 200px;
  height: 200px;
  object-fit: cover;
  border-radius: 12px;
  image-orientation: from-image;
}

.file-info {
  text-align: left;
}

.processing-options {
  margin: 2rem 0;
  padding: 1.5rem;
  background: rgba(255, 255, 255, 0.85);
  border-radius: 16px;
  border: 1px solid rgba(28, 27, 26, 0.08);
}

.processing-options h3 {
  margin: 0 0 1rem 0;
  color: var(--color-ink);
  font-size: 1.1rem;
}

.option-group {
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.option-group label {
  font-weight: 500;
  color: var(--color-muted);
  min-width: 140px;
}

.option-group select {
  padding: 0.5rem;
  border: 1px solid rgba(28, 27, 26, 0.15);
  border-radius: 8px;
  background: white;
  min-width: 180px;
}

.option-group input[type="range"] {
  flex: 1;
  margin: 0 0.5rem;
}

.option-group input[type="checkbox"] {
  margin-right: 0.5rem;
}

.option-group span {
  min-width: 50px;
  font-weight: 500;
  color: var(--color-ink);
}

.actions {
  margin-top: 2rem;
  display: flex;
  gap: 1rem;
  justify-content: center;
}

.batch-actions {
  margin-top: 1.5rem;
  display: flex;
  gap: 1rem;
  justify-content: center;
  flex-wrap: wrap;
}

.batch-summary {
  margin-top: 1rem;
  display: flex;
  gap: 0.75rem;
  justify-content: center;
  flex-wrap: wrap;
  color: var(--color-muted);
  font-size: 0.9rem;
}

.batch-error {
  margin-top: 1rem;
  text-align: center;
  color: #7a1f2a;
  background: #ffe2e2;
  border: 1px solid rgba(214, 69, 69, 0.4);
  padding: 0.75rem 1rem;
  border-radius: 10px;
}

.batch-queue {
  margin-top: 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.batch-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  padding: 0.85rem 1rem;
  border-radius: 12px;
  background: var(--color-card);
  border: 1px solid rgba(28, 27, 26, 0.08);
}

.batch-file {
  display: flex;
  flex-direction: column;
  gap: 0.2rem;
  min-width: 0;
}

.batch-name {
  font-weight: 600;
  color: var(--color-ink);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 260px;
}

.batch-size {
  color: var(--color-muted);
  font-size: 0.85rem;
}

.batch-status {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
  align-items: flex-end;
  min-width: 180px;
}

.batch-status-text {
  font-size: 0.9rem;
  font-weight: 600;
}

.status-pending .batch-status-text {
  color: var(--color-muted);
}

.status-uploading .batch-status-text {
  color: var(--color-accent-strong);
}

.status-success .batch-status-text {
  color: #1d5b3a;
}

.status-error .batch-status-text {
  color: #7a1f2a;
}

.status-canceled .batch-status-text {
  color: #7a6f5a;
}

.batch-progress {
  width: 160px;
  height: 6px;
  background: rgba(47, 111, 109, 0.15);
  border-radius: 999px;
  overflow: hidden;
}

.batch-progress-bar {
  height: 100%;
  background: linear-gradient(90deg, #2f6f6d, #4aa6a1);
  transition: width 0.2s ease;
}

.progress {
  margin-top: 2rem;
  background: #f0f0f0;
  border-radius: 4px;
  overflow: hidden;
  position: relative;
  height: 40px;
}

.progress-bar {
  background: #333;
  height: 100%;
  transition: width 0.3s;
}

.progress span {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  color: #333;
  font-weight: 500;
}

.progress-bar.success {
  background: linear-gradient(90deg, #4caf50, #66bb6a);
}

.progress-bar.error {
  background: linear-gradient(90deg, #f44336, #ef5350);
}

.error {
  margin-top: 1rem;
  padding: 1rem;
  background: #ffebee;
  color: #c62828;
  border-radius: 4px;
}

/* UNIFIED STATUS BOX - ONE BOX FOR ALL STATUS */
.unified-status {
  position: fixed;
  top: 20px;
  left: 50%;
  transform: translateX(-50%);
  z-index: 1000;
  min-width: 400px;
  max-width: 500px;
  padding: 1.5rem;
  border-radius: 16px;
  font-weight: 600;
  text-align: center;
  box-shadow: 0 6px 20px rgba(0,0,0,0.2);
  backdrop-filter: blur(10px);
}

.unified-status.uploading {
  background: linear-gradient(135deg, #f8fafc, #edf2f7);
  color: #3f4a4a;
  border: 2px solid rgba(47, 111, 109, 0.35);
}

.unified-status.success {
  background: linear-gradient(135deg, #d8f5e5, #c3ecd7);
  color: #1d5b3a;
  border: 2px solid #2f7d5d;
}

.unified-status.error {
  background: linear-gradient(135deg, #ffe2e2, #f9caca);
  color: #7a1f2a;
  border: 2px solid #d64545;
}

.status-content {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.status-message {
  font-size: 1.2rem;
  font-weight: 700;
}

.progress-container {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.progress-bar {
  background: #28a745;
  height: 8px;
  border-radius: 4px;
  transition: width 0.3s ease;
}

.progress-text {
  font-size: 0.9rem;
  opacity: 0.8;
}

.error-message {
  background: rgba(255,255,255,0.7);
  padding: 0.75rem;
  border-radius: 6px;
  font-size: 0.95rem;
  color: #721c24;
  border: 1px solid rgba(220,53,69,0.3);
}

.hint {
  display: block;
  color: var(--color-muted);
  font-size: 0.85rem;
  margin-top: 0.25rem;
  font-style: italic;
}
</style>
