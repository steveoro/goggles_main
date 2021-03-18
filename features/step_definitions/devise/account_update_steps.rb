# frozen_string_literal: true

When('I update the {string} field with a new valid value') do |updated_field|
  new_user_values = FactoryBot.build(:user)
  if updated_field == 'password'
    fill_in('user_password', with: 'Password1234!')
    fill_in('user_password_confirmation', with: 'Password1234!')
  else
    fill_in("user_#{updated_field}", with: new_user_values.send(updated_field))
  end
end

# Assumes @current_user is loaded and valid
When('I set the current password to confirm the change') do
  fill_in('user_current_password', with: @current_user.password)
end

Then('an ok flash message is present customized for the kind of update') do
  # This will depend from whether the email has been updated or not:
  flash_content = find('#flash-content-body .flash-body')
  expect(flash_content.text).to eq(
    I18n.t('devise.registrations.updated')
  ).or eq(
    I18n.t('devise.registrations.update_needs_confirmation')
  )
end

# Uses @matching_swimmer
When('I select the desired matching swimmer') do
  find('#user_swimmer_id').select(SwimmerDecorator.decorate(@matching_swimmer).text_label)
end

# Uses @current_user
When('I fill the email input with my address') do
  fill_in('user_email', with: @current_user.email)
end

When('I fill the email input with a non-existing address') do
  fill_in('user_email', with: FFaker::Internet.safe_email)
end
