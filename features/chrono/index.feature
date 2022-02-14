# language:en

Feature: Chrono index
  As a logged-in user
  I want to see the index of current or pending chrono requests made by me
  I want to see the details of each request
  I want to be able to delete a chrono request
  Also, if I have Admin grants
  I want to be able to download each pending request as a JSON file

  Scenario: using chrono requires authentication
    Given I am not signed in
    And I have a confirmed account
    When I browse to '/chrono'
    Then I get redirected to '/users/sign_in'
    When I fill the log-in form as the confirmed user
    Then the user row is signed-in
    And a flash 'devise.sessions.signed_in' message is present
    And I am at the Chrono index page

  Scenario: no pending requests from the current user
    Given I am already signed-in and at the root page
    When I browse to '/chrono'
    Then I can see the empty chrono index page

  Scenario: some pending requests from the current user
    Given I am already signed-in and at the root page
    And there is a chrono recording request from the current_user with sibling rows
    When I browse to '/chrono'
    Then I can see the chrono index page with an expandable row with details
    When I delete the pending chrono request
    Then I can see the empty chrono index page

  Scenario: some pending requests from the current user with Admin grants
    Given I have Admin grants and have already signed-in and at the root page
    And there is a chrono recording request from the current_user with sibling rows
    When I browse to '/chrono'
    Then I can see the chrono index page with an expandable row with details
    When I download the chrono request as a JSON file
    Then I can see the chrono request details in the JSON file structure
