import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
    static values = {
        indicatorId: { type: String, default: 'loading-indicator' },
        hiddenClass: { type: String, default: 'd-none' }
    }

    show() {
        const indicatorNode = this.indicatorNode
        if (indicatorNode) {
            indicatorNode.classList.remove(this.hiddenClassValue)
        }
    }

    hide() {
        const indicatorNode = this.indicatorNode
        if (indicatorNode) {
            indicatorNode.classList.add(this.hiddenClassValue)
        }
    }

    get indicatorNode() {
        return document.querySelector(`#${this.indicatorIdValue}`)
    }
}
