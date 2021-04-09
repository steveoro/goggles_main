# frozen_string_literal: true

# = ApplicationMailer
#
# Common parent mailer
class ApplicationMailer < ActionMailer::Base
  # [Steve A., 20180115] Avoid using hostname from ENV (ENV['HOSTNAME']) because it uses the local IP
  HOSTNAME = Rails.application.config.action_mailer.default_url_options[:host]

  # Internal Mailer address for the "From" field :
  default from: "Goggles Mailer <no-reply@#{HOSTNAME}>"
  layout 'mailer'

  # Generates a generic application e-mail with a custom subject and body,
  # to a specific User instance.
  #
  # == Params:
  # - +user+: the chosen User instance;
  # - +subject_text+: text for the Subject field;
  # - +content_body+: the actual contents of the mail body, rendered as html_safe.
  #
  def generic_message(user, subject_text, content_body)
    @user  = user
    @host  = HOSTNAME
    @content_body = content_body
    mail(
      subject: "[Goggles@#{@host}] #{subject_text}",
      to: @user.email,
      date: Time.now
    )
  end
  #-- -------------------------------------------------------------------------
  #++
end
