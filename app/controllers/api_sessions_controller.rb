# frozen_string_literal: true

# = APISessionsController
#
# Allows to request a new JWT session valid for API connection.
#
class APISessionsController < ApplicationController
  before_action :authenticate_user!

  # POST /api_session/jwt
  # (Logged-in users only)
  #
  # Returns a valid JWT for a new API session
  def jwt
    unless request.format.json?
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to root_path
      return
    end

    token = GogglesDb::JWTManager.encode(
      { user_id: current_user.id },
      Rails.application.credentials.api_static_key
      # use defalt session length (@see GogglesDb::JWTManager::TOKEN_LIFE)
    )
    render(json: { jwt: token })
  end
end
