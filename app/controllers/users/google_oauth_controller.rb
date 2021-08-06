# frozen_string_literal: true

# == Users::GoogleOauthController
#
# Bespoke OAuth2 callbacks wrapper for Sign-in/Sign-up with Google,
# due to updated data flow @ 2021/08, after the introduction of the One-Tap login
# feature.
#
module Users
  # == GoogleOauthController
  #
  class GoogleOauthController < ApplicationController
    # Handles resulting responses from the new Google OAuth2 introduced in 2021 together with the
    # One-Tap login flow.
    # (The old Google OAuth2 flow is already dead and doesn't work anymore.)
    #
    # This endpoint is referenced by the 'google_sign_in' gem button helpers and doesn't involve
    # any Devise/Omniauthable callback (it's independent).
    #
    # - For the returned data structure, see https://github.com/basecamp/google_sign_in
    # - See also config/initializers/google_sign_in.rb for callback path customization.
    #
    # == Note:
    # Make sure at least 'http://localhost:3000/google_sign_in/callback' is added as an allowed callback URI
    # in the Cloud Platform developer console (https://console.cloud.google.com/apis/credentials/),
    # and the proper credentials are stored in the credentials file ('rails credentials:edit')
    #
    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def continue
      id_token = flash['google_sign_in']['id_token'] if flash['google_sign_in'].present?
      error = flash['google_sign_in']['error'] if flash['google_sign_in'].present?
      # Errors returned:
      if error.present?
        logger.error(I18n.t('devise.customizations.google_oauth.auth_error', error: error))
        redirect_to(
          new_user_registration_url,
          alert: I18n.t('devise.customizations.google_oauth.auth_error', error: error)
        ) && return
      end

      # No JWT from Google:
      unless id_token.present?
        redirect_to(
          new_user_registration_url,
          alert: I18n.t('devise.customizations.google_oauth.empty_response')
        ) && return
      end

      # Retrieve & serialize user (find or create/update):
      result_user = user_from_id_token(id_token)
      unless result_user.is_a?(GogglesDb::User) && result_user.persisted?
        redirect_to(
          new_user_registration_url,
          alert: alert_for_user_errors(result_user)
        ) && return
      end

      # Condition ok:
      flash[:notice] = I18n.t('devise.omniauth_callbacks.success', kind: 'Google')
      # This will throw if result_user is not activated:
      sign_in_and_redirect(result_user, event: :authentication) && return
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    #-- ------------------------------------------------------------------------
    #++

    private

    # Returns either the AR errors on the specified User instance or a generic OAuth error text if
    # no serialization issues are found on the record.
    #
    # == Params
    # - user: must be a valid GogglesDb::User instance
    #
    def alert_for_user_errors(user)
      return user.errors.full_messages.join("\n") if user.is_a?(GogglesDb::User) && user.errors.full_messages.present?

      I18n.t('devise.customizations.google_oauth.invalid_data')
    end

    # Extracts the user data returned from the JWT response from the new Google OAuth flow
    # tries to find a matching user for it, updates the user fields regading the
    # provider of its last login or it creates a whole new user if totally missing.
    #
    # == Params
    # - id_token: the string JWT returned by the OAuth flow
    #
    # == Returns
    # nil or an invalid User instance in case of errors; a valid User otherwise.
    #
    def user_from_id_token(id_token)
      identity = GoogleSignIn::Identity.new(id_token)
      return nil unless identity.is_a?(GoogleSignIn::Identity)

      # DEBUG
      # logger.debug("\r\n- identity: #{identity.inspect}")
      result_user = find_or_create_new_user(identity)
      I18n.locale = identity.locale if identity.locale.present?
      result_user.skip_confirmation_notification! if identity.email_verified?
      if result_user.persisted?
        update_existing_user!(result_user, identity)
      else
        # Try to persist the user (may yield validation errors; caller should check resulting user always)
        result_user.save
      end
      result_user
    end

    # Given a GoogleSignIn::Identity tries to find or create a new user given the data contained
    # in the identity.
    #
    # Returns the User instance or nil.
    #
    def find_or_create_new_user(identity)
      return nil unless identity.is_a?(GoogleSignIn::Identity)

      GogglesDb::User.find_by(email: identity.email_address) ||
        GogglesDb::User.where(
          provider: 'google',
          uid: identity.user_id,
          first_name: identity.given_name,
          last_name: identity.family_name
        ).first_or_initialize do |user|
          user.name = identity.name
          user.email = identity.email_address
          user.password = Devise.friendly_token[0, 20]
          user.confirmed_at = Time.zone.now
          user.avatar_url = identity.avatar_url
        end
    end

    # Updates an existing User instance with the new sign-in values & verifies that the associated
    # swimmer is set, if available.
    # Requires also the identity (GoogleSignIn::Identity) data.
    #
    def update_existing_user!(user, identity)
      return unless user.is_a?(GogglesDb::User) && user.persisted? && identity.is_a?(GoogleSignIn::Identity)

      user.update!(
        provider: 'google',
        uid: identity.user_id,
        avatar_url: identity.avatar_url,
        confirmed_at: Time.zone.now
      )
      user.reload
      # Enforce bidirectional swimmer association when user |=> swimmer but not vice-versa:
      return unless user.swimmer && user.swimmer_id != user.swimmer.associated_user_id

      user.swimmer.associated_user_id = user.id
      user.swimmer.save!
    end
    #-- ------------------------------------------------------------------------
    #++
  end
end
