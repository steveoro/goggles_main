# frozen_string_literal: true

#
# = Version module
# - author: Steve A.
#
# Framework version may differ from core engine versioning number.
# Actual Semantic versioning code is stored into 'goggles_db'.
# To be sure getting the correct Semantic versioning number use:
#
# > require 'goggles_db/version'
# > GogglesDb::VERSION
#
# Or:
#
# > require 'version'
# > Version::SEMANTIC
#
module Version
  # Framework Core internal name.
  CORE = 'C7'

  # Major version.
  MAJOR = '0'

  # Minor version.
  MINOR = '8'

  # Patch version.
  PATCH = '00'

  # Current build version.
  BUILD = '20241223'

  # Full versioning for the current release.
  FULL = "#{MAJOR}.#{MINOR}.#{PATCH} (#{CORE}-#{BUILD})".freeze

  # Compact semantic versioning label for the current framework release.
  SEMANTIC = "#{MAJOR}.#{MINOR}.#{PATCH}".freeze

  # Current internal DB version (independent from migrations and framework release)
  DB = '2.07.6'
end
