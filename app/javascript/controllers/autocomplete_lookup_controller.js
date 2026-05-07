import {
    Controller
} from '@hotwired/stimulus'

import TomSelect from 'tom-select'

/**
 * Lookup controller refactored for importmap runtime.
 * Uses TomSelect instead of jQuery/Select2.
 * 
 * Original docs:
 *
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

    connect() {
        if (!this.hasFieldTarget) {
            return
        }
        this.jwt = null
        this.jwtPromise = null
        this.tomSelect = null
        this.setupTomSelect()
    }

    disconnect() {
        if (this.tomSelect) {
            this.tomSelect.destroy()
            this.tomSelect = null
        }
    }

    get baseName() {
        if (this.hasFieldBaseNameValue && this.fieldBaseNameValue) {
            return this.fieldBaseNameValue
        }
        return this.fieldTarget.id.replace(/_select$/, '')
    }

    csrfToken() {
        const node = document.querySelector('meta[name=csrf-token]')
        return node ? node.content : ''
    }

    /**
     * Retrieves the Promise for a new valid JWT.
     *
     * @returns the 'fetch' Promise that resolves to the new JWT string value
     */
    async fetchJWT() {
        // DEBUG
        // console.log('Fetching JWT...')
        return fetch('/api_sessions/jwt.json', {
                method: 'POST',
                headers: {
                    'X-CSRF-Token': this.csrfToken(),
                    'Content-Type': 'application/json;charset=UTF-8'
                }
            }).then((resp) => resp.json())
            .then((json) => json.jwt)
            .catch((error) => {
                console.error('fetchJWT error:', error)
                return null
            })
    }

    /**
     * Retrieves the Promise for the additional entity details object.
     *
     * @returns the 'fetch' Promise that resolves to the an object mapping all entity row details
     */
    async ensureJWT() {
        if (!this.hasApiUrlValue) {
            return null
        }
        if (this.jwt) {
            return this.jwt
        }
        if (!this.jwtPromise) {
            this.jwtPromise = this.fetchJWT().then((jwt) => {
                this.jwt = jwt
                this.jwtPromise = null
                return jwt
            })
        }
        return this.jwtPromise
    }

    async fetchEntityDetails(jwt, entityName, entityId) {
        // DEBUG
        // console.log(`fetchEntityDetails('${entityName}', ${entityId})`)
        // Return an empty object if the secondary API endpoint is not defined:
        if (!this.hasApiUrl2Value || !entityName || !entityId) {
            return {}
        }

        return fetch(`${this.apiUrl2Value}/${entityName}/${entityId}`, {
                method: 'GET',
                headers: {
                    Authorization: `Bearer ${jwt}`,
                    'Content-Type': 'application/json;charset=UTF-8'
                }
            }).then((resp) => resp.json())
            .catch((error) => {
                console.error('fetchEntityDetails error:', error)
                return {}
            })
    }

    setupTomSelect() {
        const staticOptions = this.optionsFromSelectElement()
        this.tomSelect = new TomSelect(this.fieldTarget, {
            options: staticOptions,
            valueField: 'id',
            labelField: 'text',
            searchField: ['text'],
            placeholder: this.hasPlaceholderValue ? this.placeholderValue : '',
            maxOptions: 100,
            maxItems: 1,
            plugins: {
                clear_button: {}
            },
            create: this.hasFreeTextValue && this.freeTextValue ?
                (input) => ({
                    id: input,
                    text: input,
                    label: input
                }) : false,
            shouldLoad: (query) => !this.hasApiUrlValue || query.length >= 3,
            load: (query, callback) => {
                this.loadRemoteOptions(query, callback)
            },
            onInitialize: () => {
                this.syncCurrentSelection()
            },
            onChange: () => {
                this.syncCurrentSelection()
            }
        })
    }

    optionsFromSelectElement() {
        return Array.from(this.fieldTarget.options).map((option) => this.optionNodeToObject(option))
    }

    optionNodeToObject(option) {
        const data = {
            id: option.value,
            text: option.text,
            label: option.text
        }

        Object.entries(option.dataset || {}).forEach(([key, value]) => {
            data[this.camelToSnake(key)] = value
        })
        return data
    }

    camelToSnake(value) {
        return value.replace(/[A-Z]/g, (letter) => `_${letter.toLowerCase()}`)
    }

    /**
     * Prepares (adjusts) the parameters for the outgoing API call.
     * @param {Object} term the query parameter
     */
    prepareAPIPayload(term) {
        const queryParams = {}

        if (this.hasFieldBaseNameValue && this.fieldBaseNameValue === 'team') {
            queryParams.select2_format = true
        }

        if (this.hasFieldBaseNameValue && this.hasBoundQueryValue) {
            const boundNode = document.querySelector(`#${this.fieldBaseNameValue}_${this.boundQueryValue}`)
            if (boundNode) {
                queryParams[this.boundQueryValue] = boundNode.value
            }
        }

        if (this.hasQueryColumnValue && this.queryColumnValue) {
            queryParams[this.queryColumnValue] = term
        } else {
            queryParams.name = term
        }

        queryParams.page = 1
        return queryParams
    }

    async loadRemoteOptions(query, callback) {
        if (!this.hasApiUrlValue) {
            callback()
            return
        }

        if (!query || query.length < 3) {
            callback([])
            return
        }

        try {
            const jwt = await this.ensureJWT()
            const payload = this.prepareAPIPayload(query)
            const queryString = new URLSearchParams(payload).toString()
            const response = await fetch(`${this.apiUrlValue}?${queryString}`, {
                method: 'GET',
                headers: {
                    Authorization: `Bearer ${jwt}`,
                    'Content-Type': 'application/json;charset=UTF-8'
                }
            })

            if (response.status === 401) {
                this.jwt = null
                this.jwtPromise = null
                callback([])
                return
            }

            const data = await response.json()
            const parsed = this.processAPIResults(data)
            callback(parsed.results || [])
        } catch (error) {
            console.error('loadRemoteOptions error:', error)
            callback([])
        }
    }

    processAPIResults(data) {
        if (data && Array.isArray(data.results)) {
            return data
        }

        const rows = Array.isArray(data) ? data : []
        return {
            results: rows.map((row) => this.normalizeRow(row))
        }
    }

    normalizeRow(row) {
        if (row.complete_name && row.year_of_birth) {
            return {
                id: row.id,
                complete_name: row.complete_name,
                first_name: row.first_name,
                last_name: row.last_name,
                year_of_birth: row.year_of_birth,
                gender_type_id: row.gender_type_id,
                text: `${row.complete_name} (${row.year_of_birth})`
            }
        }

        if (row.pool_type_id && row.name) {
            return {
                id: row.id,
                name: row.name,
                nick_name: row.nick_name,
                city_id: row.city_id,
                pool_type_id: row.pool_type_id,
                text: `${row.name} (${row.nick_name})`
            }
        }

        if (row.code && row.description && row.header_date && row.header_year && row.edition) {
            return {
                id: row.id,
                code: row.code,
                description: row.description,
                header_date: row.header_date,
                header_year: row.header_year,
                edition: row.edition,
                edition_type_id: row.edition_type_id,
                season_id: row.season_id,
                swimming_pool_id: row.swimming_pool_id,
                team_id: row.team_id,
                timing_type_id: row.timing_type_id,
                text: `${row.description} (${row.header_date})`
            }
        }

        if ((row.region || row.area) && row.name) {
            return {
                id: row.id,
                text: row.name,
                area: row.region || row.area
            }
        }

        if (row.long_label || row.label || row.display_label || row.short_label) {
            return {
                id: row.id,
                text: row.long_label || row.label || row.display_label || row.short_label
            }
        }

        return {
            id: row.id,
            text: row.text || row.name || row.description || `${row.id}`
        }
    }

    copyObjectToMap(object, destMap) {
        if (!object || !destMap) {
            return destMap
        }

        Object.entries(object).forEach(([key, value]) => {
            if (key !== 'text' && key !== 'selected' && key !== 'select2Id' && key !== '$order') {
                destMap.set(key, value)
            }
        })
        return destMap
    }

    presenceLedUpdate(baseName, hasLabel) {
        const node = document.querySelector(`#${baseName}-presence`)
        if (!node) {
            return
        }
        node.classList.toggle('text-success', hasLabel)
        node.classList.toggle('text-danger', !hasLabel)
    }

    newLedUpdate(baseName, visible) {
        const node = document.querySelector(`#${baseName}-new`)
        if (!node) {
            return
        }
        node.classList.toggle('d-none', !visible)
    }

    setFieldValue(fieldId, value) {
        const node = document.querySelector(`#${fieldId}`)
        if (node) {
            node.value = value == null ? '' : value
        }
    }

    setOrCreateBoundOption(baseName, value, label = null) {
        const selectNode = document.querySelector(`#${baseName}_select`)
        if (!selectNode) {
            return
        }

        const resolvedLabel = label || this.findLabelForSelectValue(selectNode, value)

        if (selectNode.tomselect) {
            if (!selectNode.tomselect.options[value] && resolvedLabel) {
                selectNode.tomselect.addOption({
                    id: value,
                    text: resolvedLabel,
                    label: resolvedLabel
                })
            }
            selectNode.tomselect.setValue(value, true)
        } else {
            const existing = Array.from(selectNode.options).find((option) => `${option.value}` === `${value}`)
            if (!existing && resolvedLabel) {
                selectNode.appendChild(new Option(resolvedLabel, value))
            }
            selectNode.value = value
            selectNode.dispatchEvent(new Event('change', {
                bubbles: true
            }))
        }

        this.setFieldValue(`${baseName}_id`, value)
        this.setFieldValue(`${baseName}_label`, resolvedLabel || '')
        this.presenceLedUpdate(baseName, (resolvedLabel || '').length > 0)
    }

    findLabelForSelectValue(selectNode, value) {
        const option = Array.from(selectNode.options).find((node) => `${node.value}` === `${value}`)
        return option ? option.text : ''
    }

    handleSpecialCases(mapData) {
        const yearOfBirth = parseInt(mapData.get('year_of_birth'), 10)
        if (yearOfBirth > 0) {
            const categorySelect = document.querySelector('#category_type_select')
            if (categorySelect) {
                const age = new Date().getFullYear() - yearOfBirth
                const code = Math.floor(age / 5) * 5
                const option = Array.from(categorySelect.options).find((node) => (node.text || '').includes(`M${code}`))
                if (option) {
                    this.setOrCreateBoundOption('category_type', option.value, option.text)
                }
            }
        }

        if (mapData.get('gender_type_id') && document.querySelector('#gender_type_id')) {
            this.setFieldValue('gender_type_id', mapData.get('gender_type_id'))
        }

        if (mapData.get('city_id') && mapData.get('city')) {
            const city = mapData.get('city')
            this.setOrCreateBoundOption('city', mapData.get('city_id'), city.name)
            this.setFieldValue('city_country_code', city.country_code)
            this.setFieldValue('city_area', city.area)
        }

        if (mapData.get('pool_type_id') && mapData.get('pool_type')) {
            this.setFieldValue('pool_type_id', mapData.get('pool_type_id'))
        }
    }

    setHiddenFieldsValue(baseName, mapData) {
        if (!baseName || !mapData) {
            return
        }

        if (`${mapData.get('id')}` === `${mapData.get('label')}`) {
            mapData.set('id', 0)
            this.newLedUpdate(baseName, true)

            if (baseName.startsWith('swimming_pool') && mapData.get('label')) {
                this.setFieldValue('swimming_pool_name', mapData.get('label'))
                this.setFieldValue('swimming_pool_nick_name', '')
                this.setFieldValue('swimming_pool_city_id', '')
                this.setFieldValue('swimming_pool_pool_type_id', '')
            }
            if (baseName.startsWith('swimmer') && mapData.get('label')) {
                this.setFieldValue(`${baseName}_complete_name`, mapData.get('label'))
            }
        } else {
            this.newLedUpdate(baseName, false)
        }

        this.presenceLedUpdate(baseName, !!mapData.get('label'))
        const baseSelector = `${baseName}_`

        mapData.forEach((value, key) => {
            this.setFieldValue(`${baseSelector}${key}`, value)

            const boundSelectBaseName = key.split('_id')[0]
            const boundSelectNode = document.querySelector(`#${boundSelectBaseName}_select`)
            if (key.endsWith('_id') && key !== 'city_id' && boundSelectNode) {
                this.setOrCreateBoundOption(boundSelectBaseName, value)
            }

            if (!key.endsWith('_id') && key !== 'city' && value && value.id && document.querySelector(`#${key}_select`)) {
                const nestedMap = new Map()
                this.copyObjectToMap(value, nestedMap)
                nestedMap.set('label', value.label || value.name || value.description || '')
                this.setOrCreateBoundOption(key, value.id, nestedMap.get('label'))
                this.setHiddenFieldsValue(key, nestedMap)
            }
        })

        this.handleSpecialCases(mapData)
    }

    async enrichMapDataWithDetails(mapData) {
        if (!this.hasApiUrl2Value || !this.hasFieldBaseNameValue || parseInt(mapData.get('id'), 10) <= 0) {
            this.setHiddenFieldsValue(this.baseName, mapData)
            return
        }

        const jwt = await this.ensureJWT()
        const json = await this.fetchEntityDetails(jwt, this.fieldBaseNameValue, mapData.get('id'))
        json.label = mapData.get('label')
        this.copyObjectToMap(json, mapData)
        this.setHiddenFieldsValue(this.baseName, mapData)
    }

    async syncCurrentSelection() {
        if (!this.tomSelect) {
            return
        }

        const value = this.tomSelect.getValue()
        const scalarValue = Array.isArray(value) ? value[0] : value

        if (!scalarValue) {
            this.setHiddenFieldsValue(this.baseName, new Map([
                ['id', 0],
                ['label', '']
            ]))
            return
        }

        const selectedData = this.tomSelect.options[scalarValue]
        const mapData = new Map()
        mapData.set('id', scalarValue)
        mapData.set('label', selectedData?.text || selectedData?.label || '')
        this.copyObjectToMap(selectedData || {}, mapData)

        await this.enrichMapDataWithDetails(mapData)
    }
}