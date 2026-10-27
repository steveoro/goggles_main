import { Controller } from '@hotwired/stimulus'

// Handles the Goggle Cup season/team/cup selection page on goggles_main:
// - submits the GET selection form when the season or managed-team changes;
// - navigates to the selected cup (or to a "new cup" page) via the cup selector;
// - smart-selects swimmers belonging to a secondary team;
// - computes the ranking via AJAX (proxied to the API server-side) and shows
//   it in the collapsible ranking panel.
//
// Submits carrying a `formaction` attribute (save/publish/unpublish buttons)
// are left to the browser so they post to their own endpoints natively.
export default class extends Controller {
  static targets = ['form', 'selectionForm', 'noDuplicatedEventsField', 'swimmerCheckbox', 'swimmerPanel',
                    'rankingContainer', 'computeButton', 'overlay', 'cupSelect', 'goggleCupIdField',
                    'descriptionField', 'seasonYearField', 'endDateField', 'externalSwimmersContainer',
                    'selectionCounter', 'precomputedButton']
  static values = { smartSelectionUrl: String, indexUrl: String, hasRankingData: Boolean }

  connect() {
    this.csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || ''
    this.teamSelect = document.querySelector('#team_select')
    this.secondaryTeamSelect = document.querySelector('#secondary_team_select')
    this.boundSmartSelectWithDelay = this.smartSelectWithDelay.bind(this)
    this.boundSubmitSelectionFormWithDelay = this.submitSelectionFormWithDelay.bind(this)
    if (this.secondaryTeamSelect) {
      this.secondaryTeamSelect.addEventListener('change', this.boundSmartSelectWithDelay)
    }
    if (this.teamSelect) {
      // The autocomplete updates the hidden team_id field on change; the small
      // delay lets that happen before the selection form is submitted.
      this.teamSelect.addEventListener('change', this.boundSubmitSelectionFormWithDelay)
    }
    this.updateSelectionCounter()
    this.toggleRankingButtons()
  }

  disconnect() {
    if (this.secondaryTeamSelect) {
      this.secondaryTeamSelect.removeEventListener('change', this.boundSmartSelectWithDelay)
    }
    if (this.teamSelect) {
      this.teamSelect.removeEventListener('change', this.boundSubmitSelectionFormWithDelay)
    }
  }

  // Stimulus value callback: enables/disables the stored-ranking related buttons.
  hasRankingDataValueChanged() {
    this.toggleRankingButtons()
  }

  // Enables or disables "Show precomputed" (needs stored ranking data).
  toggleRankingButtons() {
    if (this.hasPrecomputedButtonTarget) {
      this.precomputedButtonTarget.disabled = !this.hasRankingDataValue
    }
  }

  // Submits the GET selection form (season / managed-team changes).
  submitSelectionForm(event) {
    if (event) {
      event.preventDefault()
    }
    if (this.hasSelectionFormTarget) {
      this.selectionFormTarget.requestSubmit()
    }
  }

  submitSelectionFormWithDelay() {
    window.setTimeout(() => this.submitSelectionForm(), 150)
  }

  // Navigates to the chosen cup, or back to a clean "new cup" page when the
  // empty option is picked.
  selectCup(event) {
    const cupId = event.target.value
    const url = new URL(this.indexUrlValue, window.location.origin)
    if (cupId) {
      url.searchParams.append('goggle_cup_id', cupId)
    } else {
      const seasonYear = this.fieldValue('season_year')
      const teamId = this.fieldValue('team_id')
      if (seasonYear) {
        url.searchParams.append('season_year', seasonYear)
      }
      if (teamId) {
        url.searchParams.append('team_id', teamId)
      }
    }
    window.location.href = url.toString()
  }

  selectAll(event) {
    event.preventDefault()
    this.swimmerCheckboxTargets.forEach((checkbox) => {
      if (!checkbox.disabled) {
        checkbox.checked = true
      }
    })
    this.updateSelectionCounter()
  }

  deselectAll(event) {
    event.preventDefault()
    this.swimmerCheckboxTargets.forEach((checkbox) => {
      if (!checkbox.disabled) {
        checkbox.checked = false
      }
    })
    this.updateSelectionCounter()
  }

  smartSelectWithDelay() {
    window.setTimeout(() => this.smartSelect(), 150)
  }

  // Checks the swimmer checkboxes matching the swimmers holding a badge for the
  // chosen secondary team (via the smart_selection endpoint).
  async smartSelect() {
    const teamId = this.fieldValue('team_id')
    const secondaryTeamId = this.fieldValue('secondary_team_id')

    if (!teamId || !secondaryTeamId || secondaryTeamId === '0') {
      return
    }

    const url = new URL(this.smartSelectionUrlValue, window.location.origin)
    url.searchParams.append('team_id', teamId)
    url.searchParams.append('secondary_team_id', secondaryTeamId)
    url.searchParams.append('season_year', this.fieldValue('season_year'))

    const response = await fetch(url.toString(), {
      method: 'GET',
      headers: { Accept: 'application/json' }
    })

    if (!response.ok) {
      return
    }

    const data = await response.json()
    const selectedIds = (data.swimmer_ids || []).map((id) => `${id}`)

    this.swimmerCheckboxTargets.forEach((checkbox) => {
      if (!checkbox.disabled) {
        checkbox.checked = selectedIds.includes(`${checkbox.dataset.swimmerId}`)
      }
    })
    this.updateSelectionCounter()
  }

  updateSelectionCounter() {
    if (!this.hasSelectionCounterTarget) {
      return
    }

    const total = this.swimmerCheckboxTargets.length
    const selected = this.swimmerCheckboxTargets.filter((cb) => cb.checked).length
    this.selectionCounterTarget.textContent = `(${selected} / ${total})`
  }

  // Computes the Goggle Cup ranking via AJAX (the controller action proxies to
  // the API which computes and persists ranking_data on the remote DB).
  // Buttons carrying a `formaction` attribute (save/publish/unpublish) bypass
  // this handler so the browser posts them to their own endpoints natively.
  async compute(event) {
    if (event.submitter && event.submitter.getAttribute('formaction')) {
      return
    }

    event.preventDefault()

    if (!this.hasFormTarget) {
      return
    }

    // Confirm before overwriting precomputed ranking data
    if (this.hasRankingDataValue && this.hasRankingDataValue === true) {
      const message = this.element.dataset.goggleCupsConfirmOverwriteMessage ||
        'A precomputed ranking exists for this cup. Computing will overwrite it. Continue?'
      if (!window.confirm(message)) {
        return
      }
    }

    this.setLoading(true)

    try {
      const formData = new FormData(this.formTarget)
      const response = await fetch(this.formTarget.action, {
        method: this.formTarget.method.toUpperCase(),
        headers: {
          Accept: 'application/json',
          'X-CSRF-Token': this.csrfToken
        },
        body: formData
      })
      const data = await response.json().catch(() => ({}))

      if (!response.ok) {
        this.showComputeError(data.error)
        return
      }

      if (this.hasRankingContainerTarget) {
        this.rankingContainerTarget.innerHTML = data.html || ''
      }
      // The compute action persists ranking_data, so the stored-data buttons
      // can be enabled right away.
      if (this.hasGoggleCupIdFieldTarget && this.goggleCupIdFieldTarget.value) {
        this.hasRankingDataValue = true
      }
      this.showRankingPanel()
    } catch (_error) {
      this.showComputeError()
    } finally {
      this.setLoading(false)
    }
  }

  // Shows a compute failure (API error detail or generic message) inside the
  // ranking panel, as plain text.
  showComputeError(message) {
    const text = message || this.element.dataset.goggleCupsComputeErrorMessage ||
      'Unable to compute the ranking. Please try again later.'
    if (!this.hasRankingContainerTarget) {
      window.alert(text)
      return
    }

    const alertBox = document.createElement('div')
    alertBox.className = 'alert alert-danger my-2'
    alertBox.setAttribute('role', 'alert')
    alertBox.textContent = text
    this.rankingContainerTarget.replaceChildren(alertBox)
    this.showRankingPanel()
  }

  // Expands the ranking panel and scrolls it into view.
  showRankingPanel() {
    const panel = document.querySelector('#ranking-panel')
    if (!panel) {
      return
    }
    panel.classList.add('show')
    panel.scrollIntoView({ behavior: 'smooth', block: 'start' })
  }

  // Smooth-scrolls back to the cup selection card without navigating, so the
  // current swimmer selection is preserved.
  goToTop(event) {
    event.preventDefault()
    const target = document.querySelector('#select-cup')
    if (target) {
      target.scrollIntoView({ behavior: 'smooth', block: 'start' })
    } else {
      window.scrollTo({ top: 0, behavior: 'smooth' })
    }
  }

  fieldValue(fieldName) {
    const field = (this.hasFormTarget && this.formTarget.querySelector(`[name="${fieldName}"]`)) ||
      (this.hasSelectionFormTarget && this.selectionFormTarget.querySelector(`[name="${fieldName}"]`)) ||
      document.querySelector(`[name="${fieldName}"]`)
    return field ? field.value : ''
  }

  setLoading(loading) {
    if (this.hasComputeButtonTarget) {
      this.computeButtonTarget.disabled = loading
      this.computeButtonTarget.classList.toggle('disabled', loading)
    }

    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.toggle('d-none', !loading)
    }
  }
}
