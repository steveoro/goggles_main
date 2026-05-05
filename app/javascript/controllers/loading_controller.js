import {
    Controller
} from '@hotwired/stimulus'

export default class extends Controller {
    /**
     * Shows the loading indicator if it's globally available.
     */
    show() {
        if (window.__loadingIndicator && window.__loadingIndicator.show) {
            window.__loadingIndicator.show()
            return
        }
        const indicatorNode = document.querySelector('#loading-indicator')
        if (indicatorNode) {
            indicatorNode.classList.remove('d-none')
        }
    }

    /**
     * Hides the loading indicator if it's globally available and the request tracker is idle.
     */
    hide() {
        if (window.__requestTracker && window.__requestTracker.isIdle && !window.__requestTracker.isIdle()) {
            return
        }
        if (window.__loadingIndicator && window.__loadingIndicator.hide) {
            window.__loadingIndicator.hide()
            return
        }
        const indicatorNode = document.querySelector('#loading-indicator')
        if (indicatorNode) {
            indicatorNode.classList.add('d-none')
        }
    }
}