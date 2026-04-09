# Pin npm packages by running ./bin/importmap

pin 'application'
pin '@hotwired/turbo-rails', to: 'turbo.min.js'
pin '@hotwired/stimulus', to: 'stimulus.min.js'
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'
pin '@rails/actioncable', to: 'actioncable.esm.js'
pin '@rails/ujs', to: 'https://esm.sh/@rails/ujs@7.1.3'
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin_all_from 'app/javascript/channels', under: 'channels'
pin_all_from 'app/javascript/src', under: 'src'

# Third-party libraries used by Stimulus controllers.
pin 'chart.js/auto', to: 'https://cdn.jsdelivr.net/npm/chart.js@4.4.4/+esm'
pin 'leaflet', to: 'https://cdn.jsdelivr.net/npm/leaflet@1.9.4/+esm'
pin 'tom-select', to: 'https://cdn.jsdelivr.net/npm/tom-select@2.3.1/dist/esm/tom-select.complete.min.js'
