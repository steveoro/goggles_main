import { Controller } from 'stimulus'
import $ from 'jquery'

/**
 * = Switch::XorComponent StimulusJS controller =
 *
 * Companion controller for the Switch::XorComponent for toggling visibility
 * between two target DOM nodes.
 *
 * This controller performs:
 *
 * - Xor-switch state setting: set current target visibility (TODO) & toggle switch state;
 * - visibility toggle between the two targets, making the selected one visible and the other one hidden;
 * - labels color update (to improve visibility).
 *
 * == Targets ==
 * @param {String} 'data-switch-target': 'area1'  first target DOM ID used by the toggle XOR switch
 * @param {String} 'data-switch-target': 'area2', second target DOM ID
 * @param {String} 'data-switch-target': 'label1'  first text label DOM ID
 * @param {String} 'data-switch-target': 'label2', second text label DOM ID
 * @param {String} 'data-switch-target': 'selector', choice selector field (1 or 2, depending on current area)
 *
 * == Values ==
 * (no static values)
 *
 * == Actions:
 * - Switch::XorComponent binds its click() action to:
 *   'click->switch#toggleTargets'
 *
 * == Usage ==
 * Set the data-controller attribute ("{ data: { controller: 'switch' } }") in a parent node that
 * wraps together both the Xor switch component *and*the target DOM areas.
 *
 * @author Steve A.
 */
export default class extends Controller {
  static targets = ['area1', 'area2', 'label1', 'label2', 'selector']

  /**
   * Sets up the controller.
   * (Called whenever the controller instance connects to the DOM)
   */
  connect () {
    // DEBUG
    // console.log('Connecting Switch controller...')

    // TODO: add visibility setup boilerplate for the targets, given state saved in cookies
  }
  // ---------------------------------------------------------------------------

  /**
   * Toggles visibility between the two targets & sets the current choice
   * value in the selector target field.
   */
  toggleTargets (_event) {
    if (this.hasArea1Target) {
      $(this.area1Target).toggleClass('d-none')
    }
    if (this.hasLabel1Target) {
      $(this.label1Target).toggleClass('text-muted')
    }
    if (this.hasArea2Target) {
      $(this.area2Target).toggleClass('d-none')
    }
    if (this.hasLabel2Target) {
      $(this.label2Target).toggleClass('text-muted')
    }
    // Update the hidden field value:
    if (this.hasSelectorTarget) {
      $(this.selectorTarget).val(
        /*
          Area 2 hidden ? => choice is area 1

          For sake of simplicity I won't parametrize this.
          The values below must match 'app/components/switch/xor_component.rb' in actual values:
          - Switch::XorComponent::TYPE_TARGET1 => 1
          - Switch::XorComponent::TYPE_TARGET2 => 2
        */
        $(this.area2Target).hasClass('d-none') ? 1 : 2
      )
    }
  }
}
