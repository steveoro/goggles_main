# language:en

Feature: New user sign-up
  As an anonymous user
  I want to be able to sign-up into the application
  Using direct account creation or a 3-rd party OAuth plugin

  Scenario: Successful direct sign-up
    Given I am not signed in
    When I browse to '/users/sign_up'
    And I fill the registration form as a new user
    Then the user account is persisted
    And the account is not yet confirmed
    And the user row is signed-in
    And I get redirected to '/'
    And a flash 'devise.registrations.signed_up' message is present

  @omniauth
  Scenario Outline: Successful OAuth sign-up
    Given I am not signed in
    And I have valid '<provider_sym>' credentials but no local account
    When I browse to '/users/sign_in'
    And I click on '#<provider_sym>-login-btn'
    Then the user account is persisted
    And the account is confirmed
    And I get redirected to '/'
    And a successful Omniauth flash message for '<provider_name>' is present
    When I browse to '/users/edit'
    Then I can see that my user is the one from the OAuth response
    Examples:
      | provider_sym  | provider_name |
      | google_oauth2 | Google        |
      | facebook      | Facebook      |

  Scenario: Failing direct sign-up
    Given I am not signed in
    When I browse to '/users/sign_up'
    And I fill the registration form as an existing user
    Then an error message from the edit form is present

  @omniauth
  Scenario Outline: Failing OAuth sign-up
    Given I am not signed in
    And I don't have valid credentials for '<provider_sym>' sign-in
    When I browse to '/users/sign_in'
    And I click on '#<provider_sym>-login-btn'
    And I get redirected to '/users/sign_up'
    And a flash 'devise.customizations.invalid_credentials' message is present
    Examples:
      | provider_sym  |
      | google_oauth2 |
      | facebook      |
