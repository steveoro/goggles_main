// Entry point for the build script. Replaces app/javascript/packs/application.js from Webpacker era.
// This file is compiled by esbuild (via jsbundling-rails) into app/assets/builds/application.js

import jQuery from 'jquery'
import 'popper.js'
import 'bootstrap'
import 'select2'

import './controllers/index'

window.$ = window.jQuery = jQuery

import Rails from '@rails/ujs'
Rails.start()

import Turbolinks from 'turbolinks'
Turbolinks.start()

import * as ActiveStorage from '@rails/activestorage'
ActiveStorage.start()

import './channels'
