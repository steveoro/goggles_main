import "@hotwired/turbo-rails"
import "controllers"
import "channels"

const tracker = {
  pendingRequests: 0,
  increment() {
    this.pendingRequests += 1
  },
  decrement() {
    this.pendingRequests = Math.max(0, this.pendingRequests - 1)
  },
  isIdle() {
    return this.pendingRequests === 0
  }
}

window.__requestTracker = tracker

document.addEventListener("turbo:before-fetch-request", () => tracker.increment())
document.addEventListener("turbo:before-fetch-response", () => tracker.decrement())
document.addEventListener("turbo:fetch-request-error", () => tracker.decrement())
document.addEventListener("turbo:load", () => {
  tracker.pendingRequests = 0
})

if (typeof window.fetch === "function" && !window.__requestTrackerPatchedFetch) {
  const originalFetch = window.fetch.bind(window)
  window.fetch = (...args) => {
    tracker.increment()
    return originalFetch(...args).finally(() => tracker.decrement())
  }
  window.__requestTrackerPatchedFetch = true
}
