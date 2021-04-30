# frozen_string_literal: true

#
# = Footer components module
#
#   - version:  7.02
#   - author:   Steve A.
#
module Footer
  #
  # = Footer::SocialUrlsComponent
  #
  # Renders the links to the Social Media accounts, using
  # the URLs defined in the settings
  #
  class SocialUrlsComponent < ViewComponent::Base
    # Creates a new ViewComponent getting the "social URLs" directly
    # from the settings.
    #
    def initialize
      super
      @social_urls = GogglesDb::AppParameter.versioning_row.settings(:social_urls)
    end

    # Skips rendering unless the social_urls instance is properly set and there's
    # at least a social media account URL defined
    def render?
      @social_urls.facebook.present? ||
        @social_urls.linkedin.present? ||
        @social_urls.twitter.present?
    end
  end
end
