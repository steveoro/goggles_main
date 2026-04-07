import { Controller } from '@hotwired/stimulus'

/**
 * = StimulusJS controller for Pop-overs, Modals & Tooltips =
 *
 * Allows popover, modal & tooltip initialization without adding
 * page/load event listeners for Turbo/Turbolinks.
 *
 * Setup is performed on controller instance binding: as long as the
 * page is connected to this controller, any initialization will be automatically
 * done for:
 * - data-toggle="tooltip"
 * - data-toggle="modal"
 * - data-toggle="popover"
 *
 * (Typically, this controller is bound to the application layout, so that there's
 * no need to duplicate the data-controller code on each view.)
 *
 * == Targets ==
 * (no static targets)
 *
 * == Values ==
 * (no static values)
 *
 * == Actions:
 * (no actions, just setup)
 *
 * @author Steve A.
 */
export default class extends Controller {
  /**
   * Sets up the controller.
   * (Called whenever the controller instance connects to the DOM)
   */
  connect () {
    this.setupAutoHideAlerts()
    this.setupSwitchableCollapseLabel()
  }

  setupAutoHideAlerts () {
    document.querySelectorAll('.flash-alert.alert').forEach((alertNode) => {
      window.setTimeout(() => {
        alertNode.classList.add('fade')
        alertNode.style.opacity = '0'
        window.setTimeout(() => {
          alertNode.remove()
        }, 300)
      }, 2500)
    })
  }

  setupSwitchableCollapseLabel () {
    const iconNode = document.querySelector('#show-more-or-less')
    if (!iconNode) {
      return
    }

    document.querySelectorAll('.switchable-label-collapse').forEach((collapseNode) => {
      collapseNode.addEventListener('shown.bs.collapse', () => {
        iconNode.classList.remove('fa-plus')
        iconNode.classList.add('fa-minus')
      })
      collapseNode.addEventListener('hidden.bs.collapse', () => {
        iconNode.classList.remove('fa-minus')
        iconNode.classList.add('fa-plus')
      })
    })
  }
}
