import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
    compute(event) {
        event.preventDefault()

        const formData = new FormData(this.element)
        const requestURL = `${this.element.action}?${new URLSearchParams(formData).toString()}`

        fetch(requestURL, { headers: { Accept: 'application/json' } })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Request failed')
                }
                return response.json()
            })
            .then(payload => {
                this.resetDeltas()
                ;(payload.deltas || []).forEach((delta, index) => {
                    const node = document.querySelector(`#delta-${index}`)
                    if (node) {
                        node.innerText = delta
                    }
                })
                this.hideLoadingIndicator()
            })
            .catch(error => {
                this.hideLoadingIndicator()
                console.log('fetch error:', error)
            })
    }

    resetDeltas() {
        document.querySelectorAll("[id^='delta-']").forEach(node => {
            node.innerText = ''
        })
    }

    hideLoadingIndicator() {
        const indicatorNode = document.querySelector('#loading-indicator')
        if (indicatorNode) {
            indicatorNode.classList.add('d-none')
        }
    }
}
