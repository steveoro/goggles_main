import "@hotwired/turbo-rails"
import "controllers"
import "channels"

const PREFETCH_HEADER_NAME = "x-sec-purpose"
const PREFETCH_HEADER_VALUE = "prefetch"

const headerValueFor = (headers, key) => {
    if (!headers || !key) {
        return null
    }

    if (typeof headers.get === "function") {
        return headers.get(key)
    }

    const normalizedKey = key.toLowerCase()
    const entries = Array.isArray(headers) ? headers : Object.entries(headers)
    const matchedEntry = entries.find(([entryKey]) => String(entryKey).toLowerCase() === normalizedKey)
    return matchedEntry ? matchedEntry[1] : null
}

const isPrefetchHeaders = (headers) => {
    const value = headerValueFor(headers, PREFETCH_HEADER_NAME)
    return String(value || "").toLowerCase() === PREFETCH_HEADER_VALUE
}

const isPrefetchTurboEvent = (event) => {
    const headers = event && event.detail && event.detail.fetchOptions && event.detail.fetchOptions.headers
    return isPrefetchHeaders(headers)
}

const isPrefetchFetchCall = (args) => {
    const [resource, options] = args

    if (isPrefetchHeaders(options && options.headers)) {
        return true
    }

    if (isPrefetchHeaders(resource && resource.headers)) {
        return true
    }

    return false
}

const prefetchRequestUrls = new Set()

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

document.addEventListener("turbo:before-fetch-request", (event) => {
    const requestUrl = event && event.detail && event.detail.url ? event.detail.url.toString() : null
    if (isPrefetchTurboEvent(event)) {
        if (requestUrl) {
            prefetchRequestUrls.add(requestUrl)
        }
        return
    }

    tracker.increment()
})

document.addEventListener("turbo:before-fetch-response", (event) => {
    const requestUrl = event && event.detail && event.detail.url ? event.detail.url.toString() : null
    const responseUrl =
        event && event.detail && event.detail.fetchResponse && event.detail.fetchResponse.response ?
        event.detail.fetchResponse.response.url :
        null
    if (requestUrl && prefetchRequestUrls.delete(requestUrl)) {
        return
    }

    if (!requestUrl && responseUrl && prefetchRequestUrls.delete(responseUrl)) {
        return
    }

    tracker.decrement()
})

document.addEventListener("turbo:fetch-request-error", (event) => {
    const requestUrl = event && event.detail && event.detail.url ? event.detail.url.toString() : null
    if (requestUrl && prefetchRequestUrls.delete(requestUrl)) {
        return
    }

    tracker.decrement()
})

document.addEventListener("turbo:load", () => {
    tracker.pendingRequests = 0
    prefetchRequestUrls.clear()
    loadingIndicator.sync(true)
})

if (typeof window.fetch === "function" && !window.__requestTrackerPatchedFetch) {
    const originalFetch = window.fetch.bind(window)
    window.fetch = (...args) => {
        if (isPrefetchFetchCall(args)) {
            return originalFetch(...args)
        }

        tracker.increment()
        return originalFetch(...args).finally(() => tracker.decrement())
    }
    window.__requestTrackerPatchedFetch = true
}