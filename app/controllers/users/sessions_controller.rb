# frozen_string_literal: true

# = Devise::SessionsController customizations
#
module Users
  #
  # = SessionsController customizations
  #
  class SessionsController < Devise::SessionsController
    # POST /resource/sign_in
    def create
      # == Note ==
      # Any resource authenticated by this endpoint is using usual Devise authentications
      # not the omniauth strategy, so we use this override to clean-up any previously
      # set OAuth field.
      self.resource = warden.authenticate!(auth_options)
      resource.update_columns(uid: nil, provider: nil)
      # Clear last seasons IDs cookie on a new sign-in:
      cookies[:last_seasons_ids] = nil
      super
    end

    # DELETE /resource/sign_out
    def destroy
      super
      reset_session
    end
  end
end
