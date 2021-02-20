# frozen_string_literal: true

require 'version'
require 'goggles_db/version'

# = MaintenanceController
#
# Handles any request when maintenance mode is toggled on.
#
# @see GogglesDb::AppParameter
#
class MaintenanceController < ApplicationController
  # Landing page for any request during maintenance mode.
  def index
    # Ignore requests to self:
    # redirect_to root_path unless GogglesDb::AppParameter.maintenance?

    render layout: false
  end
end
