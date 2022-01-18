import { Controller } from '@hotwired/stimulus'

/**
 * = StimulusJS controller for "wizard-like" forms =
 *
 * Handles wizard & progress in filling the associated form.
 * Even though the form is treated with different steps, the submit action
 * remains a single one.
 *
 * If some of the input fields among the form steps are required, the wizard final
 * submit button will result disabled (this controller hides the
 * already processed form steps) and thus it will require an additional script
 * to re-enable it.
 * (As in "document.getElementById('btn-wizard-submit').disabled = false")
 *
 *
 * == Targets ==
 * @param {String} 'data-wizard-form-target': 'form'
 *                 identifies the associated form; the form is supposed to be divided
 *                 into several 'form steps', with a single submit action at the end.
 *
 * @param {String} 'data-wizard-form-target': 'progress'
 *                 identifies the associated progress bar.
 *
 *
 * == Reserved CSS classes ==
 * - '.progress-step'         => defined on each progress bar step
 * - '.progress-step-active'  => active progress steps only
 * - '.progress-step-check'   => checked progress steps only
 * - '.step-forms'            => defined on each step form
 * - '.step-forms-active'     => active step forms only
 * - '.btn-next'              => defined on each  "next" button
 * - '.btn-prev'              => defined on each  "previous" button
 *
 *
 * == Values ==
 * (no static values)
 *
 *
 * == Actions:
 * (none so far)
 *
 * @author Steve A.
 */
export default class extends Controller {
  static targets = ['form', 'progress']

  /**
   * Sets up the controller.
   */
  connect () {
    this.setUp()
  }

  /**
   * Sets the event handlers for the associated wizard-form and all the
   * other customized display details.
   */
  setUp() {
    // DEBUG
    // console.log('Setting-up wizard-form...')
    if (!this.hasFormTarget || !this.hasProgressTarget) {
      console.warn('Required target(s) for wizard-form missing: skipping setup.')
      return
    }

    let progressCounter = 0

    document.querySelectorAll('.btn-next').forEach((btn) => {
      btn.addEventListener('click', () => {
        progressCounter = this.handleBtnProgress(progressCounter, 1)
        return false
      });
    });

    document.querySelectorAll('.btn-prev').forEach((btn) => {
      btn.addEventListener('click', () => {
        progressCounter = this.handleBtnProgress(progressCounter, -1)
        return false
      });
    });
  }
  // ---------------------------------------------------------------------------

  /**
   * Handler for previous/next button clicks.
   * @param {Number} progressCounter the current step counter.
   * @param {Number} direction the direction for the step value change.
   * @returns the updated progress counter.
   */
  handleBtnProgress(progressCounter, direction) {
    // DEBUG
    // console.log(`handleBtnNext(${progressCounter})`)
    progressCounter = progressCounter + direction
    this.updateFormSteps(progressCounter)
    this.updateProgressBar(progressCounter)
    return progressCounter
  }
  // ---------------------------------------------------------------------------

  /**
   * Updates the visibility & style of the each individual form step,
   * depending on the current progress counter.
   * @param {Number} progressCounter the current step counter.
   */
  updateFormSteps(progressCounter) {
    const formSteps = document.querySelectorAll('.step-forms')

    formSteps.forEach((formStep) => {
      formStep.classList.contains('step-forms-active') &&
        formStep.classList.remove('step-forms-active')
    })

    formSteps[progressCounter].classList.add('step-forms-active')
  }
  // ---------------------------------------------------------------------------

  /**
   * Updates the visibility & style of the steps on the progress bar,
   * depending on the current progress counter.
   * @param {Number} progressCounter the current step counter.
   */
  updateProgressBar(progressCounter) {
    const progress = this.progressTarget
    const progressSteps = document.querySelectorAll('.progress-step')

    progressSteps.forEach((progressStep, idx) => {
      if (idx < progressCounter + 1) {
        progressStep.classList.add('progress-step-active')
      }
      else {
        progressStep.classList.remove('progress-step-active')
      }
    })

    progressSteps.forEach((progressStep, idx) => {
      if (idx < progressCounter) {
        progressStep.classList.add('progress-step-check')
      }
      else {
        progressStep.classList.remove('progress-step-check')
      }
    })

    const progressActive = document.querySelectorAll('.progress-step-active')
    progress.style.width = ((progressActive.length - 1) / (progressSteps.length - 1)) * 100 + '%'
  }
  // ---------------------------------------------------------------------------

  /*
  TODO:
  => Make a separate controller for last 'next' button, handling the summary fill-in, specific
     for this for usage of the wizard. Leave this controller as generic as possible.
  */

  /**
   * @returns the String description for the Meeting/Workshop, depending on the switch value.
   */
  getMeetingLabel() {
    if (this.hasDescriptionTarget && this.hasFirstTarget && this.hasLastTarget) {
      this.descriptionTarget.value.value = `${this.firstTarget.value} ${this.lastTarget.value}`
    }
  }
  // ---------------------------------------------------------------------------
}
