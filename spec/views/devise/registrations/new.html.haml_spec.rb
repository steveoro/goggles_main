# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'devise/registrations/new.html.haml', type: :view do
  before(:each) do
    user = FactoryBot.build(:user)
    # sign_in(user)
    # allow(view).to receive(:user_signed_in?).and_return(true)
    render
  end

  xit 'shows the log-out link' do
    expect(rendered).to include(destroy_user_session_path)
    expect(rendered).to include(ERB::Util.html_escape(I18n.t('home.log_out')))
  end

  # TODO
end
