/**
 * = TimerElement =
 *
 * Simple Stop-watch / Timer / Chronometer widget.
 *
 * Assuming:
 * - 1 single timer & "LED"-like display per page
 * - unique "switch" (start/stop) & "reset" buttons per page
 * - 1 "lap" button x page (this may change in future)
 *
 *
 * == Basic behavior & usage ==
 * Use a Stimulus controller to import & connect this widget to the page.
 *
 * - "start" starts the timer and becomes "stop"
 * - "reset" can also act as "clear laps" using the triggered event
 * - "lap" yields the current timing, with about 1/100s of a second precision
 *
 *
 * == Widget DOM/Styles ==
 * The Widget requires to specify just just the DOM node that contains the timer digits.
 *
 *
 * == Base parameters ==
 * @param {HTMLElement} digitsElement the DOM node of which innerHTML contains the digits to be displayed (& updated)
 * @param {*} options any supported options (see below)
 *
 *
 * == Options ==
 * @param {boolean}   debug       toggle debug output to the console; default: false
 * @param {boolean}   showHours   true to display also the hours counter; default: false
 * @param {function}  onstart     *callback*: triggered on timer start
 * @param {function}  onreset     *callback*: triggered on timer reset
 * @param {function}  onstop      *callback*: triggered on timer stop, yields a "timing" object as parameter (*)
 * @param {function}  onlap       *callback*: triggered on lap timing measurement, yields a "timing" object as parameter (*)
 *
 * (*) The "timing" object parameter has members: { lap:, hours:, minutes:, seconds:, hundredths: };
 * - 'lap'.......: current lap index
 * - 'hours'.....: elapsed hours since start
 * - 'minutes'...: elapsed minutes since start
 * - 'seconds'...: elapsed seconds since start
 * - 'hundredths': elapsed hundredths of seconds since start
 *
 *
 * == References ==
 * - [Steve A.] most of original code
 * - inspired by: https://code-boxx.com/simple-javascript-stopwatch/
 */
export default class TimerElement {
  running = false

  constructor(digitsElement, options) {
    'use strict';
    // Options with defaults:
    options = options || {};

    // Properties:
    let debug = options.debug;
    let showHours = options.showHours || false;
    let divDigits = digitsElement;

    let timerObj = null; // timer object (from setInterval)
    let tickCount = 0;   // overall elapsed timer ticks from start
    let lapIndex = 0;
    let hours = 0;
    let mins = 0;
    let secs = 0;
    let hundredths = 0;

    if (debug) { console.log('TimerElement constructor') }

    /**
     * == clearTimerFields ==
     * Resets the internal timer fields
     */
    this.clearTimerFields = function () {
      if (debug) { console.log('clearTimerFields()') }
      tickCount = -1;
      lapIndex = 0;
      hours = 0;
      mins = 0;
      secs = 0;
      hundredths = 0;
    }

    /**
     * == updateTimerFields ==
     * Updates the internal timer fields given the "tickCount" value of the Timer object
     */
    this.updateTimerFields = function () {
      let remain = tickCount;
      hours = Math.floor(remain / 360_000);
      remain -= hours * 360_000;
      mins = Math.floor(remain / 6_000);
      remain -= mins * 6_000;
      secs = Math.floor(remain / 100);
      remain -= secs * 100;
      hundredths = remain;
    }

    /**
     * == readTimerFields ==
     * Returns an object with the current timer field values having format:
     *      { lap:, hours:, minutes:, seconds:, hundredths: }
     */
    this.readTimerFields = function () {
      lapIndex++;
      if (debug) { console.log(`readTimerFields() - current lap: ${lapIndex}`) }
      return {
        lap: lapIndex,
        hours: hours,
        minutes: mins,
        seconds: secs,
        hundredths: hundredths
      }
    }
    //-------------------------------------------------------------------------

    /**
     *   == handle Update ==
     */
    this.handleTickUpdate = function () {
      tickCount++;
      this.updateTimerFields();
      // Format digit strings:
      let ledHours = `${hours < 10 ? '0' + hours : hours}`
      let ledMins = `${mins < 10 ? '0' + mins : mins}`
      let ledSecs = `${secs < 10 ? '0' + secs : secs}`
      let ledHundredths = `${hundredths < 10 ? '0' + hundredths : hundredths}`
      divDigits.innerHTML = showHours ?
                            `${ledHours}:${ledMins}:${ledSecs}.${ledHundredths}` :
                            `${ledMins}:${ledSecs}.${ledHundredths}`;
    }.bind(this)

    /**
     *   == handle Start ==
     */
    this.handleStart = function () {
      if (debug) { console.log('handleStart') }
      this.running = true
      timerObj = setInterval(this.handleTickUpdate, 10);
      // Trigger event handler:
      if (options.onstart) {
        if (debug) { console.log('onstart triggered.') }
        options.onstart()
      }
    }.bind(this)
    //-------------------------------------------------------------------------

    /**
     *   == handle Lap ==
     */
    this.handleLap = function () {
      if (debug) { console.log('handleLap') }
      let timing = this.readTimerFields()
      // Trigger event handler:
      if (options.onlap) {
        if (debug) { console.log('onlap triggered.') }
        options.onlap(timing)
      }
    }.bind(this)
    //-------------------------------------------------------------------------

    /**
     *   == handle Stop ==
     */
    this.handleStop = function () {
      if (debug) { console.log('handleStop') }
      clearInterval(timerObj);
      timerObj = null;
      this.running = false
      let timing = this.readTimerFields()
      // Trigger event handler:
      if (options.onstop) {
        if (debug) { console.log('onstop triggered.') }
        options.onstop(timing)
      }
    }.bind(this)
    //-------------------------------------------------------------------------

    /**
     *   == handle Reset ==
     */
    this.handleReset = function () {
      if (debug) { console.log('handleReset') }
      if (timerObj != null) { this.handleStop() }
      // Clear timer fields:
      this.clearTimerFields();
      this.handleTickUpdate();
      // Trigger event handler:
      if (options.onreset) {
        if (debug) { console.log('onreset triggered.') }
        options.onreset()
      }
    }.bind(this)
    //-------------------------------------------------------------------------
  }
  //---------------------------------------------------------------------------
}
