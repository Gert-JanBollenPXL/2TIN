<template>
  <div class="queue">
    <div class="queue-header">
      <div>
        <h2>Processing Queue</h2>
        <p class="queue-subtitle">Your queue is private; system metrics are global.</p>
      </div>
      <div class="refresh-info">Auto-refreshing every 2 seconds</div>
    </div>
    
    <div class="queue-top">
      <div class="panel">
        <h3 class="panel-title">Your Queue (last 24h)</h3>
        <div class="stats-grid">
          <div class="stat-card">
            <div class="stat-value">{{ stats.queued || 0 }}</div>
            <div class="stat-label">Queued</div>
          </div>
          <div class="stat-card">
            <div class="stat-value">{{ stats.processing || 0 }}</div>
            <div class="stat-label">Processing</div>
          </div>
          <div class="stat-card">
            <div class="stat-value">{{ stats.done || 0 }}</div>
            <div class="stat-label">Completed</div>
          </div>
          <div class="stat-card">
            <div class="stat-value">{{ stats.failed || 0 }}</div>
            <div class="stat-label">Failed</div>
          </div>
        </div>
      </div>

      <div class="panel">
        <div class="panel-header">
          <h3>System Metrics</h3>
          <span class="panel-badge">Global</span>
        </div>
        <div class="stats-grid">
          <div class="stat-card">
            <div class="stat-value">{{ metrics.total_images || 0 }}</div>
            <div class="stat-label">Total Images</div>
          </div>
          <div class="stat-card">
            <div class="stat-value">{{ metrics.processed_images || 0 }}</div>
            <div class="stat-label">Processed</div>
          </div>
          <div class="stat-card">
            <div class="stat-value">{{ metrics.recent_failures || 0 }}</div>
            <div class="stat-label">Recent Failures</div>
          </div>
          <div class="stat-card">
            <div class="stat-value">{{ metrics.queued_jobs || 0 }}</div>
            <div class="stat-label">Queue Depth</div>
          </div>
        </div>
      </div>
    </div>

    <div class="panel global-queues">
      <div class="panel-header">
        <h3>Global Queues (last 24h)</h3>
        <span class="panel-badge">All users</span>
      </div>
      <div v-if="globalQueues.length === 0" class="empty-state">
        No active queues yet.
      </div>
      <div v-else class="queue-table">
        <div class="queue-row queue-head">
          <span>User</span>
          <span>Queued</span>
          <span>Processing</span>
          <span>Done</span>
          <span>Failed</span>
          <span>Total (24h)</span>
        </div>
        <div v-for="queue in globalQueues" :key="queue.user_id" class="queue-row">
          <span class="queue-user">{{ queue.user_id }}</span>
          <span>{{ queue.queued || 0 }}</span>
          <span>{{ queue.processing || 0 }}</span>
          <span>{{ queue.done || 0 }}</span>
          <span>{{ queue.failed || 0 }}</span>
          <span>{{ queue.total_24h || 0 }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { queueApi } from '@/api/queue'

const stats = ref({})
const metrics = ref({})
const globalQueues = ref([])
let refreshInterval = null
let loadController = null

const loadQueueStats = async () => {
  try {
    if (loadController) {
      loadController.abort()
    }
    loadController = new AbortController()
    const [queueResponse, metricsResponse, globalResponse] = await Promise.all([
      queueApi.stats({ signal: loadController.signal }),
      queueApi.metrics({ signal: loadController.signal }),
      queueApi.global({ signal: loadController.signal })
    ])
    
    // Convert stats array to object
    const statsObj = {}
    queueResponse.data.stats.forEach(item => {
      statsObj[item.status] = item.count
    })
    stats.value = statsObj
    
    metrics.value = metricsResponse.data
    globalQueues.value = globalResponse.data.users || []
  } catch (err) {
    if (err?.name !== 'CanceledError' && err?.code !== 'ERR_CANCELED') {
      console.error('Failed to load queue stats:', err)
    }
  }
}

onMounted(() => {
  loadQueueStats()
  refreshInterval = setInterval(loadQueueStats, 2000)
})

onUnmounted(() => {
  if (refreshInterval) {
    clearInterval(refreshInterval)
  }
  if (loadController) {
    loadController.abort()
  }
})
</script>

<style scoped>
.queue {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem 0;
}

.queue-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
  margin-bottom: 2rem;
}

.queue-subtitle {
  margin-top: 0.4rem;
  color: var(--color-muted);
  font-size: 0.95rem;
}

.queue-top {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 1.5rem;
}

.panel {
  background: var(--color-card);
  padding: 1.5rem 1.75rem;
  border-radius: 18px;
  border: 1px solid rgba(28, 27, 26, 0.08);
  box-shadow: 0 12px 28px rgba(30, 30, 30, 0.08);
}

.panel-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 1rem;
}

.panel-title {
  margin-bottom: 1rem;
}

.panel-badge {
  padding: 0.2rem 0.6rem;
  border-radius: 999px;
  background: rgba(47, 111, 109, 0.12);
  color: var(--color-accent-strong);
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.06em;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
  gap: 1rem;
}

.stat-card {
  text-align: center;
  padding: 1rem;
  border-radius: 14px;
  background: rgba(47, 111, 109, 0.08);
}

.stat-value {
  font-size: 2rem;
  font-weight: 700;
  color: var(--color-ink);
}

.stat-label {
  font-size: 0.8rem;
  color: var(--color-muted);
  text-transform: uppercase;
  margin-top: 0.35rem;
  letter-spacing: 0.08em;
}


.refresh-info {
  text-align: right;
  color: var(--color-muted);
  font-size: 0.875rem;
}

.global-queues {
  margin-top: 2rem;
}

.queue-table {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
}

.queue-row {
  display: grid;
  grid-template-columns: minmax(120px, 1.2fr) repeat(5, minmax(80px, 1fr));
  gap: 0.75rem;
  align-items: center;
  padding: 0.75rem 0.5rem;
  border-radius: 10px;
}

.queue-head {
  font-size: 0.75rem;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: var(--color-muted);
  border-bottom: 1px solid rgba(28, 27, 26, 0.08);
}

.queue-row:not(.queue-head) {
  background: rgba(28, 27, 26, 0.03);
}

.queue-user {
  font-weight: 600;
  color: var(--color-ink);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.empty-state {
  text-align: center;
  color: var(--color-muted);
  padding: 1.5rem 0;
}
</style>
