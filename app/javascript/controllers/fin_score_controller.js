import {
    Controller
} from '@hotwired/stimulus'

export default class extends Controller {
    compute(event) {
        event.preventDefault()

        const formData = new FormData(this.element)
        if (event.submitter && event.submitter.name) {
            formData.set(event.submitter.name, event.submitter.value)
        }

        const requestURL = `${this.element.action}?${new URLSearchParams(formData).toString()}`
        fetch(requestURL, {
                headers: {
                    Accept: 'application/json'
                }
            })
            .then(response => {
                if (!response.ok) {
                    return response.json().then(payload => {
                        throw new Error(payload.error || 'Request failed')
                    })
                }
                return response.json()
            })
            .then(payload => {
                const targetType = Number(payload.target_type)
                const result = payload.result || {}

                if (targetType === 1 && result.timing) {
                    this.updateTiming(result.timing)
                    this.flashNodeGroup('.target-time')
                } else {
                    this.updateScore(result.score)
                    this.flashNodeGroup('.target-score')
                }

                this.updateStandardTimingLabel(payload.standard_timing_label)
            })
            .catch(error => {
                console.log('fetch error:', error)
            })
    }

    resetScore() {
        document.querySelectorAll('.target-score').forEach(node => {
            node.value = ''
        })
    }

    resetTiming() {
        document.querySelectorAll('.target-time').forEach(node => {
            node.value = ''
        })
    }

    updateTiming(timing) {
        this.updateFieldValue('#minutes', timing.minutes)
        this.updateFieldValue('#seconds', timing.seconds)
        this.updateFieldValue('#hundredths', timing.hundredths)
    }

    updateScore(score) {
        this.updateFieldValue('#score', score)
    }

    updateStandardTimingLabel(label) {
        const node = document.querySelector('#standard-timing-label')
        if (node) {
            node.innerText = label || ''
        }
    }

    updateFieldValue(selector, value) {
        const node = document.querySelector(selector)
        if (node) {
            node.value = value
        }
    }

    flashNodeGroup(selector) {
        document.querySelectorAll(selector).forEach(node => {
            node.classList.add('bg-warning')
            setTimeout(() => {
                node.classList.remove('bg-warning')
            }, 350)
        })
    }
}