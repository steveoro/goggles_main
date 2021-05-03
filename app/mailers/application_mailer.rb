# frozen_string_literal: true

require 'goggles_db/version'

# = ApplicationMailer
#
# Common parent mailer
class ApplicationMailer < ActionMailer::Base
  # [Steve A., 20180115] Avoid using hostname from ENV (ENV['HOSTNAME']) because it uses the local IP
  HOSTNAME = Rails.application.config.action_mailer.default_url_options[:host]

  # Internal Mailer address for the "From" field :
  default from: "'Goggles Mailer' <no-reply@#{HOSTNAME}>"
  layout 'mailer_boxed_basic'

  # Generates a generic application e-mail with a custom subject and body,
  # to a specific User email.
  #
  # == Params:
  # - +user_email+: e-mail address for the message;
  # - +user_name+: user name used for the greetings (can be +nil+ to disable the greetings line);
  # - +subject_text+: text for the Subject field;
  # - +content_body+: the actual contents of the mail body, rendered as html_safe inside a styled box.
  #
  def generic_message(user_email:, subject_text:, content_body:, user_name: nil)
    @user_email = user_email
    @user_name = user_name
    @host = HOSTNAME
    @content_body = content_body
    mail(
      subject: "[Goggles@#{@host}] #{subject_text}",
      to: @user_email,
      date: Time.now
    )
  end
  #-- -------------------------------------------------------------------------
  #++

  # Generates a system application text-only e-mail to custom addresses.
  #
  # == Params:
  # - +user+: a User instance displayed in detail inside the body; can be +nil+ to skip displaying it
  # - +to_address+: destination e-mail
  # - +cc_address+: array of addtional destination e-mail addresses (as strings); set this to +nil+ or empty to skip
  # - +subject_text+: text for the Subject field
  # - +content_body+: the actual contents of the mail body, rendered as text with no styles.
  #
  def system_message(to_address:, subject_text:, content_body:, user: nil, cc_address: nil)
    @user = user
    @host = HOSTNAME
    @content_body = content_body
    mail(
      subject: "[Goggles@#{@host}] [SYS] #{subject_text}",
      to: to_address,
      cc: cc_address,
      date: Time.now
    )
  end
  #-- -------------------------------------------------------------------------
  #++
end
