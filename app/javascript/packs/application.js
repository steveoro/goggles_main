// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import jQuery from 'jquery'
window.$ = window.jQuery = jQuery
import 'popper.js'
import 'bootstrap'
import 'select2'
import 'select2/dist/css/select2.css'

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require('channels')

import '../controllers/stimulus_setup'
import './components'

// Styles:
import '../stylesheets/application'

// Before each page load:
// document.addEventListener('turbolinks:load', () => {
//   // DEBUG
//   console.log('turbolinks:load')
//   // (do something)
// })

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
