# frozen_string_literal: true

# == Users::OmniauthCallbacksController
#
# OAuth2 callbacks wrapper for Devise Users
# Overrides default OAuth controller from devise, mounted inside engine itself.
#
module GogglesDb
  # == OmniauthCallbacksController override for failures
  #
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    # Catch-all for OAuth failures (typically, from invalid credentials)
    def failure
      redirect_to(new_user_registration_url, alert: I18n.t('devise.customizations.invalid_credentials'))
    end
    #-- ------------------------------------------------------------------------
    #++
  end
end
