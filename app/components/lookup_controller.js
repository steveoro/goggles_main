import { Controller } from 'stimulus'
import $ from 'jquery'

require('select2')

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
 * @param {String} 'data-lookup-bound-query-value'
 *                 (API only) inbound additional query parameter field name (no default); when set (for example, as 'country_code'),
 *                 a field text with DOM ID = "<BASE_NAME>_<boundQuery>" will be accessed to retrieve an
 *                 additional (inbound) query parameter value. (In the example, a node with DOM ID = "<BASE_NAME>_country_code")
 *
 * @param {String} 'data-lookup-api-url2-value'
 *                 secondary base API URL for any additional data request (automated, w/o params except the current row ID);
 *                 allows a second API query for entity details after the first lookup,
 *                 using the base name value as target entity and the chosen ID value from the select2 widget as key;
 *                 turned off when not set.
 *
 * @param {Boolean} 'data-lookup-free-text-value'
 *                 enables free text input (the user can enter any text, not just the one matching the items in the value list);
 *                 when set to 'true' (or true by JS DOM attribute getter) it will enable the free 'tags' option of the Select2 widget,
 *                 which allows the user to input any free text that can be used or set as current selection. Disabled by default.
 *
 * @param {String} 'data-lookup-field-base-name-value'
 *                 base name for the DOM IDs used to access the actual fields that will store the
 *                 data values for a form POST (usually an hidden fields).
 *                 Default accessed fields tags will be:
 *                 - DOM ID = "<BASE_NAME>_id" => stores the ID value of the selected option
 *                 - DOM ID = "<BASE_NAME>_label" => stores the display text value of the selected option
 *                 - DOM ID = "<BASE_NAME>_<any other data-field>" => stores any additional data field stored into the selected option
 *                 (The additional data fields will be defined & accessed dynamically.)
 *
 * == Assumptions:
 * @assert the widget can use '.select2' CSS to customize width
 * @assert 'data-lookup-target' must be a parent node the actual '.select2' widget
 *
 * == About the 2nd API call feature:
 * By enabling the second API call, the current row ID is used as key for retrieving all row details, including most associated entities,
 * in a single multi-level nested JSON object with all its associated details.
 * (For example: SwimmingPool(current row ID), -> City, -> PoolType, ...)
 *
 * Relying mostly on entity association naming conventions and on the nested structure of the resulting JSON object, and by looking
 * for the presence of other coherently-named DOM widgets or fields, this controller will try to update their values
 * when the main target widget/field changes its values or its selection.
 *
 * For instance, when using correct naming & parameters in configuring this controller, a 'swimming_pool_select' widget could
 * update any of its related 'pool_type_select', 'city_select' or 'city_area' fields found on the same page.
 *
 * @author Steve A.
 */
export default class extends Controller {
  static targets = ['field']
  static values = {
    placeholder: String,
    apiUrl: String,
    apiUrl2: String,
    queryColumn: String,
    boundQuery: String,
    freeText: Boolean,
    fieldBaseName: String
  }

  /**
   * Sets up the Select2 widget used for the lookup-combo box to which this
   * controller instance connects.
   */
  connect () {
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
  refreshWidgetSetup () {
    if (this.hasApiUrlValue) {
      this.fetchJWT()
        .then((jwt) => this.initSelect2Widget(this.fieldTarget, jwt))
    } else {
      this.initSelect2Widget(this.fieldTarget, null)
    }
  }

  /**
   * Retrieves the Promise for a new valid JWT.
   *
   * @returns the 'fetch' Promise that resolves to the new JWT string value
   */
  async fetchJWT () {
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
      .catch(error => console.error('fetchJWT error:', error))
  }

  /**
   * Retrieves the Promise for the additional entity details object.
   *
   * @param {String} jwt a valid JWT
   * @param {String} entityName the entity/endpoint name (snake-case)
   * @param {String} entityId the desired row ID
   * @returns the 'fetch' Promise that resolves to the an object mapping all entity row details
   */
  async fetchEntityDetails (jwt, entityName, entityId) {
    // DEBUG
    // console.log(`fetchEntityDetails('${entityName}', ${entityId})`)
    // Return an empty object if the secondary API endpoint is not defined:
    if (!this.hasApiUrl2Value) {
      return {}
    }

    return fetch(`${this.apiUrl2Value}/${entityName}/${entityId}`, {
      method: 'GET',
      headers: {
        Authorization: `Bearer ${jwt}`,
        'Content-type': 'application/json;charset=UTF-8'
      }
    }).then(resp => { return resp.json() })
      .catch(error => console.error('fetchEntityDetails error:', error))
  }

  /**
   * Returns the Select2 AJAX options for data retrieval for the lookup options
   * if the apiUrlValue has been set up.
   *
   * @param {String} jwt a valid JWT
   */
  chooseSelect2AjaxOptions (jwt) {
    let ajaxOptions = null
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
        data: (params) => this.prepareAPIPayload(params),

        // Set authorization header:
        beforeSend: (xhr) => {
          try {
            if (jwt == null) {
              console.error('Null JWT before setting header!')
            }
          } catch {
            console.error('Undefined JWT before setting header!')
          }
          xhr.setRequestHeader('Authorization', `Bearer ${jwt}`)
        },

        // Handle JWT expiration:
        error: (_xhr, _textStatus, errorThrown) => {
          if (errorThrown === 'Unauthorized') {
            console.warn('Session expired, refreshing...')
            this.refreshWidgetSetup()
          } else if (errorThrown !== 'abort') {
            console.error(errorThrown)
          }
        },

        // Parse results into Select2 data format:
        processResults: (data, params) => this.processAPIResults(data, params)
      }
    }
    return ajaxOptions
  }
  // ---------------------------------------------------------------------------

  /**
   * Prepares (adjusts) the parameters for the outgoing API call.
   * @param {Object} params the base API query parameters as per Select2 API ('term', 'page')
   */
  prepareAPIPayload (params) {
    // NOTE: avoid pre-setting { select2_format: true } as a default to get always a more rich result dataset
    const queryParams = {}

    // Ask for the simplified select2_format just in special cases:
    if (this.hasFieldBaseNameValue && this.fieldBaseNameValue === 'team') {
      queryParams.select2_format = true
    }

    // Add an in-bound API query parameter, if specified:
    if (this.hasFieldBaseNameValue && this.hasBoundQueryValue && document.querySelector(`#${this.fieldBaseNameValue}_${this.boundQueryValue}`)) {
      queryParams[this.boundQueryValue] = document.querySelector(`#${this.fieldBaseNameValue}_${this.boundQueryValue}`).value
    }

    // Finalize API parameters:
    // - 'term': actual query term
    // - 'page': support for infinite scrolling
    // - 'select2_format': ignored by the API if the endpoint doesn't implement it
    if (this.hasQueryColumnValue) {
      // Bespoke query term:
      queryParams[this.queryColumnValue] = params.term
    } else {
      // Default query term ('name'):
      queryParams.name = params.term
    }
    queryParams.page = params.page
    return queryParams
  }
  // ---------------------------------------------------------------------------

  /**
   * Parses the API result data into the Select2 widget data format.
   * @param {Object} data resulting array of data objects
   * @param {Object} params parameters used for the API query
   */
  processAPIResults (data, params) {
    params.page = params.page || 1 // ('page': support for infinite scrolling)
    // DEBUG
    // console.log('results from API call:')
    // console.log(data)

    if (data.results) { // Already formatted in simplified select2 format? ('results' array)
      return data
    } else { // Prepare the bespoke select2 format:
      return {
        results: data.map((row) => {
          // Recognize Swimmer from defined data attributes:
          if (row.complete_name && row.year_of_birth) {
            return this.setDataMembersForSwimmer(row)
          }
          // Recognize SwimmingPool:
          if (row.pool_type_id && row.name) {
            return this.setDataMembersForSwimmingPool(row)
          }
          // Recognize Meeting/Workshop:
          if (row.code && row.description && row.header_date && row.header_year && row.edition) {
            return this.setDataMembersForMeetings(row)
          }
          // Recognize City:
          if ((row.region || row.area) && row.name) {
            const area = row.region || row.area
            return { id: row.id, text: row.name, area: area }
          }

          // Generic Lookup entity support by checking for long_label or label:
          if (row.long_label) {
            return { id: row.id, text: row.long_label }
          }
          if (row.label) {
            return { id: row.id, text: row.label }
          }

          // Any other default case (just id, text):
          return { id: row.id, text: row.text }
        }),
        pagination: {
          more: (params.page * 30) < data.total_count
        }
      }
    }
  }
  // ---------------------------------------------------------------------------

  /**
   * Returns the usual text label used for displaying a row of the specified entityName.
   * @param {String} entityName a snake_case name of the key entity
   * @param {Object} resultRow  the result object holding the entity attributes
   */
  getLabelForEntity (entityName, resultRow) {
    if (entityName === 'swimmer') {
      return `${resultRow.complete_name} (${resultRow.year_of_birth})`
    }
    if (entityName === 'swimming_pool') {
      return `${resultRow.name} (${resultRow.nick_name})`
    }
    if (entityName === 'meeting' || entityName === 'user_workshop') {
      return `${resultRow.description} (${resultRow.header_date})`
    }
    // Defaults, in priority order:
    return resultRow.label || resultRow.name || resultRow.description
  }

  /**
   * Returns an object with all the custom 'data' members for a Swimmer option lookup,
   * plus the obligatory id key & text label for display.
   * @param {Object} resultRow result object holding Swimmer detailed data fields
   */
  setDataMembersForSwimmer (resultRow) {
    return {
      id: resultRow.id,
      complete_name: resultRow.complete_name,
      first_name: resultRow.first_name,
      last_name: resultRow.last_name,
      year_of_birth: resultRow.year_of_birth,
      gender_type_id: resultRow.gender_type_id,
      text: this.getLabelForEntity('swimmer', resultRow)
    }
  }

  /**
   * Returns an object with all the custom 'data' members for a SwimmingPool option lookup,
   * plus the obligatory id key & text label for display.
   * @param {Object} resultRow result data object holding SwimmingPool detailed data fields
   */
  setDataMembersForSwimmingPool (resultRow) {
    return {
      id: resultRow.id,
      name: resultRow.name,
      nick_name: resultRow.nick_name,
      city_id: resultRow.city_id,
      pool_type_id: resultRow.pool_type_id,
      text: this.getLabelForEntity('swimming_pool', resultRow)
    }
  }

  /**
   * Returns an object with all the custom 'data' members for a Meeting/UserWorkshop option lookup,
   * plus the obligatory id key & text label for display.
   * @param {Object} resultRow result data object holding Meeting/UserWorkshop detailed data fields
   */
  setDataMembersForMeetings (resultRow) {
    return {
      id: resultRow.id,
      code: resultRow.code,
      description: resultRow.description,
      header_date: resultRow.header_date,
      header_year: resultRow.header_year,
      edition: resultRow.edition,
      edition_type_id: resultRow.edition_type_id,
      season_id: resultRow.season_id,
      swimming_pool_id: resultRow.swimming_pool_id,
      team_id: resultRow.team_id,
      timing_type_id: resultRow.timing_type_id,
      text: this.getLabelForEntity('meeting', resultRow)
    }
  }
  // ---------------------------------------------------------------------------

  /**
   * Returns a new Map extracted from the selection data of the specified Select2 widget.
   * @param {Object} targetWidget the Select2 target widget
   */
  prepareMapDataFromCurrentSelection (targetWidget) {
    // DEBUG
    // console.log('prepareMapDataFromCurrentSelection()')
    // console.log("=> $(targetWidget).find(':selected').first().data()")
    // console.log($(targetWidget).find(':selected').first().data())
    // console.log("=> $(targetWidget).select2('data')")
    // console.log($(targetWidget).select2('data'))

    const mapData = new Map()
    mapData.set('id', $(targetWidget).find(':selected').first().val())
    mapData.set('label', $(targetWidget).find(':selected').first().text())
    if ($(targetWidget).find(':selected').first().data()) {
      this.copyObjectToMap($(targetWidget).find(':selected').first().data(), mapData)
    }
    return mapData
  }
  // ---------------------------------------------------------------------------

  /**
   * Copies all attributes of a specified Object into a Map of key attributes and values.
   * The method skips certain attributes which may be found when dealing with internal data objects
   * from the Select2 widget.
   * Both object and destMap are assumed to be existing and defined.
   *
   * @param {Object} object   an Object with data properties
   * @param {Map}    destMap  the destination data Map
   * @returns the converted/enriched Map object data
   */
  copyObjectToMap (object, destMap) {
    if (object && destMap) {
      Object.entries(object)
        .forEach(
          ([key, value]) => {
            // Skip peculiar attributes:
            if (key !== 'text' && key !== 'selected' && key !== 'select2Id') {
              destMap.set(key, value)
            }
          }
        )
    }
    return destMap
  }

  /**
   * Sets the text color of the span text identified by '#<BASE_NAME>-presence'.
   * @param {String}  baseName base name for the presence indicator.
   * @param {boolean} hasLabel true sets the flag span text to green; red (default) otherwise.
   */
  presenceLedUpdate (baseName, hasLabel) {
    if (document.querySelector(`#${baseName}-presence`)) {
      // Make sure the "status led" is green when there's a selection and vice-versa:
      // Given that setHiddenFieldsValue() may be invoked twice on some occasions,
      // we'll do an explicit check instead of relying on the simple outcome of toggleClass():
      if (hasLabel) {
        $(`#${baseName}-presence`).addClass('text-success')
        $(`#${baseName}-presence`).removeClass('text-danger')
      } else {
        $(`#${baseName}-presence`).addClass('text-danger')
        $(`#${baseName}-presence`).removeClass('text-success')
      }
    }
  }
  // ---------------------------------------------------------------------------

  /**
   * Setter for all the hidden fields stored in the lookup option data (id, label, ...).
   * (Does nothing if the data field is not found.)
   *
   * @param {String} baseName base name for the context of the provided data map and base prefix for
   *                          all the hidden fields;
   * @param {Object} mapData a Map including all attribute names and values that have to be
   *                         stored on hidden field tags having DOM IDs = "<BASE_NAME>_<ATTR_NAME>"
   *
   * == Example: ==
   *
   * mapData = { id: 1, label: "whatever", another_field: "anything", ... }
   *
   * - stores 1          as value of the DOM node having ID "<BASE_NAME>_id"
   * - stores "whatever" as value of the DOM node having ID "<BASE_NAME>_label"
   * - stores "anything" as value of the DOM node having ID "<BASE_NAME>_another_field"
   */
  setHiddenFieldsValue (baseName, mapData) {
    // DEBUG
    console.log('setHiddenFieldsValue()')
    console.log(mapData)

    if (baseName && mapData) {
      /*
       * Free-input text case handling:
       * Clear the ID field if it's equal to the label.
       */
      if (mapData.get('id') === mapData.get('label')) {
        mapData.set('id', 0)
        // Peculiar cases:
        // 1. SwimmingPool: clear pre-existing values set by cookies when we're setting new records
        if (baseName.startsWith('swimming_pool') && mapData.get('label')) {
          document.querySelector('#swimming_pool_name').value = mapData.get('label')
          document.querySelector('#swimming_pool_nick_name').value = null
          document.querySelector('#swimming_pool_city_id').value = null
          document.querySelector('#swimming_pool_pool_type_id').value = null
        }
        // 1. Swimmer: update complete_name
        if (baseName.startsWith('swimmer') && mapData.get('label') && document.querySelector(`#${baseName}_complete_name`)) {
          document.querySelector(`#${baseName}_complete_name`).value = mapData.get('label')
        }
      }

      // "Status led" update for the main data input:
      this.presenceLedUpdate(baseName, mapData.has('label'))
      const baseSelector = `#${baseName}_`

      // Set each hidden field tag value from data map only if the DOM node is found:
      mapData.forEach(
        (value, key) => {
          // If a kwy field is found (prefixed with base name), trigger all the related changes,
          // including any '<BASE_NAME><key>_select' value selects (which will work only on Select2
          // widget with pre-fixed list of options):
          if (document.querySelector(`${baseSelector}${key}`)) {
            // DEBUG
            console.log(`Found DOM field for '${key}': [${baseSelector}${key}] <= ${value}`)
            document.querySelector(`${baseSelector}${key}`).value = value
            /*
             * Trigger a sub-entity change for in-bound select2 widgets.
             * (Updates only the linked sub-entity's hidden id & label)
             *
             * If the current field name ("key") ends with "_id" (as in 'swimming_pool_id', or 'city_id'),
             * then it's assumed to imply the Rails convention for an association column name.
             * Thus, we check if there's also a possible Select2 widget bound to this by a similar name,
             * and we update that too when found.
             *
             * The naming convention is:
             * - "key" ("<something>_id") DOM node for source value
             *   => "key-minus-id_select" ("<something>_select") DOM node for target change
             *
             * == Example ==
             * - key: "pool_type_id" => target select: "pool_type_select"
             */
            const boundSelectBaseName = key.split('_id')[0]
            const boundSelectID = `#${boundSelectBaseName}_select`

            // Process bound select widgets & hidden fields (but skip special cases handled elsewhere)
            if (key.endsWith('_id') && (key !== 'city_id') && document.querySelector(boundSelectID)) {
              this.setOrCreateSelect2Option(boundSelectBaseName, value, null)
            }
          }

          // If there's another Select2 widget with an DOM ID based on the current key and the current
          // value holds nested details, we can go deep with recursion and update its fields too:
          // (but skip special cases handled elsewhere)
          if (!key.endsWith('_id') && (key !== 'city') && document.querySelector(`#${key}_select`) && value.id) {
            // DEBUG
            console.log(`Nested data details w/ '#${key}_select' widget found: going deep...`)
            const nestedLabel = this.getLabelForEntity(key, value)
            this.setOrCreateSelect2Option(key, value.id, nestedLabel)
            const nestedMap = new Map()
            this.copyObjectToMap(value, nestedMap)
            nestedMap.set('label', nestedLabel)
            this.setHiddenFieldsValue(key, nestedMap)
          }
        }
      )

      this.handleSpecialCases(mapData)
    }
  }
  // ---------------------------------------------------------------------------

  /**
   * Selects a specific key value among the available options.
   * If the option is not available, it will be added programmatically.
   *
   * @param {String} boundSelectBaseName  the DOM ID base name for all the widget bound to the current target
   * @param {String} value the key value for the selection in the bound widget
   * @param {String} label the label text for the selection in the bound widget;
   *                       if not defined, the current data selection will be used instead (if available)
   */
  setOrCreateSelect2Option (boundSelectBaseName, value, label) {
    const boundSelectID = `#${boundSelectBaseName}_select`
    // Set the value, creating a new option if necessary:
    if ($(boundSelectID).find("option[value='" + value + "']").length) {
      $(boundSelectID).val(value).trigger('change')
    } else if (label) { // Otherwise, create a new Option and pre-select it by default:
      const newOption = new Option(label, value, true, true)
      // Append it to the select
      $(boundSelectID).append(newOption).trigger('change')
    }

    // Set also the related hidden fields:
    $(`#${boundSelectBaseName}_id`).val(value)
    if (label) {
      $(`#${boundSelectBaseName}_label`).val(label)
    } else if ($(boundSelectID).select2('data').length > 0) {
      // Set the label from the Option if possible and the label parameter was not set:
      $(`#${boundSelectBaseName}_label`).val(
        $(boundSelectID).select2('data')[0].text
      )
    }
    // Update the correlated presence "status led":
    this.presenceLedUpdate(boundSelectBaseName, $(`#${boundSelectBaseName}_label`).val().length > 0)
  }

  /**
   * Additional binding steps taken depending by specific field names that differ from the usual
   * ActiveRecord convention naming scheme ("<FIELD_NAME>_id" => "<FIELD_NAME>" association).
   *
   * Does a bunch domain-specific, quick & dirty update-triggering stuff in other bound widgets,
   * but only if the target DOM IDs are found and mapData contains any one among the following attribute keys:
   *
   * - year_of_birth => updates #category_type_select
   * - year_of_birth => updates #category_type_select
   * - (FUTUREDEV: add more here)
   *
   * @param {Object} mapData a Map including all attribute names for the current selection
   */
  handleSpecialCases (mapData) {
    /*
     * Special case #1:
     * - 'year_of_birth' => update 'category_type_select'
     * (selection dataset assumed to be already present)
     */
    if (mapData.get('year_of_birth') && document.querySelector('#category_type_select')) {
      const age = (new Date().getFullYear() - mapData.get('year_of_birth'))
      const code = Math.floor(age / 5) * 5
      // Find the ID value looking for the displayed code:
      const valueId = $('#category_type_select').find(`option:contains('M${code}')`).first().val()
      $('#category_type_select').val(valueId)
      $('#category_type_select').trigger('change')
      // Programmatically set also any related fields:
      $('#category_type_id').val(valueId)
      $('#category_type_label').val($('#category_type_select').select2('data')[0].text)
    }
    /*
     * Special case #2:
     * - 'gender_type_id' => update 'gender_type_id' standard select_tag
     * (selection dataset assumed to be already present)
     */
    if (mapData.get('gender_type_id') && document.querySelector('#gender_type_id')) {
      const valueId = mapData.get('gender_type_id')
      $('#gender_type_id').val(valueId)
      $('#gender_type_id').trigger('change')
    }

    /*
     * Special case #3: 'city_id' w/ city object => update 'city_select'
     * (selection dataset will be created if missing)
     */
    if (mapData.get('city_id') && mapData.get('city') && document.querySelector('#city_select')) {
      // DEBUG
      // console.log('city details:')
      // console.log(mapData.get('city'))
      this.setOrCreateSelect2Option('city', mapData.get('city_id'), mapData.get('city').name)
      // Programmatically set also any other related fields:
      $('#city_country_code').val(mapData.get('city').country_code)
      $('#city_area').val(mapData.get('city').area)
    }

    /*
     * Special case #4: 'pool_type_id' w/ PoolType object => update 'pool_type_select'
     * (selection dataset will be created if missing)
     */
    if (mapData.get('pool_type_id') && mapData.get('pool_type') && document.querySelector('#pool_type_select')) {
      // DEBUG
      console.log('pool type details:')
      console.log(mapData.get('pool_type'))
      const valueId = mapData.get('pool_type_id')
      $('#pool_type_id').val(valueId)
      $('#pool_type_id').trigger('change')
    }
  }
  // ---------------------------------------------------------------------------

  /**
   * Tries to resolve the current selected row details with all its details by using the secondary API
   * endpoint (with the fieldBaseNameValue as the single-row fetch endpoint).
   *
   * In any case, when mapData is defined the hidden fields are updated with the values of the
   * defined attributes.
   *
   * @param {String} jwt a valid JWT
   * @param {Object} mapData a Map including all attribute names for the current selection
   */
  async enrichMapDataWithDetails (jwt, mapData) {
    // DEBUG
    // console.log('enrichMapDataWithDetails')
    if (this.hasApiUrl2Value && this.hasFieldBaseNameValue && (mapData.get('id') > 0)) {
      return this.fetchEntityDetails(jwt, this.fieldBaseNameValue, mapData.get('id'))
        .then((json) => {
          // Add or replace the display label into the JSON result:
          json.label = mapData.get('label')
          // DEBUG
          // console.log('enrichMapDataWithDetails result:')
          // console.log(json)
          this.copyObjectToMap(json, mapData)
          this.setHiddenFieldsValue(this.hasFieldBaseNameValue ? this.fieldBaseNameValue : '', mapData)
        })
    } else {
      this.setHiddenFieldsValue(this.hasFieldBaseNameValue ? this.fieldBaseNameValue : '', mapData)
    }
  }
  // ---------------------------------------------------------------------------

  /**
   * Resolves internally the JWT value and then initializes the specified Select2 widget.
   * (This needs to be called each time the JWT expires or changes.)
   *
   * @param {Object} target the target widget for Select2 setup
   * @param {String} jwt    a yet-to-be-resolved JWT for the current API sessions
   */
  initSelect2Widget (target, jwt) {
    const currJWT = jwt
    $(target).select2({
      placeholder: this.placeholderValue,
      minimumInputLength: 3,
      width: 'style',
      theme: 'bootstrap4',
      tags: this.freeTextValue, // (the 'tags' option will enable free-text input)
      ajax: this.chooseSelect2AjaxOptions(currJWT),
      cache: true
    })

    // Preset target hidden fields if there's a pre-selection already:
    if ($(target).find(':selected').val()) {
      // DEBUG
      // console.log('select2 => :selected')
      const mapData = this.prepareMapDataFromCurrentSelection(target)
      this.setHiddenFieldsValue(this.hasFieldBaseNameValue ? this.fieldBaseNameValue : '', mapData)
    }
    // Update target hidden fields also when the drop-down menu is closing.
    // Note: 'change' & 'select2:select' events) may not always be triggered due to AJAX delay,
    // especially if the "free-text" tag option is set - in which case we need to consider
    // as a valid selection any value that is written in the input box.
    $(target).on('select2:closing', (_event) => {
      // DEBUG
      // console.log('select2 => select2:closing')
      const mapData = this.prepareMapDataFromCurrentSelection(target)
      this.setHiddenFieldsValue(this.hasFieldBaseNameValue ? this.fieldBaseNameValue : '', mapData)
    })

    // Update target hidden fields when the actual selection occurs:
    // (To limit the total of API calls, this should be the only place where the secondary call occurs)
    $(target).on('select2:select', (event) => {
      // DEBUG
      // console.log('select2 => select2:select')
      // const mapData = this.prepareMapDataFromCurrentSelection(target)
      const mapData = new Map()
      mapData.set('label', event.params.data.text)
      this.copyObjectToMap(event.params.data, mapData)
      this.enrichMapDataWithDetails(currJWT, mapData)
    })
  }
  // ---------------------------------------------------------------------------
}
