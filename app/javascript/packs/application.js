// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import JQuery from 'jquery'
window.$ = window.JQuery = JQuery
import 'popper.js'
import 'bootstrap'

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
  $('[data-toggle="modal"]').modal()

  // Show & auto-hide all flash alerts after a while:
  $(".alert").alert().fadeTo(500, 1).delay(3000).slideUp(200, function () {
    $(".alert").alert('close')
  })
})


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
