# frozen_string_literal: true

# = Devise::RegistrationsController customizations
#
module Users
  #
  # = RegistrationsController customizations
  #
  # Mainly used for handling a self-hosted captcha solution during
  # the registration process.
  #
  # (The commented out code below comes as default from the Devise generator:
  #  please, leave that here for future reference)
  #
  class RegistrationsController < Devise::RegistrationsController
    before_action :configure_sign_up_params, only: [:create]
    # before_action :configure_account_update_params, only: [:update]

    # GET /resource/sign_up
    # Adds captcha question selection
    # def new
    #   super
    # end

    # POST /resource
    # Adds captcha checking before creating the resource
    def create
      # Avoid hCaptcha check in test environment - Don't even start
      # checking hcaptcha if under test environment:
      unless Rails.env.test? || verify_hcaptcha
        redirect_to(new_user_registration_url, alert: I18n.t('captcha.error'))
        return
      end

      super
    end

    # GET /resource/edit
    # def edit
    #   super
    # end

    # PUT /resource
    # def update
    #   super
    # end

    # DELETE /resource
    # def destroy
    #   super
    # end

    # GET /resource/cancel
    # Forces the session data which is usually expired after sign
    # in to be expired now. This is useful if the user wants to
    # cancel oauth signing in/up in the middle of the process,
    # removing all OAuth session data.
    # def cancel
    #   super
    # end

    protected

    # Checks client response against hCaptcha's /siteverify
    def verify_hcaptcha
      res = RestClient.post(
        'https://hcaptcha.com/siteverify',
        "response=#{params['h-captcha-response']}&" \
        "secret=#{Rails.application.credentials.hcaptcha_secret}&" \
        "remoteip=#{request.ip}&" \
        "sitekey=#{Rails.application.credentials.hcaptcha_sitekey}"
      )
      json_response = JSON.parse(res)
      json_response['success'] == true
    end

    # Adds just the self-hosted captcha parameters to sign-up form
    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, keys: ['h-captcha-response'])
    end

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_account_update_params
    #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
    # end

    # The path used after sign up.
    # def after_sign_up_path_for(resource)
    #   super(resource)
    # end

    # The path used after sign up for inactive accounts.
    # def after_inactive_sign_up_path_for(resource)
    #   super(resource)
    # end
  end
end
