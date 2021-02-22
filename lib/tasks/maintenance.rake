# frozen_string_literal: true

#
# = Maintenance helper tasks
#
#   - (p) FASAR Software 2007-2021
#   - for Goggles framework vers.: 7+
#   - author: Steve A.
#
#-- ---------------------------------------------------------------------------
#++

namespace :maintenance do
  desc 'Sets maintenance mode ON'
  task on: [:environment] do |_t|
    GogglesDb::AppParameter.maintenance = true
    puts 'Maintenance mode is ON.'
  end

  desc 'Sets maintenance mode OFF'
  task off: [:environment] do |_t|
    GogglesDb::AppParameter.maintenance = false
    puts 'Maintenance mode is OFF.'
  end
end
