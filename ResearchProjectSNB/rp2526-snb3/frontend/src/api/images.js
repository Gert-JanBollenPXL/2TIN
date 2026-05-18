import apiClient from './client'

export const imagesApi = {
  list: (params, options = {}) => apiClient.get('/images', { params, ...options }),
  get: (imageId, options = {}) => apiClient.get(`/images/${imageId}`, options),
  delete: (imageId, options = {}) => apiClient.delete(`/images/${imageId}`, options),
  uploadInit: (payload, options = {}) => apiClient.post('/upload-init', payload, options),
  process: (imageId, payload, options = {}) => apiClient.post(`/images/${imageId}/process`, payload, options)
}
