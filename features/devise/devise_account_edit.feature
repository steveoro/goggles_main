# language:en

@headless_chrome
Feature: Existing user can edit account: desktop, lg-size
  As logged-in user
  I want to be able to edit my account

  Scenario Outline: Successful basic account update
    Given I am already signed-in and at the root page
    When I browse to '/users/edit'
    And I update the '<updated_field>' field with a new valid value
    And I set the current password to confirm the change
    And I click on '#update-account-btn'
    Then I get redirected to '/'
    And an ok flash message is present customized for the kind of update
    Examples:
      | updated_field |
      | email         |
      | name          |
      | password      |
      | first_name    |
      | last_name     |
      | year_of_birth |

  Scenario: Successful swimmer association change
    Given I am already signed-in and at the root page
    And I have an available matching swimmer for my user
    When I browse to '/users/edit'
    And I click on '#toggle-swimmer-edit-btn'
    And I select the desired matching swimmer
    And I set the current password to confirm the change
    And I click on '#update-account-btn'
    Then I get redirected to '/'
    And a flash 'devise.registrations.updated' message is present

  Scenario Outline: Failing basic account update (no current password)
    Given I am already signed-in and at the root page
    When I browse to '/users/edit'
    And I update the '<updated_field>' field with a new valid value
    And I click on '#update-account-btn'
    Then an error message from the edit form is present
    Examples:
      | updated_field |
      | email         |
      | name          |
      | password      |
      | first_name    |
      | last_name     |
      | year_of_birth |
