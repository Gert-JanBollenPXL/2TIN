import { describe, it, expect } from 'vitest'
import { flushPromises, mount } from '@vue/test-utils'
import { createRouter, createMemoryHistory } from 'vue-router'
import App from '@/App.vue'

const UploadStub = {
  template: '<button class="emit-uploaded" @click="$emit(\'uploaded\')">Uploaded</button>'
}

const GalleryStub = {
  template: '<button class="emit-select" @click="$emit(\'select\', \'img-1\')">Select</button>'
}

const QueueStub = {
  template: '<div class="queue-stub">Queue</div>'
}

const ImageDetailStub = {
  name: 'ImageDetail',
  template: '<div class="image-detail-stub">Detail</div>'
}

const createTestRouter = () => createRouter({
  history: createMemoryHistory(),
  routes: [
    { path: '/', redirect: '/upload' },
    { path: '/upload', name: 'upload', component: UploadStub },
    { path: '/gallery', name: 'gallery', component: GalleryStub },
    { path: '/queue', name: 'queue', component: QueueStub }
  ]
})

describe('App', () => {
  it('redirects to upload by default', async () => {
    const router = createTestRouter()
    router.push('/')
    await router.isReady()

    const wrapper = mount(App, {
      global: {
        plugins: [router],
        stubs: { ImageDetail: ImageDetailStub }
      }
    })

    expect(router.currentRoute.value.name).toBe('upload')
    expect(wrapper.find('.nav-link.active').text()).toBe('Upload')
    wrapper.unmount()
  })

  it('navigates to gallery on upload event', async () => {
    const router = createTestRouter()
    router.push('/upload')
    await router.isReady()

    const wrapper = mount(App, {
      global: {
        plugins: [router],
        stubs: { ImageDetail: ImageDetailStub }
      }
    })

    await wrapper.find('.emit-uploaded').trigger('click')
    await flushPromises()

    expect(router.currentRoute.value.name).toBe('gallery')
    wrapper.unmount()
  })

  it('opens image detail when gallery emits select', async () => {
    const router = createTestRouter()
    router.push('/gallery')
    await router.isReady()

    const wrapper = mount(App, {
      global: {
        plugins: [router],
        stubs: { ImageDetail: ImageDetailStub }
      }
    })

    await wrapper.find('.emit-select').trigger('click')
    await flushPromises()

    expect(wrapper.find('.image-detail-stub').exists()).toBe(true)
    wrapper.unmount()
  })
})
