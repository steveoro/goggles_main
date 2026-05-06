import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    targetId: String,
    remote: { type: Boolean, default: false }
  }

  connect () {
    this.syncStateFromTarget()
  }

  toggle (_event) {
    if (!this.targetNode) {
      return
    }

    this.toggleTargetVisibility()
    this.syncStateFromTarget()

    if (this.remoteValue) {
      window.setTimeout(() => this.syncStateFromTarget(), 0)
    }
  }

  get targetNode () {
    if (!this.targetIdValue) {
      return null
    }

    return document.getElementById(this.targetIdValue)
  }

  toggleTargetVisibility () {
    if (this.usesBootstrapCollapse(this.targetNode)) {
      this.targetNode.classList.toggle('show')
      return
    }

    this.targetNode.classList.toggle('d-none')
  }

  usesBootstrapCollapse (node) {
    return node && node.classList.contains('collapse')
  }

  isExpanded () {
    if (!this.targetNode) {
      return false
    }

    if (this.usesBootstrapCollapse(this.targetNode)) {
      return this.targetNode.classList.contains('show')
    }

    if (this.targetNode.hidden) {
      return false
    }

    return !this.targetNode.classList.contains('d-none')
  }

  syncStateFromTarget () {
    const expanded = this.isExpanded()

    this.element.classList.toggle('is-expanded', expanded)
    this.element.classList.toggle('is-collapsed', !expanded)
    this.element.setAttribute('aria-expanded', expanded)
  }
}
