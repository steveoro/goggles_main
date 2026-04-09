import {
    Controller
} from '@hotwired/stimulus'
import TimerElement from 'src/timer_element'

/**
 * = StimulusJS Chrono controller =
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
 * @param {String} 'data-chrono-lap-length'     => lap length in meters
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
    connect() {
        this.laps = []
        this.deleteEnabled = false

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
    }

    /**
     * Takes a timing object and returns the formatted label.
     */
    updateLabelTime(timing) {
        const labelMins = `${timing.minutes < 10 ? '0' + timing.minutes : timing.minutes}`
        const labelSecs = `${timing.seconds < 10 ? '0' + timing.seconds : timing.seconds}`
        const labelHundredths = `${timing.hundredths < 10 ? '0' + timing.hundredths : timing.hundredths}`
        return `${labelMins}'${labelSecs}"${labelHundredths}`
    }

    setupLapsGrid() {
        this.lapsGridTarget.innerHTML = ''
        this.gridTable = document.createElement('table')
        this.gridTable.className = 'table table-sm backgrid'
        this.gridTable.innerHTML = `
      <thead>
        <tr>
          <th>#</th>
          <th>min</th>
          <th>sec</th>
          <th>1/100</th>
          <th>m</th>
          <th>t</th>
          <th></th>
        </tr>
      </thead>
      <tbody></tbody>
    `
        this.gridBody = this.gridTable.querySelector('tbody')
        this.lapsGridTarget.append(this.gridTable)
        this.renderLapsGrid()
    }

    createNumericInput(value, min, max, onChange) {
        const input = document.createElement('input')
        input.type = 'number'
        input.className = 'form-control form-control-sm'
        input.value = value
        input.min = min
        input.max = max
        input.addEventListener('input', onChange)
        return input
    }

    renderLapsGrid() {
        this.gridBody.innerHTML = ''

        if (this.laps.length < 1) {
            const emptyRow = document.createElement('tr')
            emptyRow.className = 'empty'
            const cell = document.createElement('td')
            cell.colSpan = 7
            cell.textContent = '- - -'
            emptyRow.append(cell)
            this.gridBody.append(emptyRow)
            return
        }

        this.laps.forEach((lap, index) => {
            const row = document.createElement('tr')

            const orderCell = document.createElement('td')
            orderCell.textContent = `${lap.order}`
            row.append(orderCell)

            const minutesCell = document.createElement('td')
            minutesCell.append(this.createNumericInput(
                lap.minutes, 0, 99,
                (event) => this.updateLapField(index, 'minutes', event.target.value)
            ))
            row.append(minutesCell)

            const secondsCell = document.createElement('td')
            secondsCell.append(this.createNumericInput(
                lap.seconds, 0, 59,
                (event) => this.updateLapField(index, 'seconds', event.target.value)
            ))
            row.append(secondsCell)

            const hundredthsCell = document.createElement('td')
            hundredthsCell.append(this.createNumericInput(
                lap.hundredths, 0, 99,
                (event) => this.updateLapField(index, 'hundredths', event.target.value)
            ))
            row.append(hundredthsCell)

            const metersCell = document.createElement('td')
            metersCell.append(this.createNumericInput(
                lap.meters, 0, 99999,
                (event) => this.updateLapField(index, 'meters', event.target.value)
            ))
            row.append(metersCell)

            const labelCell = document.createElement('td')
            labelCell.textContent = lap.labelTime
            row.append(labelCell)

            const actionCell = document.createElement('td')
            const deleteBtn = document.createElement('button')
            deleteBtn.type = 'button'
            deleteBtn.className = 'btn btn-xs btn-outline-danger btn-delete-lap'
            deleteBtn.textContent = 'X'
            deleteBtn.disabled = !this.deleteEnabled
            deleteBtn.addEventListener('click', () => this.deleteLap(index))
            actionCell.append(deleteBtn)
            row.append(actionCell)

            this.gridBody.append(row)
        })
    }

    updateLapField(index, field, value) {
        const lap = this.laps[index]
        if (!lap) {
            return
        }
        lap[field] = parseInt(value, 10) || 0
        lap.labelTime = this.updateLabelTime(lap)
        this.renderLapsGrid()
    }

    deleteLap(index) {
        const lap = this.laps[index]
        if (!lap) {
            return
        }
        const confirmMessage = this.data.get('delete-message') || 'Delete lap?'
        if (confirm(`${confirmMessage}\r\n(${lap.labelTime})`)) {
            this.laps.splice(index, 1)
            this.renderLapsGrid()
        }
    }

    /**
     * == start/Stop action ==
     * Toggles between starting & stopping the timer, depending on current timer widget state.
     */
    startStop(_event) {
        if (this.timerWidget.running) {
            this.stop()
        } else {
            this.start()
        }
    }

    /**
     * == Reset action ==
     */
    reset(_event) {
        if (confirm(this.data.get('reset-message'))) {
            this.timerWidget.handleReset()
            // Disable "save" button:
            if (this.hasBtnSaveTarget) {
                this.btnSaveTarget.setAttribute('disabled', 'true')
                if (this.hasBtnDownloadJSONTarget) {
                    this.btnDownloadJSONTarget.classList.add('disabled')
                }
            }
        }
    }

    /**
     * == Start action ==
     */
    start(_event) {
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
            if (this.hasBtnDownloadJSONTarget) {
                this.btnDownloadJSONTarget.classList.add('disabled')
            }
        }
    }

    /**
     * == Stop action ==
     */
    stop(_event) {
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
            if (this.hasBtnDownloadJSONTarget) {
                this.btnDownloadJSONTarget.classList.remove('disabled')
            }
        }
    }

    /**
     * == Lap action ==
     */
    lap(_event) {
        this.timerWidget.handleLap()
    }

    /**
     * == Save action ==
     * Prepares an array of stringified JSON detail rows to be set at form payload
     * and triggers the data submit.
     */
    save(_event) {
        _event.preventDefault()

        if (confirm(this.data.get('post-message')) && this.hasPayloadTarget) {
            // Prepare payload:
            const dataPayload = this.laps.map((lap) => {
                return {
                    order: lap.order,
                    minutes: 0,
                    seconds: 0,
                    hundredths: 0,
                    minutes_from_start: lap.minutes,
                    seconds_from_start: lap.seconds,
                    hundredths_from_start: lap.hundredths,
                    length_in_meters: lap.meters,
                    label: lap.labelTime
                }
            })
            this.payloadTarget.value = JSON.stringify(dataPayload)

            // Post & Save data:
            if (this.hasMainFormTarget) {
                this.mainFormTarget.submit()
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
    downloadJSON(_event) {
        _event.preventDefault()

        if ((this.laps.length < 1) ||
            (this.hasHeaderTarget && this.headerTarget.value.toString().length < 1)) {
            console.log('No data to export: skipping')
            return false
        }

        // Prepare payload:
        const dataPayload = this.laps.map((lap) => {
            const jsonHeader = JSON.parse(this.headerTarget.value)
            jsonHeader.order = lap.order
            jsonHeader.label = lap.labelTime
            jsonHeader.lap.order = lap.order
            jsonHeader.lap.minutes = 0
            jsonHeader.lap.seconds = 0
            jsonHeader.lap.hundredths = 0
            jsonHeader.lap.minutes_from_start = lap.minutes
            jsonHeader.lap.seconds_from_start = lap.seconds
            jsonHeader.lap.hundredths_from_start = lap.hundredths
            jsonHeader.lap.length_in_meters = lap.meters
            jsonHeader.lap.label = lap.labelTime
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
    afterStart() {
        // DEBUG
        // console.log(`afterStart()`)

        // (no-op)
    }

    /**
     * "onreset" controller handler, called from the corresponding widget event
     */
    afterReset() {
        this.laps = []
        this.deleteEnabled = false
        this.renderLapsGrid()
    }

    /**
     * "onstop" controller handler, called from the corresponding widget event
     * @param {Object} timing  an object with the current timer field values having format:
     *                         { order:, hours:, minutes:, seconds:, hundredths: }
     */
    afterStop(timing) {
        // Add the final lap row:
        this.afterLap(timing)
        this.deleteEnabled = true
        this.renderLapsGrid()
    }

    /**
     * "onlap" controller handler, called from the corresponding widget event
     * @param {Object} timing  an object with the current timer field values having format:
     *                         { order:, hours:, minutes:, seconds:, hundredths: }
     */
    afterLap(timing) {
        if (!this.hasLapsGridTarget) {
            return
        }
        const lengthInMt = parseInt(this.data.get('lap-length'), 10) || 50
        this.laps.push({
            order: timing.order,
            hours: timing.hours,
            minutes: timing.minutes,
            seconds: timing.seconds,
            hundredths: timing.hundredths,
            meters: timing.order * lengthInMt,
            labelTime: this.updateLabelTime(timing)
        })
        this.renderLapsGrid()
    }
}