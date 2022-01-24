// This file is auto-generated by ./bin/rails stimulus:manifest:update
// Run that command whenever you add a new controller or create them with
// ./bin/rails generate stimulus controllerName

import { application } from './application'

import ChronoController from './chrono_controller.js'

import ChronoNewSummaryController from './chrono_new_summary_controller.js'

import LookupController from './lookup_controller.js'

import PopoverController from './popover_controller.js'

import RemotePartialController from './remote_partial_controller.js'

import SearchController from './search_controller.js'

import SwitchController from './switch_controller.js'

import UnsavedChangesController from './unsaved_changes_controller.js'

import UserNameController from './user_name_controller.js'

import WizardFormController from './wizard_form_controller.js'
application.register('chrono', ChronoController)
application.register('chrono-new-summary', ChronoNewSummaryController)
application.register('lookup', LookupController)
application.register('popover', PopoverController)
application.register('remote-partial', RemotePartialController)
application.register('search', SearchController)
application.register('switch', SwitchController)
application.register('unsaved-changes', UnsavedChangesController)
application.register('user-name', UserNameController)
application.register('wizard-form', WizardFormController)
