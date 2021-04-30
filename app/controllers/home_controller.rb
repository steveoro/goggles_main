# frozen_string_literal: true

require 'version'

# = HomeController
#
# Main landing actions.
#
class HomeController < ApplicationController
  before_action :authenticate_user!, only: %i[contact_us]

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

  private

  # Prepares and enqueues the "contact us" email message
  def enqueue_contact_message
    ApplicationMailer.system_message(
      current_user,
      app_settings_row.settings(:framework_emails)&.contact, # to:
      app_settings_row.settings(:framework_emails)&.admin, # cc:
      "Msg from '#{current_user.name}'",
      params['body']
    ).deliver_later
  end
end
