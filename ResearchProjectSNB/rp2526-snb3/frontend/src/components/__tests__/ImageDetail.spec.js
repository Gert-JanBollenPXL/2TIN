import { describe, it, expect, vi, beforeEach } from 'vitest'
import { flushPromises, mount } from '@vue/test-utils'
import ImageDetail from '../ImageDetail.vue'
import { imagesApi } from '@/api/images'

vi.mock('@/api/images', () => ({
  imagesApi: {
    get: vi.fn()
  }
}))

describe('ImageDetail Component', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    global.fetch = vi.fn().mockResolvedValue({
      ok: true,
      blob: vi.fn().mockResolvedValue(new Blob(['test']))
    })
    global.URL.createObjectURL = vi.fn(() => 'blob:local-image')
    global.URL.revokeObjectURL = vi.fn()
  })

  it('loads image details and creates a blob URL for signed originals', async () => {
    imagesApi.get.mockResolvedValueOnce({
      data: {
        id: 'img-1',
        status: 'done',
        mime: 'image/png',
        bytes: 1234,
        original_url: 'https://example.com/original',
        original_headers: { Authorization: 'signed' },
        processed_url: 'https://example.com/processed',
        created_at: new Date().toISOString()
      }
    })

    const wrapper = mount(ImageDetail, {
      props: { imageId: 'img-1' }
    })

    await flushPromises()

    expect(imagesApi.get).toHaveBeenCalledWith('img-1', expect.anything())
    expect(global.fetch).toHaveBeenCalled()
    expect(global.URL.createObjectURL).toHaveBeenCalled()

    wrapper.unmount()
    expect(global.URL.revokeObjectURL).toHaveBeenCalled()
  })
})
