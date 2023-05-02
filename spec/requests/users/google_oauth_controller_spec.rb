# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::GoogleOauthController do
  let(:valid_identity) { instance_double(GoogleSignIn::Identity) }
  let(:returned_uid) { '1234567890' }

  # Requires:
  # - fixture_user: the valid User instance matching the values of the GoogleSignIn::Identity attributes
  shared_examples_for 'GoogleSignIn::Identity token_id valid & user find_or_create successful' do
    let(:user_subject) do
      # We need to reload the user serialized by the controller action with a finder to allow
      # these shared examples to be used even when the fixture_user doesn't have an ID yet:
      serialized_user = GogglesDb::User.find_by(email: fixture_user.email)
      expect(serialized_user).to be_a(GogglesDb::User).and be_valid
      serialized_user
    end
    it 'redirects to default (for event: authentication)' do
      expect(response).to redirect_to(root_path)
    end

    it 'persists (and updates) the user matched by the identity fields' do
      expect(user_subject).to be_persisted
    end

    it 'updates the user provider' do
      expect(user_subject.provider).to eq('google')
    end

    it 'confirms the user' do
      expect(user_subject).to be_confirmed
    end

    it 'updates the user uid' do
      expect(user_subject.uid).to eq(returned_uid)
    end

    it 'signs-in the user' do
      expect(user_subject.sign_in_count).to be_positive # assumes: default must be 0
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'GET users/google_oauth/continue' do
    # == NOTE:
    # We shall allow the deprecated monkey-patching syntax for these examples only, as we need to set the flash
    # object *before* the request is set, with something like {'google_sign_in' => { 'id_token' => '<ACTUAL_TOKEN_VALUE>' }},
    # in order to mock the behavior of the GoogleSignIn Engine and test our response redirections.
    #
    # Under "normal" conditions, we would have:
    #
    # 1. retrieved a valid Google Cloud key for encrypting the JWT
    # 2. create the JWT bespoke to the current test context (valid existing, valid new, invalid, ...)
    # 3. mock the request to the sign-in engine (GoogleSignIn)
    # 4. expect the response to redirect to GET /continue with the correct id_token set inside the flash
    # 5. start the actual tests
    #
    # So, monkey patching it is.
    before(:all) do
      RSpec.configure do |config|
        config.mock_with :rspec do |mocks|
          mocks.syntax = :should
        end
      end
    end

    after(:all) do
      RSpec.configure do |config|
        config.mock_with :rspec do |mocks|
          mocks.syntax = :expect
        end
      end
    end

    context 'when returning an already valid & confirmed user,' do
      let(:fixture_user) { FactoryBot.create(:user, sign_in_count: 0, provider: '', uid: '') }

      before do
        expect(fixture_user).to be_a(GogglesDb::User).and be_valid
        described_class.any_instance.stub(:flash) { { 'google_sign_in' => { 'id_token' => 'anything' } } }
        # Bypass everything GoogleSignIn::Identity-related: (very ugly!!!)
        valid_identity.stub(:is_a?)           { true } # bypass also internal checks
        valid_identity.stub(:locale)          { 'it' }
        valid_identity.stub(:email_verified?) { true }
        valid_identity.stub(:email_address)   { fixture_user.email }
        valid_identity.stub(:user_id)         { returned_uid }
        valid_identity.stub(:name)            { fixture_user.name }
        valid_identity.stub(:given_name)      { fixture_user.first_name }
        valid_identity.stub(:family_name)     { fixture_user.last_name }
        valid_identity.stub(:avatar_url)      { fixture_user.avatar_url }
        GoogleSignIn::Identity.stub(:new) { valid_identity }
        # Make sure anything passed as JWT will yield our mocked valid GoogleSignIn::Identity instance:
        expect(GoogleSignIn::Identity.new('whatever')).to eq(valid_identity)
        get(users_google_oauth_continue_path)
      end

      after do
        described_class.any_instance.unstub(:flash)
      end

      it_behaves_like('GoogleSignIn::Identity token_id valid & user find_or_create successful')
    end

    context 'when returning a NEW valid user,' do
      let(:fixture_user) { FactoryBot.build(:user, sign_in_count: 0, provider: '', uid: '') }

      before do
        expect(fixture_user).to be_a(GogglesDb::User).and be_valid
        described_class.any_instance.stub(:flash) { { 'google_sign_in' => { 'id_token' => 'anything' } } }
        valid_identity.stub(:is_a?)           { true }
        valid_identity.stub(:locale)          { 'it' }
        valid_identity.stub(:email_verified?) { true }
        valid_identity.stub(:email_address)   { fixture_user.email }
        valid_identity.stub(:user_id)         { returned_uid }
        valid_identity.stub(:name)            { fixture_user.name }
        valid_identity.stub(:given_name)      { fixture_user.first_name }
        valid_identity.stub(:family_name)     { fixture_user.last_name }
        valid_identity.stub(:avatar_url)      { fixture_user.avatar_url }
        GoogleSignIn::Identity.stub(:new) { valid_identity }
        get(users_google_oauth_continue_path)
      end

      after do
        described_class.any_instance.unstub(:flash)
      end

      it_behaves_like('GoogleSignIn::Identity token_id valid & user find_or_create successful')
    end

    context 'when returning an authentication error,' do
      before do
        described_class.any_instance.stub(:flash) { { 'google_sign_in' => { 'error' => 'No way man!' } } }
        get(users_google_oauth_continue_path)
      end

      after do
        described_class.any_instance.unstub(:flash)
      end

      it 'redirects to new_user_registration_url' do
        expect(response).to redirect_to(new_user_registration_url)
      end
    end
  end
end
