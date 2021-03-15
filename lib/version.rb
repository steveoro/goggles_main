# frozen_string_literal: true

#
# == Versioning codes
#
#   - version:  7.88
#   - author:   Steve A.
#
# Framework version number usually differs from core engine versioning number.
# Actual Semantic versioning code is stored into 'goggles_db'.
#
# To get the correct Semantic versioning number, use:
#
# > require 'goggles_db/version'
# > GogglesDb::VERSION
#
module Version
  # Framework Core internal name.
  CORE    = 'C7'

  # Major version.
  MAJOR   = '7'

  # Minor version.
  MINOR   = '88'

  # Current build version.
  BUILD   = '20210315'

  # Full versioning for the current release.
  FULL    = "#{MAJOR}.#{MINOR}.#{BUILD} (#{CORE})"

  # Compact versioning label for the current release.
  COMPACT = "#{MAJOR.gsub('.', '')}#{MINOR}"

  # Current internal DB version (independent from migrations and framework release)
  DB      = '1.88.0'
end
