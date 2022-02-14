# language:en

Feature: List of current team swimmers
    As a logged-in user
    I want to be able to see the full list of swimmers belonging to a team
    And filter the list either by season or name
    And browse to the details of each swimmer

  Scenario: accessing the index list requires authentication
    Given I have an associated swimmer on a confirmed account
    But I am not signed in
    When I browse to '/team/show/1'
    And click on the 'Swimmers' link
    Then I get redirected to '/users/sign_in'
    When I fill the log-in form as the confirmed user
    Then the user row is signed-in
    And a flash 'devise.sessions.signed_in' message is present
    And I am at the team swimmers page index for team ID 1

  Scenario: logged-in user without associated swimmer browsing the team swimmers index
    Given I am already signed-in and at the root page
    When I browse to '/team/show/1'
    Then I am at the team swimmers page index for team ID 1
    And pending
