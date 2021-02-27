# frozen_string_literal: true

# = OmniauthCallbacksController
#
# Controller for handling OAuth2 callbacks
#
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # Handles callbacks returning from Google OAuth2
  def google_oauth2
    process_omniauth
  end

  # Handles callbacks returning from Facebook OAuth2
  def facebook_oauth2
    process_omniauth
  end

  # Handles failures from OAuth2
  def failure
    redirect_to root_path
  end

  private

  # Generalized OmniAuth processing
  def process_omniauth
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.is_a?(GogglesDb::User) && @user.persisted?
      flash[:notice] = I18n.t('devise.omniauth_callbacks.success', kind: @user.provider)
      sign_in_and_redirect(@user, event: :authentication) # this will throw if @user is not activated
    else
      # Remove the extra sub-hash as it can overflow some session stores:
      session["devise.#{@user.provider.downcase}_data"] = request.env["omniauth.auth"]&.except('extra')
      redirect_to(
        new_user_registration_url,
        alert: @user.respond_to?(:errors) ? @user.errors.full_messages.join("\n") : 'Invalid OAuth data!'
      )
    end
  end
end
