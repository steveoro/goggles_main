import {
    Controller
} from '@hotwired/stimulus'

/**
 * = Creative trainings gallery =
 *
 * Thumbnail grid + full-size image modal with prev/next navigation.
 * Item metadata is passed as a JSON array inside a <script type="application/json">
 * tag referenced by the 'items' target.
 *
 * Bootstrap 4 is available but its jQuery-based modal API is avoided here in
 * favour of direct class/style toggling (same approach as modal_controller's
 * fallback), so it also works without jQuery at all.
 *
 * == Targets ==
 * - items:      <script type="application/json"> element holding the items JSON
 * - modal:      the modal container element
 * - image:      the <img> showing the current full-size picture
 * - caption:    element receiving the auto-built item title
 * - trainingBy: element receiving the 'training_by' value
 * - createdBy:  element receiving the 'created_by' value (as link when swimmer_url is present)
 * - descriptionSection: wrapper shown only when the item has a description
 * - description:        the <code> element holding the description text
 * - descriptionToggle:  the expand/collapse link for the description
 */
export default class extends Controller {
    static targets = [
        'items', 'modal', 'image', 'caption', 'trainingBy', 'createdBy',
        'descriptionSection', 'description', 'descriptionToggle', 'copyButton'
    ]

    connect() {
        this.items = JSON.parse(this.itemsTarget.textContent)
        this.currentIndex = 0
        this.boundKeydown = this.keydown.bind(this)
    }

    disconnect() {
        document.removeEventListener('keydown', this.boundKeydown)
    }

    // Opens the modal at the clicked thumbnail index.
    // ('data-gallery-index-param' on the thumbnail carries the item position.)
    open(event) {
        event.preventDefault()
        this.currentIndex = parseInt(event.params.index, 10) || 0
        this.renderCurrent()
        this.showModal()
    }

    next(event) {
        if (event) {
            event.preventDefault()
        }
        if (this.items.length === 0) {
            return
        }
        this.currentIndex = (this.currentIndex + 1) % this.items.length
        this.renderCurrent()
    }

    previous(event) {
        if (event) {
            event.preventDefault()
        }
        if (this.items.length === 0) {
            return
        }
        this.currentIndex = (this.currentIndex - 1 + this.items.length) % this.items.length
        this.renderCurrent()
    }

    close(event) {
        if (event) {
            event.preventDefault()
        }
        this.hideModal()
    }

    // Toggles the collapsed description block below the full-size image.
    toggleDescription(event) {
        event.preventDefault()
        this.descriptionTarget.classList.toggle('collapsed-description')
    }

    // Copies the description text to the clipboard.
    // (Bound to the copy button beside the description block.)
    copyDescription(event) {
        event.preventDefault()
        const text = this.descriptionTarget.textContent
        this.writeClipboard(text).then(() => {
            this.flashCopied()
        })
    }

    //-- internals --------------------------------------------------------

    renderCurrent() {
        const item = this.items[this.currentIndex]
        if (!item) {
            return
        }

        this.imageTarget.src = item.full_url
        this.imageTarget.alt = item.title
        this.captionTarget.textContent = item.title
        this.trainingByTarget.textContent = item.training_by || ''

        // 'created_by' renders as a link to the swimmer's page when valid:
        if (item.swimmer_url) {
            const link = document.createElement('a')
            link.href = item.swimmer_url
            link.textContent = item.created_by
            this.createdByTarget.replaceChildren(link)
        } else {
            this.createdByTarget.textContent = item.created_by || ''
        }

        // Collapsed description section, only when the item has one:
        if (item.description) {
            this.descriptionSectionTarget.classList.remove('d-none')
            this.descriptionTarget.textContent = item.description
            this.descriptionTarget.classList.add('collapsed-description')
        } else {
            this.descriptionSectionTarget.classList.add('d-none')
            this.descriptionTarget.textContent = ''
        }
    }

    showModal() {
        this.modalTarget.classList.add('show')
        this.modalTarget.style.display = 'block'
        this.modalTarget.setAttribute('aria-hidden', 'false')
        document.body.classList.add('modal-open')
        document.addEventListener('keydown', this.boundKeydown)

        if (!this.backdrop) {
            this.backdrop = document.createElement('div')
            this.backdrop.className = 'modal-backdrop fade show'
            document.body.appendChild(this.backdrop)
        }
    }

    hideModal() {
        this.releaseFocusIfInside()
        this.modalTarget.classList.remove('show')
        this.modalTarget.style.display = 'none'
        this.modalTarget.setAttribute('aria-hidden', 'true')
        document.body.classList.remove('modal-open')
        document.removeEventListener('keydown', this.boundKeydown)

        if (this.backdrop) {
            this.backdrop.remove()
            this.backdrop = null
        }
    }

    keydown(event) {
        if (event.key === 'Escape') {
            this.close(event)
        } else if (event.key === 'ArrowRight') {
            this.next(event)
        } else if (event.key === 'ArrowLeft') {
            this.previous(event)
        }
    }

    releaseFocusIfInside() {
        const activeElement = document.activeElement
        if (activeElement && this.modalTarget.contains(activeElement) && typeof activeElement.blur === 'function') {
            activeElement.blur()
        }
    }

    writeClipboard(text) {
        if (navigator.clipboard && window.isSecureContext !== false) {
            return navigator.clipboard.writeText(text)
        }

        // Fallback for non-secure contexts / older browsers:
        return new Promise((resolve, reject) => {
            const helper = document.createElement('textarea')
            helper.value = text
            helper.style.position = 'absolute'
            helper.style.left = '-9999px'
            document.body.appendChild(helper)
            helper.select()
            try {
                document.execCommand('copy')
                resolve()
            } catch (err) {
                reject(err)
            } finally {
                helper.remove()
            }
        })
    }

    flashCopied() {
        if (!this.hasCopyButtonTarget) {
            return
        }
        const button = this.copyButtonTarget
        const icon = button.querySelector('i')
        const originalText = button.textContent
        button.classList.add('text-success')
        if (icon) {
            icon.classList.replace('fa-clipboard', 'fa-check')
        } else {
            button.textContent = '✓'
        }
        window.setTimeout(() => {
            button.classList.remove('text-success')
            if (icon) {
                icon.classList.replace('fa-check', 'fa-clipboard')
            } else {
                button.textContent = originalText
            }
        }, 1200)
    }
}
