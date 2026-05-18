import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { flushPromises, mount } from '@vue/test-utils'
import Queue from '../Queue.vue'
import { queueApi } from '@/api/queue'

vi.mock('@/api/queue', () => ({
  queueApi: {
    stats: vi.fn(),
    metrics: vi.fn(),
    global: vi.fn()
  }
}))

describe('Queue Component', () => {
  beforeEach(() => {
    vi.useFakeTimers()
    vi.clearAllMocks()
  })

  afterEach(() => {
    vi.useRealTimers()
  })

  it('renders stats and metrics from the API', async () => {
    queueApi.stats.mockResolvedValueOnce({
      data: {
        stats: [
          { status: 'queued', count: 2 },
          { status: 'processing', count: 1 },
          { status: 'done', count: 5 },
          { status: 'failed', count: 0 }
        ]
      }
    })
    queueApi.metrics.mockResolvedValueOnce({
      data: {
        total_images: 10,
        processed_images: 6,
        recent_failures: 0,
        queued_jobs: 2
      }
    })
    queueApi.global.mockResolvedValueOnce({
      data: {
        users: [
          {
            user_id: 'shared',
            queued: 1,
            processing: 0,
            done: 3,
            failed: 0,
            total_24h: 4
          }
        ]
      }
    })

    const wrapper = mount(Queue)
    await flushPromises()

    expect(wrapper.text()).toContain('Queued')
    expect(wrapper.text()).toContain('Processing')
    expect(wrapper.text()).toContain('Completed')
    expect(wrapper.text()).toContain('10')
    expect(wrapper.text()).toContain('6')

    wrapper.unmount()
  })

  it('polls for updates on an interval', async () => {
    queueApi.stats.mockResolvedValue({
      data: { stats: [{ status: 'queued', count: 1 }] }
    })
    queueApi.metrics.mockResolvedValue({
      data: { total_images: 1, processed_images: 0, recent_failures: 0, queued_jobs: 1 }
    })
    queueApi.global.mockResolvedValue({
      data: { users: [] }
    })

    const wrapper = mount(Queue)
    await flushPromises()

    vi.advanceTimersByTime(2000)
    await flushPromises()

    expect(queueApi.stats).toHaveBeenCalledTimes(2)
    expect(queueApi.metrics).toHaveBeenCalledTimes(2)
    expect(queueApi.global).toHaveBeenCalledTimes(2)

    wrapper.unmount()
  })
})
