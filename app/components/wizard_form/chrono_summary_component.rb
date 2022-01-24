# frozen_string_literal: true

#
# = WizardForm components module
#
#   - version:  7.3.40
#   - author:   Steve A.
#
module WizardForm
  #
  # = ChronoSummaryComponent
  #
  # Creates summary overview for the wizard form used for /chrono/new.
  #
  # The summary includes both a success notice and a "please go back" notice in
  # case the form does not validate.
  #
  # Summary update & proper notice show/hide toggle is managed by the ChronoNewSummaryController
  # (Stimulus JS).
  #
  class ChronoSummaryComponent < ViewComponent::Base
    # Creates a new ViewComponent.
    #
    # == Supported options & defaults:
    # - swimmer: descriptive label for the selected swimmer (default: '')
    # - event: descriptive label for the selected event (default: '')
    # - title: descriptive label for the selected meeting or workshop (default: '')
    # - pool: descriptive label for the selected pool (default: '')
    #
    # - skip_notice: skip the 'required fields are ready/missing' notice sections (default: false => render them)
    #
    def initialize(options = {})
      super
      @swimmer = options[:swimmer] || ''
      @event = options[:event] || ''
      @title = options[:title] || ''
      @pool = options[:pool] || ''
      @skip_notice = options[:skip_notice] || false
    end
  end
end
