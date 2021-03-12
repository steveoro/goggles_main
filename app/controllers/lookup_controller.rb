# frozen_string_literal: true

# = LookupController
#
# Renders HTML partials for XHR requests.
#
class LookupController < ApplicationController
  before_action :authenticate_user!

  # PUT /lookup/matching_swimmers
  # (Logged-in users only)
  #
  # Returns updated select options given the parameters.
  #
  # == Params
  # - 'user[first_name]'
  # - 'user[last_name]'
  # - 'user[year_of_birth]'
  #
  def matching_swimmers
    permitted = params.require(:user).permit(:first_name, :last_name, :year_of_birth)

    if permitted.key?(:first_name) && permitted.key?(:last_name) && permitted.key?(:year_of_birth)
      matches = GogglesDb::User.new(permitted).matching_swimmers
      # DEBUG
      puts "\r\n- matching_swimmers SQL => #{matches.to_sql}"
      render(partial: 'matching_swimmers', locals: { matches: matches })
    else
      render(plain: '')
    end
  end
end
