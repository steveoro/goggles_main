import { Controller } from '@hotwired/stimulus'
import SwipeElement from '../src/swipe_element'

/**
 * = StimulusJS Search-browse/swipe controller =
 *
 * Uses the SwipeElement class to handle swipe gestures for a target node.
 * Swipe on target left or right to toggle pagination requests in "raw" mode.
 *
 * @see /app/controllers/search_controller.rb
 * @see /app/javascript/src/swipe_element.js
 *
 * == Targets ==
 * @param {String} 'data-search-target': 'swiper'
 *                 wrapper DOM node that receives swipe gestures & displays results
 *
 * == Values ==
 * @param {String} 'data-search-current-value' => current results data page
 * @param {String} 'data-search-max-value'     => max results data pages available
 * @param {String} 'data-search-url-value'     => current request.url
 *
 * == Assumptions:
 * @assert only 1 "swiper" element per page (set with the 'data-search-target'=>'swiper')
 * @assert uses '#loading-indicator' node as common loading indicator
 * @assert uses '.d-none' CSS class as common visibility switch
 *
 * @author Steve A.
 */
export default class extends Controller {
  static targets = ['swiper']
  static values = { max: Number, current: Number, url: String }

  /**
   * Initialization boilerplate for the Swipe element/widget.
   * (Re-run each time the controller is connected to the DOM)
   */
  connect () {
    // Build a swiper target only if we have more than 1 page:
    if (this.hasSwiperTarget && this.maxValue > 1) {
      window.pageSwiper = new SwipeElement(this.swiperTarget, {
        // Options:
        continuous: true, // (wrap back at pagination end)
        enableLeft: true, // (useful to force-disable swiping when not continuous if at first or last page)
        enableRight: true,
        index: this.hasCurrentValue ? this.currentValue : 1,
        total: this.hasMaxValue ? this.maxValue : 1,
        // debug: true,

        // Callbacks:
        onswipeleft: (index) => {
          this.fetchSearchResultPage(index)
        },
        onswiperight: (index) => {
          this.fetchSearchResultPage(index)
        }
      })
    }
  }

  /**
   * Fetches a paginated result page directly from the server and replaces the innerHTML of
   * the search results
   *
   * @param {Number} pageIndex the new index for the data page to be retrieved
   */
  fetchSearchResultPage (pageIndex) {
    if (!(this.hasUrlValue && this.hasSwiperTarget)) {
      return
    }
    // Display loading indicator:
    document.querySelector('#loading-indicator').classList.remove('d-none')
    this.currentValue = pageIndex
    let url = this.urlValue

    // Set or add the next browsing page parameter:
    url = url.includes('page=') ? url.replace(/(?<=\W)(page=\d+)/i, `page=${pageIndex}`) : `${url}&page=${pageIndex}`

    // Set or add 'raw' request parameter:
    url = url.includes('raw=') ? url.replace(/(?<=\W)(raw=\d+)/i, 'raw=1') : `${url}&raw=1`
    // DEBUG
    // console.log(`fetchSearchResultPage('${url}')`)

    fetch(url)
      .then(response => { return response.text() })
      .then(html => {
        // DEBUG
        // console.log('Response OK')
        this.swiperTarget.innerHTML = html
        window.pageSwiper.resetPosition()
        // Hide loading indicator at the end:
        document.querySelector('#loading-indicator').classList.add('d-none')
      })
      .catch(error => console.log('fetch error:', error))
  }
}
