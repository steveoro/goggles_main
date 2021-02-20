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
    # (no-op)
  end
end
