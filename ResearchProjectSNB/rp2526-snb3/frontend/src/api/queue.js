import apiClient from './client'

export const queueApi = {
  stats: (options = {}) => apiClient.get('/queue', options),
  metrics: (options = {}) => apiClient.get('/queue/metrics', options),
  global: (options = {}) => apiClient.get('/queue/global', options)
}
