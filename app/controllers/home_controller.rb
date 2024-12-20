# frozen_string_literal: true

require 'version'

# = HomeController
#
# Main landing actions.
#
class HomeController < ApplicationController
  before_action :authenticate_user!, only: %i[contact_us dashboard]

  # [GET] Main landing page default action.
  # Includes the "smart" search box.
  def index
    # (no-op)
  end

  # [GET] Multi-section '#about' page.
  # Includes privacy_policy plus much more.
  def about
    @updated_calendars = collect_latest_updates(30.days)
  end

  # [GET] Similarly to '#about' (but dedicated) retrieves the latest calendar updates.
  def latest_updates
    @updated_calendars = collect_latest_updates(30.days)
  end

  # [GET/POST] Show the '#contact_us' form, only for registered users.
  def contact_us
    return unless request.post? && params['body'].present?

    enqueue_contact_message
    flash[:info] = I18n.t('contact_us.message_sent')
    redirect_to root_path and return
  end

  # [GET/POST] Show the '#reactivate' form, only for de-activated users.
  def reactivate
    email = nil
    if request.post?
      email = params.permit(user: :email)[:user]&.fetch(:email, nil)
      flash[:warning] = I18n.t('devise.customizations.reactivation.msg.error_email_empty') if email.blank?
    end
    return if email.blank?

    process_reactivate_email(email)
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

  # Returns the latest 'updated_at' calendar rows, limited by a range of days.
  def collect_latest_updates(days_range)
    GogglesDb::Calendar.where('calendars.updated_at > ?', DateTime.now - days_range).order('calendars.updated_at DESC')
  end

  # Processes a reactivation request for an account email and sets the resulting flash message accordingly.
  # Creates a new Issue type 5 request if and only if the email is found existing and associated to a
  # deactivated account. Does nothing otherwise (apart from setting a flash message).
  #
  # == Params:
  # - email: a User#email string
  #
  def process_reactivate_email(email)
    user = GogglesDb::User.find_by(email:)
    if user.nil?
      flash[:warning] = I18n.t('devise.customizations.reactivation.msg.error_not_existing')
    elsif user.active?
      flash[:warning] = I18n.t('devise.customizations.reactivation.msg.error_not_deactivated')
    elsif GogglesDb::Issue.exists?(user_id: user.id, code: '5')
      flash[:warning] = I18n.t('devise.customizations.reactivation.msg.error_already_requested')
    else
      GogglesDb::Issue.create!(user_id: user.id, code: '5', req: '{}')
      flash[:info] = I18n.t('devise.customizations.reactivation.msg.ok_sent')
    end
  end
end
