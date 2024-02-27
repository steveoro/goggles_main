/**
 * = SwipeElement =
 *
 * Manages an horizontal swipe-enabled DOM node. Triggers callbacks depending on swipe direction.
 *
 * This manager class is "widget agnostic" in the sense that it doesn't need to know or impose much
 * of the layout of the container element -- see below for the only limit on CSS styles.
 *
 *
 * == Basic behavior & usage ==
 * Use a Stimulus controller to import & connect this widget to the page.
 *
 * The container node is animated and moved toward the swipe direction until it disappears from
 * the side border.
 *
 * The suggested follow-up behavior would be to either replace externally the whole container element
 * or programmatically update its contents and then reset its position with @see resetPosition()
 * during the gesture callbacks.
 *
 *
 * === Supported features:
 * - swiping back & forth through different data pages;
 * - sets & updates an internal continuous index for the current data page to be shown (if any);
 * - page-wrapping at the end.
 *
 *
 * == Events: ==
 * All called with the current dataIndex value (can be ignored if not needed by the callback):
 * - onswipeleft(dataIndex)
 * - onswiperight(dataIndex)
 *
 *
 * == Widget DOM/Styles ==
 * No required structure or style names; just set the following style to disable the native handlers.
 * Minimal requirement:
 * - element/container node => must set the following CSS property to either one of these:
 *   - "touch-action: pan-y pinch-zoom;" => capture horizontal events with Javascript
 *   - "touch-action: none;" => capture *all* events
 *
 *
 * == Base parameters ==
 * @param {*} element,  the DOM node in the foreground that has to be moved left or right
 * @param {*} options,  any supported options (see below)
 *
 *
 * == Options ==
 * @param {Number}    index,        current index/data page displayed; default: 1
 * @param {Number}    total,        total available index/pages count; default: 1
 * @param {boolean}   continuous,   swiping will wrap against range limits (1..total); default: false
 * @param {boolean}   enableLeft,   enable swipe-left; default: false
 * @param {boolean}   enableRight,  enable swipe-right; default: false
 * @param {boolean}   debug,        toggle debug output to the console; default: false
 * @param {function}  onswipeleft,  *callback*: swipe-left gesture performed
 * @param {function}  onswiperight, *callback*: swipe-right gesture performed
 *
 *
 * == References ==
 * - [Steve A.] most of original code
 * - Low-level touch support code & idea adapted from: https://developers.google.com/web/fundamentals/design-and-ux/input/touch
 */
export default class SwipeElement {
  constructor (element, options) {
    'use strict'
    // Global state variables
    const STATE_DEFAULT = 1
    const STATE_SWEPT_LEFT = 2
    const STATE_SWEPT_RIGHT = 3

    const swipeElement = element
    let reqAnimFrmPending = false
    let initialTouchPos = null
    let lastTouchPos = null
    let currentXPosition = 0
    let currentState = STATE_DEFAULT

    // == Options with defaults ==
    options = options || {}
    const continuous = options.continuous
    const enableLeft = options.enableLeft
    const enableRight = options.enableRight
    const debug = options.debug
    const totalIndex = options.total || 1
    let currentIndex = options.index || 1
    // DEBUG
    if (debug) {
      console.log(`new SwipeElement(idx: ${currentIndex}/${totalIndex})`)
    }

    // Perform client width here as this can be expensive and doesn't change until window.onresize:
    let itemWidth = swipeElement.clientWidth
    let slopeValue = itemWidth * (1 / 4)
    // DEBUG
    if (debug) {
      console.log(`itemWidth: ${itemWidth}, slopeValue: ${slopeValue})`)
    }

    // On resize, change the slope value:
    this.resize = function () {
      itemWidth = swipeElement.clientWidth
      slopeValue = itemWidth * (1 / 4)
    }

    window.requestAnimFrameMultiBrowser = (function () {
      return window.requestAnimationFrame ||
        window.webkitRequestAnimationFrame ||
        window.mozRequestAnimationFrame ||
        function (callback) {
          window.setTimeout(callback, 1000 / 60)
        }
    })()
    // ------------------------------------------------------------------------

    /**
     * SwipeElement: handleGestureStart
     *
     * Handles the start of gestures, storing starting coordinates
     */
    this.handleGestureStart = function (evt) {
      evt.preventDefault()

      if (evt.touches && evt.touches.length > 1) {
        return
      }

      if (window.PointerEvent) { // Add the move and end listeners
        evt.target.setPointerCapture(evt.pointerId)
      } else { // Add Mouse Listeners
        document.addEventListener('mousemove', this.handleGestureMove, true)
        document.addEventListener('mouseup', this.handleGestureEnd, true)
      }

      initialTouchPos = getGesturePointFromEvent(evt)
      swipeElement.style.transition = 'initial'
    }.bind(this)

    /**
     * SwipeElement: handleGestureMove
     *
     * Handles move gestures
     */
    this.handleGestureMove = function (evt) {
      evt.preventDefault()
      if (!initialTouchPos) {
        return
      }

      lastTouchPos = getGesturePointFromEvent(evt)
      if (reqAnimFrmPending) { // Animation frame requested and pending?
        return
      }

      reqAnimFrmPending = true
      window.requestAnimFrameMultiBrowser(onAnimFrame)
    }

    /**
     * SwipeElement: handleGestureEnd
     *
     * Handles end gestures
     */
    this.handleGestureEnd = function (evt) {
      evt.preventDefault()
      if (evt.touches && evt.touches.length > 0) {
        return
      }

      reqAnimFrmPending = false

      if (window.PointerEvent) { // Remove Event Listeners
        evt.target.releasePointerCapture(evt.pointerId)
      } else { // Remove Mouse Listeners
        document.removeEventListener('mousemove', this.handleGestureMove, true)
        document.removeEventListener('mouseup', this.handleGestureEnd, true)
      }

      updateSwipeRestPosition()

      initialTouchPos = null
    }.bind(this)

    /**
     * SwipeElement: resetPosition
     *
     * Clears CSS transition & transform, so that the element node returns immediately
     * visible at the center.
     */
    this.resetPosition = function () {
      if (debug) {
        console.log('resetPosition')
      }
      swipeElement.style.transition = 'all 0ms linear' // make it snappy
      changeState(STATE_DEFAULT)
    }

    /**
     * SwipeElement: updateSwipeRestPosition
     *
     * State-automata for swipeElement transition to destination state (and position)
     */
    function updateSwipeRestPosition () {
      const differenceInX = initialTouchPos && lastTouchPos ? initialTouchPos.x - lastTouchPos.x : 0
      currentXPosition = currentXPosition - differenceInX

      // Go to the default state and change according to gesture:
      let newState = STATE_DEFAULT

      // Check if we need to change state to left or right based on slope value
      if (Math.abs(differenceInX) > slopeValue) {
        if (currentState === STATE_DEFAULT) {
          if (enableLeft && differenceInX > 0) {
            newState = STATE_SWEPT_LEFT
            currentIndex++ // Update data index
            // DEBUG
            if (debug) {
              console.log(`currentIndex: ${currentIndex}, totalIndex: ${totalIndex}`)
            }
            if (currentIndex > totalIndex) {
              currentIndex = continuous ? 1 : currentIndex
            }
            // Trigger event handler:
            if (options.onswipeleft) {
              // DEBUG
              if (debug) {
                console.log('onswipeleft triggered.')
              }
              options.onswipeleft(currentIndex)
            }
          } else if (enableRight && differenceInX < 0) {
            newState = STATE_SWEPT_RIGHT
            currentIndex-- // Update data index
            // DEBUG
            if (debug) {
              console.log(`currentIndex: ${currentIndex}, totalIndex: ${totalIndex}`)
            }
            if (currentIndex < 1) {
              currentIndex = continuous ? totalIndex : 1
            }
            // Trigger event handler:
            if (options.onswiperight) {
              // DEBUG
              if (debug) {
                console.log('onswiperight triggered.')
              }
              options.onswiperight(currentIndex)
            }
          }
        } else {
          if (currentState === STATE_SWEPT_LEFT && differenceInX > 0) {
            newState = STATE_DEFAULT
          } else if (currentState === STATE_SWEPT_RIGHT && differenceInX < 0) {
            newState = STATE_DEFAULT
          }
        }
      } else {
        newState = currentState
      }

      changeState(newState)
      swipeElement.style.transition = 'all 150ms ease-out'
    }

    /**
     * SwipeElement: changeState
     *
     * Internal swipe state setter (sets also transform & translateX)
     * @param {*} newState the destination logic state associated to the swipe gesture
     */
    function changeState (newState) {
      switch (newState) {
        case STATE_DEFAULT:
          currentXPosition = 0
          break
        case STATE_SWEPT_LEFT:
          currentXPosition = '-110%'
          break
        case STATE_SWEPT_RIGHT:
          currentXPosition = '110%'
          break
      }
      const transformStyle = `translateX(${currentXPosition})`
      swipeElement.style.msTransform = transformStyle
      swipeElement.style.MozTransform = transformStyle
      swipeElement.style.webkitTransform = transformStyle
      swipeElement.style.transform = transformStyle
      currentState = newState
    }

    /**
     * SwipeElement: getGesturePointFromEvent
     *
     * Computes actual client coordinates
     * @param {*} evt the touch/mouse/pointer event
     * @returns a point object having x & y member values
     */
    function getGesturePointFromEvent (evt) {
      const point = {}

      if (evt.targetTouches) {
        point.x = evt.targetTouches[0].clientX
        point.y = evt.targetTouches[0].clientY
      } else {
        // Either Mouse event or Pointer Event
        point.x = evt.clientX
        point.y = evt.clientY
      }
      return point
    }

    /**
     * SwipeElement: onAnimFrame
     *
     * Update & transform coordinates for swipeElement during animation frames
     */
    function onAnimFrame () {
      if (!reqAnimFrmPending) { // No requested animation frame pending?
        return
      }

      const differenceInX = initialTouchPos.x - lastTouchPos.x
      const newXTransform = (currentXPosition - differenceInX) + 'px'
      const transformStyle = 'translateX(' + newXTransform + ')'
      swipeElement.style.webkitTransform = transformStyle
      swipeElement.style.MozTransform = transformStyle
      swipeElement.style.msTransform = transformStyle
      swipeElement.style.transform = transformStyle
      reqAnimFrmPending = false
    }

    /**
     * Add event listeners for the above functions
     */
    // Check if pointer events are supported.
    if (window.PointerEvent) {
      // Add Pointer Event Listener
      swipeElement.addEventListener('pointerdown', this.handleGestureStart, true)
      swipeElement.addEventListener('pointermove', this.handleGestureMove, true)
      swipeElement.addEventListener('pointerup', this.handleGestureEnd, true)
      swipeElement.addEventListener('pointercancel', this.handleGestureEnd, true)
    } else {
      // Add Touch Listener
      swipeElement.addEventListener('touchstart', this.handleGestureStart, true)
      swipeElement.addEventListener('touchmove', this.handleGestureMove, true)
      swipeElement.addEventListener('touchend', this.handleGestureEnd, true)
      swipeElement.addEventListener('touchcancel', this.handleGestureEnd, true)

      // Add Mouse Listener
      swipeElement.addEventListener('mousedown', this.handleGestureStart, true)
    }
  }
}
// ----------------------------------------------------------------------------
