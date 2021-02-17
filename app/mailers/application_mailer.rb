# frozen_string_literal: true

# = ApplicationMailer
#
# Common parent mailer
class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'
end
