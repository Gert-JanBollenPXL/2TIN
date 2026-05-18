import { describe, it, expect, vi, beforeEach } from 'vitest'
import { flushPromises, mount } from '@vue/test-utils'
import Upload from '../Upload.vue'
import axios from 'axios'
import { imagesApi } from '@/api/images'

vi.mock('axios')
vi.mock('@/api/images', () => ({
  imagesApi: {
    uploadInit: vi.fn(),
    process: vi.fn()
  }
}))

// Mock URL.createObjectURL
global.URL.createObjectURL = vi.fn(() => 'blob:mock-url')
global.URL.revokeObjectURL = vi.fn()

// Mock Image loading for calculateSmartMosaicSize
global.Image = class {
  constructor() {
    this._onload = null
    this._src = ''
  }
  set onload(fn) { this._onload = fn }
  get onload() { return this._onload }
  set src(val) {
    this._src = val
    if (this._onload) {
       setTimeout(() => this._onload(), 10)
    }
  }
}

// Mock crypto.subtle for SHA256
const mockDigest = vi.fn().mockResolvedValue(new Uint8Array([1, 2, 3]).buffer)
Object.defineProperty(global, 'crypto', {
  value: {
    subtle: {
      digest: mockDigest
    }
  }
})

describe('Upload Component', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('renders dropzone initially', () => {
    const wrapper = mount(Upload)
    expect(wrapper.text()).toContain('Drop image here')
    wrapper.unmount()
  })

  it('calculates SHA256 and calls API on upload', async () => {
    const wrapper = mount(Upload)
    
    // 1. Simulate file selection
    const file = new File(['dummy content'], 'test.png', { type: 'image/png' })
    // Mock arrayBuffer since jsdom File might not implement it fully or correctly for tests
    file.arrayBuffer = vi.fn().mockResolvedValue(new Uint8Array([1, 2, 3]).buffer)
    
    // Simulate selecting file
    await wrapper.vm.selectFile(file)
    await wrapper.vm.$nextTick()
    
    expect(wrapper.text()).toContain('test.png') 
    
    // 2. Click Upload
    imagesApi.uploadInit.mockResolvedValueOnce({
      data: {
        image_id: 'img-123',
        upload_url: '/upload/img-123',
        upload_headers: {},
        duplicate: false
      }
    })

    axios.put.mockResolvedValueOnce({ status: 200 })
    
    imagesApi.process.mockResolvedValueOnce({ data: { job_id: 'job-1' } }) 
    
    // Find the Upload button (it's the second button in .actions)
    const buttons = wrapper.findAll('.actions .btn')
    await buttons[1].trigger('click')
    
    await flushPromises()

    // 3. Verify API flow
    expect(imagesApi.uploadInit).toHaveBeenCalledWith(expect.objectContaining({
      filename: 'test.png'
    }))
    
    expect(axios.put).toHaveBeenCalled()
    expect(imagesApi.process).toHaveBeenCalledWith('img-123', expect.anything())
    wrapper.unmount()
  })

  it('queues files in batch mode', async () => {
    const wrapper = mount(Upload)
    const batchToggle = wrapper.find('.mode-toggle input[type="checkbox"]')
    await batchToggle.setValue(true)

    const fileA = new File(['a'], 'a.png', { type: 'image/png' })
    const fileB = new File(['b'], 'b.png', { type: 'image/png' })
    wrapper.vm.addFiles([fileA, fileB])
    await wrapper.vm.$nextTick()

    expect(wrapper.text()).toContain('Start Uploads')
    expect(wrapper.vm.batchQueue.length).toBe(2)
    wrapper.unmount()
  })
})
