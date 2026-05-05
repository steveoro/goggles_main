import "@hotwired/turbo-rails"
import "controllers"
import "channels"

const loadingIndicator = {
    indicatorId: "loading-indicator",
    hiddenClass: "d-none",
    get node() {
        return document.querySelector(`#${this.indicatorId}`)
    },
    show() {
        const node = this.node
        if (node) {
            node.classList.remove(this.hiddenClass)
        }
    },
    hide() {
        const node = this.node
        if (node) {
            node.classList.add(this.hiddenClass)
        }
    },
    sync(isIdle) {
        if (isIdle) {
            this.hide()
            return
        }
        this.show()
    }
}

const tracker = {
    pendingRequests: 0,
    increment() {
        this.pendingRequests += 1
        loadingIndicator.sync(this.isIdle())
    },
    decrement() {
        this.pendingRequests = Math.max(0, this.pendingRequests - 1)
        loadingIndicator.sync(this.isIdle())
    },
    isIdle() {
        return this.pendingRequests === 0
    }
}

window.__requestTracker = tracker
window.__loadingIndicator = loadingIndicator

document.addEventListener("turbo:before-fetch-request", () => tracker.increment())
document.addEventListener("turbo:before-fetch-response", () => tracker.decrement())
document.addEventListener("turbo:fetch-request-error", () => tracker.decrement())
document.addEventListener("turbo:load", () => {
    tracker.pendingRequests = 0
    loadingIndicator.sync(true)
})

if (typeof window.fetch === "function" && !window.__requestTrackerPatchedFetch) {
    const originalFetch = window.fetch.bind(window)
    window.fetch = (...args) => {
        tracker.increment()
        return originalFetch(...args).finally(() => tracker.decrement())
    }
    window.__requestTrackerPatchedFetch = true
}