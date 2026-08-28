import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect () {
    const anchorNode = this.anchorNode
    if (!anchorNode) return

    const collapseNode = anchorNode.closest('.collapse')
    if (!collapseNode || !this.element.contains(collapseNode)) return

    collapseNode.classList.add('show')
    const triggerNode = this.element.querySelector(`[aria-controls="${collapseNode.id}"]`)
    if (triggerNode) {
      triggerNode.classList.remove('collapsed')
      triggerNode.setAttribute('aria-expanded', 'true')
    }

    window.requestAnimationFrame(() => anchorNode.scrollIntoView({ block: 'start' }))
  }

  get anchorNode () {
    if (!window.location.hash.startsWith('#mprg-')) return null

    return document.getElementById(decodeURIComponent(window.location.hash.slice(1)))
  }
}
