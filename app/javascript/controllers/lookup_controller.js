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
 * @param {String} 'data-lookup-placeholder-value'
 *                 localized help text for "Choose an option"

 * @param {String} 'data-lookup-api-url-value'
 *                 base API URL for data request (w/o params);
 *                 when not set, AJAX setup will be skipped and html options will be used
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
    return fetch('/api_session/jwt.json', {
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
    if (this.hasApiUrlValue) {
      // DEBUG
      // console.log('Preparing for AJAX...')
      ajaxOptions = {
        url: (params) => { return `${this.apiUrlValue}${params.term}` },
        dataType: 'json',
        delay: 250,
        data: (params) => {
          // ('page': support for infinite scrolling)
          return { name: params.term, page: params.page };
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
          console.log(data)
          return {
            // TODO: GENERALIZE THIS:
            // [Steve A.] Ideally, use a custom API endpoint that returns data that doesn't
            // need to be processed to be accepted by Select2 (FUTUREDEV)
            results: data.map((row) => {
              return { id: row.id, text: `${row.complete_name} (${row.year_of_birth})` }
            }),
            pagination: {
              more: (params.page * 30) < data.total_count
            }
          };
        }
      }
    }
    return ajaxOptions
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
        ajax: this.chooseSelect2AjaxOptions(jwt),
        cache: true
      })

      $(target).on('select2:select', (event) => {
        // DEBUG
        // console.log('select2:select')
        // console.log(event.params.data)

        // Update target hidden field from selected value:
        if (this.hasFieldIdValue) {
          // DEBUG
          // console.log(`updating field ID (${this.fieldIdValue})`)
          document.querySelector(`#${this.fieldIdValue}`).value = event.params.data.id
        }
        if (this.hasFieldTextValue) {
          // DEBUG
          // console.log(`updating field text (${this.fieldTextValue})`)
          document.querySelector(`#${this.fieldTextValue}`).value = event.params.data.text
        }
      })
    })
  }
  //---------------------------------------------------------------------------
}
