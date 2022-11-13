# frozen_string_literal: true

require 'version'

# = HomeController
#
# Main landing actions.
#
class HomeController < ApplicationController
  before_action :authenticate_user!, only: %i[contact_us dashboard]
  before_action :prepare_last_seasons, only: :dashboard

  # [GET] Main landing page default action.
  # Includes the "smart" search box.
  def index
    # (no-op)
  end

  # [GET] Multi-section '#about' page.
  # Includes privacy_policy plus much more.
  def about
    # (no-op)
  end

  # [GET/POST] Show the '#contact_us' form, only for registered users.
  def contact_us
    return unless request.post? && params['body'].present?

    enqueue_contact_message
    flash[:info] = I18n.t('contact_us.message_sent')
    redirect_to root_path and return
  end

  # [GET] Current users's '#dashboard' page.
  # Requires authentication.
  def dashboard
    @swimmer = current_user.swimmer # (can be nil)
  end

  private

  # Prepares and enqueues the "contact us" email message
  def enqueue_contact_message
    ApplicationMailer.system_message(
      user: current_user,
      to_address: app_settings_row.settings(:framework_emails)&.contact, # to:
      cc_address: app_settings_row.settings(:framework_emails)&.admin, # cc:
      subject_text: "Msg from '#{current_user.name}'",
      content_body: params['body']
    ).deliver_later
  end
end
