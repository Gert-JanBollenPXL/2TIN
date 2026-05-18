import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { flushPromises, mount } from '@vue/test-utils'
import Gallery from '../Gallery.vue'
import { imagesApi } from '@/api/images'

vi.mock('@/api/images', () => ({
  imagesApi: {
    list: vi.fn(),
    delete: vi.fn()
  }
}))

describe('Gallery Component', () => {
  let originalHidden

  beforeEach(() => {
    vi.clearAllMocks()
    originalHidden = Object.getOwnPropertyDescriptor(document, 'hidden')
  })

  afterEach(() => {
    if (originalHidden) {
      Object.defineProperty(document, 'hidden', originalHidden)
    }
  })

  it('renders loading state initially', async () => {
    // Return a promise that doesn't resolve immediately
    imagesApi.list.mockImplementation(() => new Promise(() => {}))
    
    const wrapper = mount(Gallery)
    // Wait for mounting
    await wrapper.vm.$nextTick()
    
    expect(wrapper.text()).toContain('Loading images...')
    wrapper.unmount()
  })

  it('renders empty state when no images', async () => {
    imagesApi.list.mockResolvedValue({ data: { images: [], page: 1, pageSize: 20, totalPages: 1 } })
    
    const wrapper = mount(Gallery)
    
    // Wait for mounted hook
    await wrapper.vm.$nextTick()
    await flushPromises()
    
    expect(wrapper.text()).toContain('No images found')
    wrapper.unmount()
  })

  it('renders images from API', async () => {
    const mockImages = [
      { id: '1', status: 'done', processed_url: '/img1.jpg', created_at: new Date().toISOString() },
      { id: '2', status: 'processing', created_at: new Date().toISOString() }
    ]
    
    imagesApi.list.mockResolvedValue({ 
      data: { 
        images: mockImages,
        page: 1,
        pageSize: 20,
        totalPages: 2
      } 
    })
    
    const wrapper = mount(Gallery)
    
    // Wait for async loadImages
    await flushPromises()
    
    const cards = wrapper.findAll('.image-card')
    expect(cards.length).toBe(2)
    expect(wrapper.text()).toContain('Page 1 of 2')
    
    // First image (done)
    expect(cards[0].find('img').attributes('src')).toBe('/img1.jpg')
    
    // Second image (processing)
    expect(cards[1].text()).toContain('Processing...')
    wrapper.unmount()
  })

  it('disables next page when on the last page', async () => {
    imagesApi.list.mockResolvedValue({
      data: {
        images: [{ id: '1', status: 'done', processed_url: '/img1.jpg', created_at: new Date().toISOString() }],
        page: 1,
        pageSize: 12,
        totalPages: 1
      }
    })

    const wrapper = mount(Gallery)
    await flushPromises()

    const nextButton = wrapper.find('.pagination button:last-child')
    expect(nextButton.attributes('disabled')).toBeDefined()
    wrapper.unmount()
  })

  it('pauses auto-refresh when the tab is hidden and resumes when visible', async () => {
    imagesApi.list.mockResolvedValue({ data: { images: [], page: 1, pageSize: 20, totalPages: 1 } })
    const setIntervalSpy = vi.spyOn(global, 'setInterval')
    const clearIntervalSpy = vi.spyOn(global, 'clearInterval')

    Object.defineProperty(document, 'hidden', { configurable: true, value: false })
    const wrapper = mount(Gallery)
    await flushPromises()

    expect(setIntervalSpy).toHaveBeenCalled()

    Object.defineProperty(document, 'hidden', { configurable: true, value: true })
    document.dispatchEvent(new Event('visibilitychange'))
    expect(clearIntervalSpy).toHaveBeenCalled()

    Object.defineProperty(document, 'hidden', { configurable: true, value: false })
    document.dispatchEvent(new Event('visibilitychange'))
    await flushPromises()

    expect(setIntervalSpy).toHaveBeenCalledTimes(2)
    wrapper.unmount()
  })
})
