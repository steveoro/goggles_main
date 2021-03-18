# language:en

@headless_chrome
Feature: Existing user can delete account: desktop, lg-size
  As logged-in user
  I want to be able to delete my account

  Scenario: Successful account deletion
    Given I am already signed-in and at the root page
    And I browse to '/users/edit'
    When I click on '#delete-account-btn' accepting the confirmation request
    Then I get redirected to '/'
    And the account is deleted
    And a flash 'devise.registrations.destroyed' message is present

  Scenario: Abort account deletion
    Given I am already signed-in and at the root page
    And I browse to '/users/edit'
    When I click on '#delete-account-btn' rejecting the confirmation request
    Then the account is still existing
    And the user row is signed-in
