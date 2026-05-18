import { createRouter, createWebHistory } from 'vue-router'
import Upload from '@/components/Upload.vue'
import Gallery from '@/components/Gallery.vue'
import Queue from '@/components/Queue.vue'

const routes = [
  { path: '/', redirect: '/upload' },
  { path: '/upload', name: 'upload', component: Upload },
  { path: '/gallery', name: 'gallery', component: Gallery },
  { path: '/queue', name: 'queue', component: Queue }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
