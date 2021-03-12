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

// Styles:
import '../stylesheets/application'

// Before each page load:
document.addEventListener('turbolinks:load', () => {
  // DEBUG
  // console.log('turbolinks:load')

  $('[data-toggle="tooltip"]').tooltip()
  // Auto-hide tooltips after they've being shown:
  $('[data-toggle="tooltip"]').on('shown.bs.tooltip', function () {
    $('[data-toggle="tooltip"]').delay(2000).queue(function (next) {
      $(this).tooltip('hide');
      next();
    });
  })

  $('[data-toggle="popover"]').popover()
  // Show & auto-hide all modal flash alerts after a while:
  $('[data-toggle="modal"]').modal().fadeTo(500, 1).delay(2000).slideUp(200, function () {
    $('[data-toggle="modal"]').modal('hide')
  })
})


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
