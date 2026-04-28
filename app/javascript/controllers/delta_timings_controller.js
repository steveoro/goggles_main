import {
    Controller
} from '@hotwired/stimulus'

export default class extends Controller {
    compute(event) {
        event.preventDefault()

        const formData = new FormData(this.element)
        const requestURL = `${this.element.action}?${new URLSearchParams(formData).toString()}`
        console.log('DeltaTimings: requesting', requestURL)

        fetch(requestURL, {
                headers: {
                    Accept: 'application/json'
                }
            })
            .then(response => {
                console.log('DeltaTimings: response status', response.status)
                if (!response.ok) {
                    throw new Error(`Request failed: ${response.status}`)
                }
                return response.json()
            })
            .then(payload => {
                console.log('DeltaTimings: payload', payload)
                this.resetDeltas();
                (payload.deltas || []).forEach((delta, index) => {
                    const node = document.querySelector(`#delta-${index}`)
                    if (node) {
                        node.innerText = delta
                    }
                })
                this.hideLoadingIndicator()
            })
            .catch(error => {
                this.hideLoadingIndicator()
                console.error('DeltaTimings: fetch error:', error)
            })
    }

    resetDeltas() {
        document.querySelectorAll("b[id^='delta-']").forEach(node => {
            node.innerText = ''
        })
    }

    hideLoadingIndicator() {
        const indicatorNode = document.querySelector('#loading-indicator')
        if (indicatorNode) {
            indicatorNode.classList.add('d-none')
        }
    }

    showOutputModal(event) {
        event.preventDefault()
        this.collectDeltasIntoTxt()

        const modalElement = document.querySelector('#output-txt-modal')
        if (!modalElement) {
            return
        }

        if (window.bootstrap && window.bootstrap.Modal) {
            const Modal = window.bootstrap.Modal
            let instance = null

            if (typeof Modal.getOrCreateInstance === 'function') {
                instance = Modal.getOrCreateInstance(modalElement)
            } else if (typeof Modal.getInstance === 'function') {
                instance = Modal.getInstance(modalElement) || new Modal(modalElement)
            } else {
                instance = new Modal(modalElement)
            }

            instance.show()
            return
        }

        if (window.$) {
            window.$(modalElement).modal('show')
            return
        }

        modalElement.style.display = 'block'
        modalElement.setAttribute('aria-hidden', 'false')
    }

    collectDeltasIntoTxt() {
        let txtOutput = "---8<---[TXT]\r\n"
        let csvOutput = "\r\n---8<---[CSV ➡ \";\"=value sep., \"`\"=text sep.]\r\n"

        for (let index = 0; index < 15; index++) {
            const minNode = document.querySelector(`input[name='m[${index}]']`)
            const secNode = document.querySelector(`input[name='s[${index}]']`)
            const hdsNode = document.querySelector(`input[name='h[${index}]']`)
            const min = (minNode && minNode.value) || 0
            const sec = (secNode && secNode.value) || 0
            const hds = (hdsNode && hdsNode.value) || 0

            if (min > 0 || sec > 0 || hds > 0) {
                const deltaNode = document.querySelector(`#delta-${index}`)
                const delta = (deltaNode && deltaNode.innerText) || ''
                txtOutput += `${min}'${sec}"${hds} => Δt: ${delta} (${index + 1}, ${(index + 1) * 50}m)\r\n`
                csvOutput += `${min};${sec};${hds};\`${min}'${sec}\"${hds}\`;\`${delta}\`;${index + 1};${(index + 1) * 50}\r\n`
            }
        }

        const outputField = document.querySelector('#output')
        if (outputField) {
            outputField.value = `${txtOutput}\r\n${csvOutput}`
        }
    }
}