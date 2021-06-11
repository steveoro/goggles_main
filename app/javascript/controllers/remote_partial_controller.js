import { Controller } from 'stimulus'
import $ from 'jquery'

/**
 * = StimulusJS simple remote partial update controller =
 *
 * Generic helper to update any target DOM id with an HTML text
 * retrieved through a PUT request URL.
 *
 * The payload for the request is gathered by looping on each node having
 * the 'data-remote-partial-payload' flag set to true and mapping its name & value
 * pair found as body of the PUT request.
 *
 * This allows for any set of input fields to trigger a remote partial update upon
 * specific trigger actions.
 *
 *
 * == Targets ==
 * @param {String} 'data-remote-partial-target': 'text'
 *                 identifies the target node: its innerHTML will be replaced by the update.
 *
 *
 * == Values ==
 * (no static values)
 * Uses simple 'data' attributes:
 *
 * @param {String}  'data-remote-partial-url' => PUT request URL to be invoked
 *
 * @param {Boolean} 'data-remote-partial-payload'
 *                  'true' => use this field name & value as payload parameter
 *
 *
 * == Actions:
 * Fields triggering the update should bind to:
 *    - '<EVENT>->remote-partial#update', with <EVENT> being any triggered event (i.e. 'change',
 *      'input', 'click', ...)
 *
 * @author Steve A.
 */
export default class extends Controller {
  static targets = ['text']

  /**
   * Sets up the controller.
   * (Called whenever the controller instance connects to the DOM)
   */
  connect () {
    // DEBUG
    // console.log('Connecting remote-partial...')
  }

  /**
   * Invokes a partial update from a PUT request url given a specific payload;
   * the target node's innerHTML will be replaced with the response text.
   *
   * The payload is built using the flagged field node names & values.
   *
   * == Params:
   * @param {Object} _event (unused)
   */
  update (_event) {
    if (!this.hasTextTarget || (this.hasTextTarget && this.textTarget.disabled)) {
      // DEBUG
      // console.log('No target or disabled: skipping.')
      return
    }

    const reqURL = this.data.get('url'); const payload = this.buildPayload()
    // DEBUG
    // console.log('reqURL:', reqURL)

    fetch(reqURL,
      {
        method: 'PUT',
        headers: {
          'X-CSRF-Token': $('meta[name=csrf-token]').attr('content'),
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(payload)
      })
      .then(res => { return Promise.resolve(res.text()) })
      .then(txt => {
        // DEBUG
        console.log(txt)
        this.textTarget.innerHTML = txt
      })
  }
  // ---------------------------------------------------------------------------

  /**
   * Assuming the payload fields come from a form (typical input field name format: "model_name[field_name]"),
   * all the flagged fields are collected and a composed object is built from their names, resulting in a
   * { "model_name" => {"fields attributes list"} } nested structure.
   *
   * In Rails controllers, this translates to a params hash in which the "model_name" can be 'required' and the
   * field name list can be permitted.
   *
   * @returns the object payload composed for the PUT request.
   */
  buildPayload () {
    const payloadNodes = $('[data-remote-partial-payload="true"]').toArray()
    const modelObjName = payloadNodes[0].name.split(/\[(.+)\]/)[0] // get just the 'model' part
    const attributesObj = {}
    let attrObjName = ''
    const resultObj = {}

    payloadNodes.forEach(node => {
      attrObjName = node.name.split(/\[(.+)\]/)[1] // get the part in between brackets
      attributesObj[attrObjName] = node.value
    })
    resultObj[modelObjName] = attributesObj
    // i.e.: { user: { first_name 'dude', last_name: 'whatever' } }

    // DEBUG
    // console.log('buildPayload() =>', resultObj)

    return resultObj
  }
}
