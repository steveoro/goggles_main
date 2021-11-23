import { Controller } from 'stimulus'
import TimerElement from '../src/timer_element'
import Backbone from 'backbone'
import Backgrid from 'backgrid'
import $ from 'jquery'

// Row data model:
const Timing = Backbone.Model.extend({
  defaults: {
    order: 0,
    hours: 0, // (not currently used)
    minutes: 0,
    seconds: 0,
    hundredths: 0,
    meters: 0,
    labelOverall: '',
    trash: 'x',
    gridRef: null // internal reference
  }
})
// -----------------------------------------------------------------------------

/**
 * = StimulusJS Search-browse/swipe controller =
 *
 * Uses the TimerElement class to manage Lap timing measurements.
 *
 * @see /app/controllers/chrono_controller.rb
 * @see /app/javascript/src/timer_element.js
 *
 *
 * == Targets ==
 * @param {String} 'data-chrono-target': 'timer'
 *                 DOM node for the timer ("LED") display
 *
 * @param {String} 'data-chrono-target': 'lapsGrid'
 *                 DOM node for the laps table
 *
 * @param {String} 'data-chrono-target': 'btnSwitch'
 *                 DOM "start/stop" button
 *
 * @param {String} 'data-chrono-target': 'btnLap'
 *                 DOM "lap" button
 *
 * @param {String} 'data-chrono-target': 'btnSave'
 *                 DOM "save" button
 *
 * @param {String} 'data-chrono-target': 'btnDownloadJSON'
 *                 DOM "download JSON" button
 *
 * @param {String} 'data-chrono-target': 'header'
 *                 DOM field tag that stores the common JSON data header for all laps
 *
 * @param {String} 'data-chrono-target': 'payload'
 *                 DOM field tag for storing the data payload as JSON text
 *
 * @param {String} 'data-chrono-target': 'mainForm'
 *                 DOM form used to POST the payload
 *
 *
 * == Values ==
 * (no static values)
 * Uses simple 'data' attributes:
 * @param {String} 'data-chrono-delete-message' => confirmation message shown before delete
 * @param {String} 'data-chrono-post-message'   => confirmation message shown before post/save
 * @param {String} 'data-chrono-reset-message'  => confirmation message shown before reset
 *
 *
 * == Assumptions:
 * @assert only 1 TimerElement widget per page
 *
 * @author Steve A.
 */
export default class extends Controller {
  static targets = [
    'timer', 'lapsGrid',
    'btnSwitch', 'btnLap', 'btnSave', 'btnDownloadJSON',
    'header', 'payload', 'mainForm'
  ]

  /**
   * Initialization boilerplate for the TimerElement.
   */
  connect () {
    // DEBUG
    // console.log('Connecting ChronoController...')

    if (this.hasTimerTarget && this.hasLapsGridTarget) {
      this.timerWidget = new TimerElement(this.timerTarget, {
        // Options:
        // debug: true,
        showHours: false,

        // Callbacks:
        onstart: () => {
          this.afterStart()
        },
        onreset: () => {
          this.afterReset()
        },
        onlap: (timing) => {
          this.afterLap(timing)
        },
        onstop: (timing) => {
          this.afterStop(timing)
        }
      })
      this.setupLapsGrid()
    }

    /**
     * Takes a "timing" object or a Timing model with compatible field names and
     * returns the formatted labelTime string field.
     */
    this.updateLabelTime = function (timing) {
      // DEBUG
      // console.log('updateLabelTime()')
      // console.log(this)
      // console.log(timing)

      // Format digit strings:
      // let labelHours = `${timing.hours < 10 ? '0' + timing.hours : timing.hours}` // (unused)
      const labelMins = `${timing.minutes < 10 ? '0' + timing.minutes : timing.minutes}`
      const labelSecs = `${timing.seconds < 10 ? '0' + timing.seconds : timing.seconds}`
      const labelHundredths = `${timing.hundredths < 10 ? '0' + timing.hundredths : timing.hundredths}`
      return `${labelMins}'${labelSecs}"${labelHundredths}`
    }
  }
  // ---------------------------------------------------------------------------

  /**
   * == initLapGrid() ==
   * Setup laps grid
   */
  setupLapsGrid () {
    const LapTimings = Backbone.Collection.extend({
      model: Timing
    })
    const lapTimings = new LapTimings()
    const confirmMessage = this.data.get('delete-message')
    const columns = [
      {
        name: 'order', // The key of the model attribute
        label: '#', // The name to display in the header
        // editable: true,  // (By default every cell in a column is editable)
        sortable: true,
        // Defines a cell type, and ID is displayed as an integer without the ',' separating 1000s.
        cell: Backgrid.IntegerCell.extend({ orderSeparator: '' })
      },
      /* ( not currently shown: )
      {
        name: "hours",
        label: "h",
        sortable: false,
        // The cell type can be a reference of a Backgrid.Cell subclass, any Backgrid.Cell subclass instances like *id* above, or a string
        // An integer cell is a number cell that displays humanized integers
        cell: "integer" // This is converted to "StringCell" and a corresponding class in the Backgrid package namespace is looked up
      },
      */
      {
        name: 'minutes',
        label: 'min',
        sortable: false,
        cell: Backgrid.IntegerCell.extend({ orderSeparator: '' })
      },
      {
        name: 'seconds',
        label: 'sec',
        sortable: false,
        cell: Backgrid.IntegerCell.extend({ orderSeparator: '' })
      },
      {
        name: 'hundredths',
        label: '1/100',
        sortable: false,
        cell: Backgrid.IntegerCell.extend({ orderSeparator: '' })
      },
      {
        name: 'meters',
        label: 'm',
        sortable: false,
        cell: Backgrid.IntegerCell.extend({ orderSeparator: '' })
      },
      {
        name: 'labelTime',
        label: 't',
        editable: false,
        sortable: false,
        cell: 'string'
      },
      {
        name: 'trash',
        label: '',
        editable: false,
        sortable: false,
        cell: Backgrid.StringCell.extend({
          render: function () {
            const btn = $('<button>', {
              tabIndex: -1,
              class: 'btn btn-xs btn-outline-danger btn-delete-lap',
              disabled: true,
              text: 'X',
              role: 'button'
            })
            const cid = this.model.cid
            const rowAttr = this.model.attributes
            btn.on('click', function () {
              if (confirm(`${confirmMessage}\r\n(${rowAttr.labelTime})`)) {
                const modelRow = rowAttr.gridRef.collection.get(cid)
                rowAttr.gridRef.removeRow(modelRow)
              }
            })
            this.$el.empty()
            this.$el.append(btn)
            this.delegateEvents()
            return this
          }
        })
      }
    ]

    // Initialize the Grid instance:
    this.grid = new Backgrid.Grid({
      columns: columns,
      collection: lapTimings,
      emptyText: '- - -'
    })

    // Render the grid and attach the root of the target node:
    this.lapsGridTarget.append(this.grid.render().el)
  }
  // ---------------------------------------------------------------------------

  /**
   * == start/Stop action ==
   * Toggles between starting & stopping the timer, depending on current timer widget state.
   */
  startStop (_event) {
    if (this.timerWidget.running) {
      this.stop()
    } else {
      this.start()
    }
  }

  /**
   * == Reset action ==
   */
  reset (_event) {
    if (confirm(this.data.get('reset-message'))) {
      this.timerWidget.handleReset()
      // Disable "save" button:
      if (this.hasBtnSaveTarget) {
        this.btnSaveTarget.setAttribute('disabled', 'true')
        this.btnDownloadJSONTarget.classList.add('disabled')
      }
    }
  }

  /**
   * == Start action ==
   */
  start (_event) {
    this.timerWidget.handleStart()
    // Toggle "start" label into "stop":
    if (this.hasBtnSwitchTarget) {
      this.btnSwitchTarget.classList.add('btn-outline-warning')
      this.btnSwitchTarget.classList.remove('btn-outline-success')
      this.btnSwitchTarget.innerHTML = '<span><i class="fa fa-stop"></i> STOP</span>'
    }
    // Enable "lap" button:
    if (this.hasBtnLapTarget) {
      this.btnLapTarget.removeAttribute('disabled')
    }
    // Disable "save" button:
    if (this.hasBtnSaveTarget) {
      this.btnSaveTarget.setAttribute('disabled', 'true')
      this.btnDownloadJSONTarget.classList.add('disabled')
    }
  }

  /**
   * == Stop action ==
   */
  stop (_event) {
    this.timerWidget.handleStop()
    // Toggle "stop" label into "start":
    if (this.hasBtnSwitchTarget) {
      this.btnSwitchTarget.classList.add('btn-outline-success')
      this.btnSwitchTarget.classList.remove('btn-outline-warning')
      this.btnSwitchTarget.innerHTML = '<span><i class="fa fa-play"></i> START</span>'
    }
    // Disable "lap" button:
    if (this.hasBtnLapTarget) {
      this.btnLapTarget.setAttribute('disabled', 'true')
    }
    // Enable "save" button:
    if (this.hasBtnSaveTarget) {
      this.btnSaveTarget.removeAttribute('disabled')
      this.btnDownloadJSONTarget.classList.remove('disabled')
    }
  }

  /**
   * == Lap action ==
   */
  lap (_event) {
    this.timerWidget.handleLap()
  }

  /**
   * == Save action ==
   * Prepares an array of stringified JSON detail rows to be set at form payload
   * and triggers the data submit.
   */
  save (_event) {
    // DEBUG
    // console.log('save() action')
    _event.preventDefault()

    if (confirm(this.data.get('post-message')) && this.hasPayloadTarget) {
      // Prepare payload:
      const dataPayload = this.grid.collection.map((model) => {
        return {
          order: model.attributes.order,
          minutes: 0,
          seconds: 0,
          hundredths: 0,
          minutes_from_start: model.attributes.minutes,
          seconds_from_start: model.attributes.seconds,
          hundredths_from_start: model.attributes.hundredths,
          length_in_meters: model.attributes.meters,
          label: model.attributes.labelTime
        }
      })
      $(this.payloadTarget).val(JSON.stringify(dataPayload))

      // Post & Save data:
      if (this.hasMainFormTarget) {
        $(this.mainFormTarget).trigger('submit')
      }
      return true
    }
    return false
  }
  // ---------------------------------------------------------------------------

  /**
   * == Download JSON action ==
   * Prepares an array of JSON objects and initiates the text data file download.
   * Assumes 'json_header' contains valid JSON data.
   */
  downloadJSON (_event) {
    // DEBUG
    // console.log('downloadCsv() action')
    _event.preventDefault()

    if ((this.grid.collection.length < 1) ||
      (this.hasHeaderTarget && this.headerTarget.value.toString().length < 1)) {
      console.log('No data to export: skipping')
      return false
    }

    // Prepare payload:
    const dataPayload = this.grid.collection.map((model) => {
      const jsonHeader = JSON.parse(this.headerTarget.value)
      jsonHeader.order = model.attributes.order
      jsonHeader.label = model.attributes.labelTime
      jsonHeader.lap.order = model.attributes.order
      jsonHeader.lap.minutes = 0
      jsonHeader.lap.seconds = 0
      jsonHeader.lap.hundredths = 0
      jsonHeader.lap.minutes_from_start = model.attributes.minutes
      jsonHeader.lap.seconds_from_start = model.attributes.seconds
      jsonHeader.lap.hundredths_from_start = model.attributes.hundredths
      jsonHeader.lap.length_in_meters = model.attributes.meters
      jsonHeader.lap.label = model.attributes.labelTime
      return jsonHeader
    })

    // Post & Save data:
    const hiddenElement = document.createElement('a')
    const stringifiedData = JSON.stringify(dataPayload)
    hiddenElement.href = `data:text/json;charset=utf-8,${encodeURI(stringifiedData)}`
    hiddenElement.target = '_blank'
    hiddenElement.download = `chrono_${dataPayload[0].lap.meeting_program.meeting_event.meeting_session.scheduled_date}.json`
    hiddenElement.click()
    return true
  }
  // ---------------------------------------------------------------------------

  /**
   * "onstart" controller handler, called from the corresponding widget event
   */
  afterStart () {
    // DEBUG
    // console.log(`afterStart()`)

    // (no-op)
  }

  /**
   * "onreset" controller handler, called from the corresponding widget event
   */
  afterReset () {
    // DEBUG
    // console.log(`afterReset()`)

    // Erase all lap rows:
    if (this.hasLapsGridTarget) {
      this.grid.remove()
      this.setupLapsGrid()
    }
  }

  /**
   * "onstop" controller handler, called from the corresponding widget event
   * @param {Object} timing  an object with the current timer field values having format:
   *                         { order:, hours:, minutes:, seconds:, hundredths: }
   */
  afterStop (timing) {
    // DEBUG
    // console.log(`afterStop()`)

    // Add the final lap row:
    this.afterLap(timing)
    $('.btn-delete-lap').removeAttr('disabled')
  }

  /**
   * "onlap" controller handler, called from the corresponding widget event
   * @param {Object} timing  an object with the current timer field values having format:
   *                         { order:, hours:, minutes:, seconds:, hundredths: }
   */
  afterLap (timing) {
    // DEBUG
    // console.log(`afterLap()`)

    // Add a new lap row:
    if (this.hasLapsGridTarget) {
      const lapTimeModel = new Timing({
        order: timing.order,
        hours: timing.hours,
        minutes: timing.minutes,
        seconds: timing.seconds,
        hundredths: timing.hundredths,
        meters: timing.order * 25, // Use a default minimum step, since the recordings can be user-edited
        labelTime: this.updateLabelTime(timing),
        gridRef: this.grid
      })
      // Bind change events to cell updates:
      lapTimeModel.on(
        'change:hours change:minutes change:seconds change:hundredths',
        (model) => { model.set('labelTime', this.updateLabelTime(model.attributes)) },
        this
      )

      this.grid.insertRow([lapTimeModel])
    }
  }
}
