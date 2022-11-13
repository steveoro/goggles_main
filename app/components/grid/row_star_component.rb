# frozen_string_literal: true

#
# = Grid components module
#
#   - version:  7-0.4.21
#   - author:   Steve A.
#
module Grid
  #
  # = Grid::RowStarComponent
  #
  # Renders the tag/star button for a Calendar or Meeting.
  # The component will render the link and parameters depending on the class
  # of the specified <tt>asset_row</tt>.
  #
  class RowStarComponent < ViewComponent::Base
    # Creates a new ViewComponent
    #
    # == Params
    # - <tt>:asset_row</tt>
    #  valid ActiveRecord Model instance to which this button component will be linked to
    #  (*required*)
    #
    # - <tt>:current_user</tt>
    #  valid User model instance to which this button component will be linked to
    #  (*required*)
    #
    # - <tt>:saved_ok</tt>
    #  set this to +false+ only to signal any error occurred during asset tagging.
    #  (optional; default +true+)
    #
    def initialize(asset_row:, current_user:, saved_ok: true)
      super
      @asset_row = asset_row
      @current_user = current_user
      @saved_ok = saved_ok
    end

    # Skips rendering unless the minimum required parameters are set
    def render?
      @asset_row.present? && @asset_row.id.to_i.positive? &&
        @current_user.is_a?(GogglesDb::User) && @current_user.id.to_i.positive?
    end

    protected

    # Memoized Meeting instance for the tagging depending on the <tt>:asset_row</tt> class.
    # Defaults to +nil+ for unsupported asset classes.
    def meeting
      @meeting ||= if @asset_row.is_a?(GogglesDb::Meeting)
                     GogglesDb::Meeting.includes(:taggings).find_by(id: @asset_row&.id)
                   elsif @asset_row.respond_to?(:meeting_id)
                     GogglesDb::Meeting.includes(:taggings).find_by(id: @asset_row.meeting_id)
                   end
    end

    # Returns the memoized Meeting ID.
    def meeting_id
      @meeting_id ||= meeting&.id
    end

    # Enabled is +true+ whenever <tt>meeting_id</tt> results valid
    def enabled
      @enabled ||= meeting_id.to_i.positive? && GogglesDb::Meeting.exists?(id: meeting_id)
    end

    # "Starred" flag: +true+ if the asset has already been tagged by a user
    def starred
      return meeting.tags_by_user_list.include?("u#{@current_user.id}") if enabled

      false
    end

    # CSS icon class
    def css_icon
      return 'fa fa-star' if enabled && @saved_ok && starred
      return 'fa fa-star-o' if enabled && @saved_ok
      return 'fa fa-minus-circle' unless enabled

      'fa fa-exclamation-triangle'
    end

    # Memoized CSS class for highlighting the icon.
    def css_highlight
      return 'text-warning' if enabled && @saved_ok && starred
      return 'text-primary' if enabled && @saved_ok

      'text-danger'
    end
  end
end
