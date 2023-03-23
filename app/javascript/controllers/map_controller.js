import { Controller } from '@hotwired/stimulus'
import 'leaflet/dist/leaflet.css'
import 'leaflet-defaulticon-compatibility/dist/leaflet-defaulticon-compatibility.webpack.css' // Re-uses images from ~leaflet package
import * as L from 'leaflet'
import 'leaflet-defaulticon-compatibility'

/**
 * = StimulusJS Leaflet Map controller =
 *
 * Prepares & displays the map for the specified 'placesList' using
 * the Leaflet library.
 *
 * @see https://leafletjs.com/
 *
 * == Targets ==
 * @param {String} 'data-map-target': 'map' => DOM ID of the target canvas
 *                 (target for this controller instance)
 *
 * == Values ==
 * (Put values directly on controller elements as JSON values that will be parsed by this controller)
 *
 * @param {Array} 'data-map-places-list-value' (Array, *required*)
 *                Array of JSON objects identifying each place, having structure:
 *      {
 *        lat: <latitude_float>,              // required
 *        lng: <longitude_float>,             // required
 *        name: "place label or title HTML",  // required
 *        bold_text: "additional place text rendered in bold",
 *        italic_text: "additional place text rendered in italic",
 *        details_link1: "additional details HTML link #1",
 *        details_link2: "additional details HTML link #2",
 *        maps_url: "external mapping service URL string rendered as button"
 *      }
 *
 * == Actions:
 * (no actions, just setup)
 *
 */
export default class extends Controller {
  static targets = ['map']
  static values = { placesList: Array }

  /**
   * Initialization boilerplate for the map target.
   * (Re-run each time the controller is connected to the DOM)
   */
  connect () {
    if (this.hasMapTarget && this.hasPlacesListValue) {
      // DEBUG
      // console.log('map controller connected')
      const map = L.map(this.mapTarget)

      L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
      }).addTo(map)

      this.placesListValue.forEach((place) => {
        let popupHtml = `<p>${place.name}<br/><b>${place.bold_text ? place.bold_text : ''}</b>` +
                        `<br/><i><small>${place.italic_text ? place.italic_text : ''}</small></i></p>`
        if (place.details_link1) {
          popupHtml += `<p />${place.details_link1}`
          if (place.maps_url) {
            popupHtml += `&nbsp;<a href="${place.maps_url}" class='btn btn-sm btn-outline-success'><i class='fa fa-map'></i></a>`
          }
          if (place.details_link2) {
            popupHtml += `<br/>${place.details_link2 ? place.details_link2 : ''}<br/>`
          }
        }

        L.marker([place.lat, place.lng])
          .addTo(map)
          .bindPopup(popupHtml)
      })

      map.locate({ setView: true, maxZoom: 7 })
    }
  }
}
