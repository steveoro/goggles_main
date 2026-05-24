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

const urlStringForResource = (resource) => {
    if (!resource) {
        return null
    }

    if (typeof resource === "string") {
        return resource
    }

    if (resource.url) {
        return resource.url.toString()
    }

    if (resource.href) {
        return resource.href.toString()
    }

    return null
}

const prefetchRequestUrls = new Set()
const prefetchResponseUrls = new WeakMap()

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
    const requestUrl = event && event.detail ? urlStringForResource(event.detail.url) : null
    if (isPrefetchTurboEvent(event)) {
        if (requestUrl) {
            prefetchRequestUrls.add(requestUrl)
        }
    }
})

document.addEventListener("turbo:before-fetch-response", (event) => {
    const request = event && event.detail && event.detail.fetchResponse && event.detail.fetchResponse.request
    const response = event && event.detail && event.detail.fetchResponse && event.detail.fetchResponse.response
    const requestUrl = request && request.url ? request.url.toString() : null
    const responseUrl = response && response.url ? response.url : null
    const prefetchResponseUrl = response ? prefetchResponseUrls.get(response) : null
    if (prefetchResponseUrl) {
        prefetchResponseUrls.delete(response)
        prefetchRequestUrls.delete(prefetchResponseUrl)
        return
    }

    if (requestUrl && prefetchRequestUrls.delete(requestUrl)) {
        return
    }

    if (!requestUrl && responseUrl && prefetchRequestUrls.delete(responseUrl)) {
        return
    }
})

document.addEventListener("turbo:fetch-request-error", (event) => {
    const requestUrl = event && event.detail ? urlStringForResource(event.detail.url) : null
    if (requestUrl && prefetchRequestUrls.delete(requestUrl)) {
        return
    }
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
            const requestUrl = urlStringForResource(args[0])
            return originalFetch(...args).then((response) => {
                if (response && requestUrl) {
                    prefetchResponseUrls.set(response, requestUrl)
                }
                return response
            })
        }

        tracker.increment()
        return originalFetch(...args).finally(() => tracker.decrement())
    }
    window.__requestTrackerPatchedFetch = true
}