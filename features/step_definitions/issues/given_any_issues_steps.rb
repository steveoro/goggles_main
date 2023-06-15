# frozen_string_literal: true

# Creates 3x random issue rows for the @current_user
# USES:
# - @current_user
Given('there are some issue reports from the current_user') do
  expect(@current_user).to be_a(GogglesDb::User).and be_valid
  issue_factories = %i[issue_type0 issue_type1a issue_type1b issue_type1b1
                       issue_type2b1 issue_type3b issue_type3c issue_type4]
  issue_factories.sample(3).each do |issue_factory|
    FactoryBot.create(issue_factory, user: @current_user)
  end

  expect(GogglesDb::Issue.for_user(@current_user).count).to be >= 3
end

# Creates a new type code '5' request for the @current_user
# USES:
# - @current_user
Given('there is a single reactivation request by me already queued') do
  expect(@current_user).to be_a(GogglesDb::User).and be_valid
  FactoryBot.create(:issue_type0, user: @current_user, code: '5')

  expect(GogglesDb::Issue.for_user(@current_user).where(code: '5').count).to eq(1)
end

# Negative existence check for type code '5' request by the @current_user
# USES:
# - @current_user
Given('NO reactivation requests by me are pending') do
  expect(@current_user).to be_a(GogglesDb::User).and be_valid
  expect(GogglesDb::Issue.for_user(@current_user).exists?(code: '5')).to be false
end

# Positive existence check for type code '5' request by the @current_user
# USES:
# - @current_user
Given('only 1 reactivation request by me is queued') do
  expect(@current_user).to be_a(GogglesDb::User).and be_valid
  expect(GogglesDb::Issue.for_user(@current_user).where(code: '5').count).to eq(1)
end
