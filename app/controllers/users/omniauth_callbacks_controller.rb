# frozen_string_literal: true

# == Users::OmniauthCallbacksController
#
# OAuth2 callbacks wrapper for Devise Users
#
module Users
  # == OmniauthCallbacksController
  #
  # Any OAuth request to a specific provider will yield a return callback request
  # to a controller action named after the same provider (as a symbol).
  #
  # The provider name can be extracted from the returned OmniAuth::AuthHash.
  #
  # @see https://github.com/heartcombo/devise/wiki/OmniAuth:-Overview
  # @see https://github.com/omniauth/omniauth/blob/master/lib/omniauth/auth_hash.rb
  # @see https://github.com/omniauth/omniauth/wiki/Integration-Testing
  #
  # Gem references:
  # - https://github.com/zquestz/omniauth-google-oauth2
  # - https://github.com/simi/omniauth-facebook
  # - https://github.com/arunagw/omniauth-twitter (as of this writing, this gem supports only OAuth 1.1a)
  #
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    # Handles callbacks returning from Google OAuth2
    # Assumes provider name = :google_oauth2
    def google_oauth2
      process_omniauth
    end

    # Handles callbacks returning from Facebook
    # Assumes provider name = :facebook
    def facebook
      process_omniauth
    end

    # Handles callbacks returning from Facebook
    # Assumes provider name = :twitter
    #
    # ==> Twitter sign-in disabled for the time being: <==
    # - gem supports only OAuth 1a
    # - doesn't work properly with current gem stack
    #
    # TODO: make a fork of the gem & add OAuth 2.0 support when possible if no-one writes another gem in the meantime
    #
    def twitter
      # [Steve A.] Twitter may not always enforce a user to give a valid email to create an account.
      # (This may change in future)
      # In the event of a returned AuthHash with an empty email, even if the user is found,
      # process_omniauth should fail and redirect to new_user_registration_url.
      process_omniauth
    end

    # WIP: FUTUREDEV
    # Callback for handling failures returning from any /auth/:provider request
    def failure
      # flash[:error] = '<any error reported by request.env['omniauth.auth']>'
      redirect_to root_path
    end

    private

    # Generalized OmniAuth processing.
    # If the returned user is not valid, this will redirect to new_user_registration_url.
    def process_omniauth
      @user = wip_from_omniauth(request.env['omniauth.auth'])
      if @user.is_a?(GogglesDb::User) && @user.persisted?
        flash[:notice] = I18n.t('devise.omniauth_callbacks.success', kind: @user.provider.to_s.split('_').first.titleize)
        sign_in_and_redirect(@user, event: :authentication) # this will throw if @user is not activated

      else
        # Remove the extra sub-hash as it can overflow some session stores:
        session["devise.#{@user.provider.downcase}_data"] = request.env['omniauth.auth']&.except('extra')
        redirect_to(
          new_user_registration_url,
          alert: @user.respond_to?(:errors) ? @user.errors.full_messages.join("\n") : 'Invalid OAuth data!'
        )
      end
    end
    #-- ------------------------------------------------------------------------
    #++

    # WIP: TO BE DELETED after:
    # 1. update GogglesDb w/ specs
    # 2. remove this and use:...
    #       @user = GogglesDb::User.from_omniauth(request.env['omniauth.auth'])
    #    ...on line 54
    #
    def wip_from_omniauth(auth)
      result_user = GogglesDb::User.find_by(email: auth.info.email) ||
                    GogglesDb::User.where(provider: auth.provider, uid: auth.uid).first_or_initialize do |user|
                      user.email = auth.info.email
                      user.password = Devise.friendly_token[0, 20]
                      user.name = auth.info.name
                      user.first_name = auth.info.first_name
                      user.last_name = auth.info.last_name
                      user.confirmed_at = Time.zone.now
                      user.avatar_url = auth.info.image
                    end
      result_user.skip_confirmation_notification!
      if result_user.persisted?
        result_user.update!(
          provider: auth.provider,
          uid: auth.uid,
          avatar_url: auth.info.image,
          confirmed_at: Time.zone.now
        )
        result_user.reload
      else
        # Try to persist the user (may yield validation errors; caller should check resulting user always)
        result_user.save
      end
      result_user
    end
    #-- ------------------------------------------------------------------------
    #++
  end
end
