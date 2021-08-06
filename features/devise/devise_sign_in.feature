# language:en

Feature: Existing user sign-in
  As an anonymous user
  I want to be able to sign-in to the application
  Using direct log-in or a 3-rd party OAuth plugin

  Scenario: Successful direct sign-in
    Given I am not signed in
    And I have a confirmed account
    When I browse to '/users/sign_in'
    And I fill the log-in form as the confirmed user
    Then the user row is signed-in
    And I get redirected to '/'
    And a flash 'devise.sessions.signed_in' message is present

  @omniauth
  Scenario Outline: Successful OAuth sign-in
    Given I am not signed in
    And I have an existing account with an email valid for '<provider_sym>' sign-in
    When I browse to '/users/sign_in'
    And I click on '#<provider_sym>-login-btn'
    Then the user row is signed-in
    And I get redirected to '/'
    And a successful Omniauth flash message for '<provider_name>' is present
    Examples:
      | provider_sym  | provider_name |
      | facebook      | Facebook      |

  Scenario: Failing direct sign-in
    Given I am not signed in
    And I am a new user
    When I browse to '/users/sign_in'
    And I fill the log-in form as a new user
    Then I am still at the '/users/sign_in' path
    And an unsuccessful login flash message is present

  @omniauth
  Scenario: Failing OAuth sign-in
    Given I am not signed in
    And I have an existing account but I don't have credentials for '<provider_sym>' sign-in
    When I browse to '/users/sign_in'
    And I click on '#<provider_sym>-login-btn'
    And I get redirected to '/users/sign_up'
    And a flash 'devise.customizations.invalid_credentials' message is present
    Examples:
      | provider_sym  |
      | facebook      |
