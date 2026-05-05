import {
    Controller
} from '@hotwired/stimulus'

export default class extends Controller {
    static values = {
        autoShow: {
            type: Boolean,
            default: false
        }
    }

    connect() {
        if (this.autoShowValue) {
            this.show()
        }
    }

    show() {
        const instance = this.bootstrapModalInstance()
        if (instance && typeof instance.show === 'function') {
            instance.show()
            return
        }

        // Fallback for non-Bootstrap environments
        this.applyShownState()
    }

    hide() {
        this.releaseFocusIfInside()

        const instance = this.bootstrapModalInstance()
        if (instance && typeof instance.hide === 'function') {
            instance.hide()
            return
        }

        // Enforce hidden state for partial/incompatible runtime APIs
        this.applyHiddenState()
    }

    bootstrapModalInstance() {
        if (!window.bootstrap || !window.bootstrap.Modal) {
            return null
        }

        const Modal = window.bootstrap.Modal

        if (typeof Modal.getOrCreateInstance === 'function') {
            return Modal.getOrCreateInstance(this.element)
        }

        if (typeof Modal.getInstance === 'function') {
            return Modal.getInstance(this.element) || new Modal(this.element)
        }

        if (typeof Modal === 'function') {
            return new Modal(this.element)
        }

        return null
    }

    releaseFocusIfInside() {
        const activeElement = document.activeElement
        if (activeElement && this.element.contains(activeElement) && typeof activeElement.blur === 'function') {
            activeElement.blur()
        }
    }

    applyShownState() {
        this.element.style.display = 'block'
        this.element.classList.add('show')
        this.element.setAttribute('aria-hidden', 'false')
    }

    applyHiddenState() {
        this.element.classList.remove('show')
        this.element.style.display = 'none'
        this.element.setAttribute('aria-hidden', 'true')

        document.body.classList.remove('modal-open')
        document.querySelectorAll('.modal-backdrop').forEach((node) => node.remove())
    }
}