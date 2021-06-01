import { Controller } from 'stimulus'

require('select2');

/**
 * = StimulusJS generic Lookup controller =
 *
 * Prepares and manages a generic lookup combo-box for input selection.
 * Works with both remote sources and static arrays of options.
 *
 * For remote data sources, given an authenticated form (behind login, with valid CSRF token):
 * 1. sets a JWT for an API session
 * 2. makes async calls to retrieve lookup data from API endpoints
 * 3. auto-renews JWT on API request 'unauthorized' response
 *
 * Base widget: @see https://select2.org/
 *
 *
 * == Targets ==
 * @param {String} 'data-lookup-target': 'field'
 *                 the target for this controller instance: a lookup field combo-box;
 *                 query for the selection: any name or description part from the options
 *
 *
 * == Values ==
 * (Put values directly on controller elements)
 * @param {String} 'data-lookup-api-url-value'
 *                 base API URL for data request (w/o params);
 *                 when not set, AJAX setup will be skipped and html options will be used
 *
 * @param {String} 'data-lookup-placeholder-value'
 *                 localized help text for "Choose an option"
 *
 * @param {String} 'data-lookup-query-column-value'
 *                 query field name used in the API lookup call; defaults to 'name'
 *
 * @param {String} 'data-lookup-free-text-value'
 *                 query field name used in the API lookup call; defaults to 'name'
 *
 * @param {String} 'data-lookup-field-id-value'
 *                 DOM ID for form field id/value (actual selection value storage; usually an hidden field)
 *
 * @param {String} 'data-lookup-field-text-value'
 *                 DOM ID for field displaying the selection text (label or text field)
 *
 *
 * == Assumptions:
 * @assert the widget can use '.select2' CSS to customize width
 * @assert 'data-lookup-target' must be a parent node the actual '.select2' widget
 *
 * @author Steve A.
 */
export default class extends Controller {
  static targets = ['field']
  static values = {
    placeholder: String,
    apiUrl: String,
    queryColumn: String,
    freeText: Boolean,
    fieldId: String,
    fieldText: String
  }

  /**
   * Sets up the Select2 widget used for the lookup-combo box to which this
   * controller instance connects.
   */
  connect() {
    // DEBUG
    // console.log('Connecting controller...')

    if (this.hasFieldTarget) {
      // DEBUG
      // console.log('Target found.')
      this.refreshWidgetSetup()
    }
  }


  /**
   * Performs a programmatic refresh of the JWT if needed, followed by a reset of
   * the Select2 setups.
   * Otherwise it just sets up the Select2 widget for static data handling.
   */
  refreshWidgetSetup() {
    if (this.hasApiUrlValue) {
      this.fetchJWT()
        .then((jwt) => this.initSelect2Widget(this.fieldTarget, jwt))
    }
    else {
      this.initSelect2Widget(this.fieldTarget, null)
    }
  }


  /**
   * Retrieves a new, valid JWT.
   *
   * @returns the 'fetch' Promise that resolves to the new JWT string value
   */
  fetchJWT() {
    // DEBUG
    // console.log('Fetching JWT...')
    return fetch('/api_sessions/jwt.json', {
      method: 'POST',
      headers: {
        'X-CSRF-Token': $('meta[name=csrf-token]').attr('content'),
        'Content-type': 'application/json;charset=UTF-8'
      }
    }).then(resp => { return resp.json() })
      .then(json => { return json.jwt })
      .catch(error => console.error('error:', error))
  }


  /**
   * Returns the Select2 AJAX options for data retrieval for the lookup options
   * if the apiUrlValue has been set up.
   *
   * @param {String} jwt a valid JWT
   */
  chooseSelect2AjaxOptions(jwt) {
    var ajaxOptions = null
    var queryParams = { select2_format: true }
    if (this.hasApiUrlValue) {
      // DEBUG
      // console.log('Preparing for AJAX...')
      // console.log(this.apiUrlValue)

      ajaxOptions = {
        url: this.apiUrlValue,
        dataType: 'json',
        method: 'GET',
        delay: 250,
        // Compose payload:
        data: (params) => {
          // - 'page': support for infinite scrolling
          // - 'select2_format': ignored by the API if the endpoint doesn't implement it
          if (this.hasQueryColumnValue) {
            queryParams[this.queryColumnValue] = params.term
            queryParams['page'] = params.page
            // DEBUG
            // console.log('queryParams:')
            // console.log(queryParams)
            return queryParams
          }
          else {
            queryParams['name'] = params.term
            queryParams['page'] = params.page
            // DEBUG
            // console.log('queryParams:')
            // console.log(queryParams)
            return queryParams
          }
        },
        // Set authorization header:
        beforeSend: (xhr) => {
          try {
            if (jwt == null) {
              console.error('Null JWT before setting header!')
            }
          } catch {
            console.error('Undefined JWT before setting header!')
          }
          xhr.setRequestHeader('Authorization', `Bearer ${jwt}`);
        },
        // Handle JWT expiration:
        error: (_xhr, _textStatus, errorThrown) => {
          if (errorThrown == 'Unauthorized') {
            console.warn('Session expired, refreshing...')
            this.refreshWidgetSetup()
          }
          else if (errorThrown != 'abort') {
            console.error(errorThrown)
          }
        },
        // Parse results into Select2 data format:
        processResults: (data, params) => {
          params.page = params.page || 1; // ('page': support for infinite scrolling)
          // DEBUG
          // console.debug("results from API call:")
          // console.debug(data)

          if (data.results) { // Already formatted in select2 format?
            return data
          }
          else {              // Prepare results in select2 format:
            return {
              // TODO: GENERALIZE THIS:
              // [Steve A.] Ideally, use a custom API endpoint that returns data that doesn't
              // need to be processed to be accepted by Select2 (FUTUREDEV)
              results: data.map((row) => {
                var text_label = null
                if (row.long_label) {
                  text_label = row.long_label
                }
                else if (row.label) {
                  text_label = row.label
                }
                else if (row.complete_name) {
                  text_label = `${row.complete_name} (${row.year_of_birth})`
                }
                return { id: row.id, text: text_label }
              }),
              pagination: {
                more: (params.page * 30) < data.total_count
              }
            }
          }
        }
      }
    }
    // DEBUG
    // console.log(ajaxOptions)
    return ajaxOptions
  }


  /**
   * Setter for the hidden fields (id & label).
   *
   * @param {Number} id     the id value to be stored
   * @param {String} label  the text label value to be stored
   */
  setHiddenFieldsValue(id, label) {
    if (this.hasFieldIdValue) {
      // Clear the ID field if it's equal to the label (it means it's a free text tag)
      document.querySelector(`#${this.fieldIdValue}`).value = (id == label ? 0 : id)
    }
    if (this.hasFieldTextValue) {
      document.querySelector(`#${this.fieldTextValue}`).value = label
    }
  }


  /**
   * Resolves internally the JWT value and then initializes the specified Select2 widget.
   * (This needs to be called each time the JWT expires or changes.)
   *
   * @param {Object} target the target widget for Select2 setup
   * @param {String} jwt    a yet-to-be-resolved JWT for the current API sessions
   */
  initSelect2Widget(target, jwt) {
    Promise.resolve(jwt).then(jwt => {
      // DEBUG
      // console.log('Target setup.')
      $(target).select2({
        placeholder: this.placeholderValue,
        minimumInputLength: 3,
        width: 'style',
        theme: "bootstrap4",
        tags: this.freeTextValue, // (the 'tags' option will enable free-text input)
        ajax: this.chooseSelect2AjaxOptions(jwt),
        cache: true
      })

      // Preset hidden fields if there's a pre-selection already:
      if ($(target).find(':selected').val()) {
        this.setHiddenFieldsValue($(target).find(':selected').val(), $(target).find(':selected').text())
      }
      // Update target hidden fields when the selection occurs:
      $(target).on('select2:select', (event) => {
        this.setHiddenFieldsValue(event.params.data.id, event.params.data.text)
      })
    })
  }
  //---------------------------------------------------------------------------
}
