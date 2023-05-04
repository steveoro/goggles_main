# language:en

Feature: Chrono index
  As a logged-in user with Team management grants
  I want to see the index of current or pending chrono requests made by me
  I want to see the details of each request
  I want to be able to delete a chrono request
  Also, if I have Admin grants
  I want to be able to download each pending request as a JSON file
  Conversely, a standard signed-in user shouldn't be able to even see the 'chrono' action in the menu

  Scenario: chrono command NOT accessible from default top menu
    Given I am not signed in
    When I browse to '/'
    And I open the drop-down top menu to see the available commands
    Then I should NOT see the 'link-chrono' command

  Scenario: chrono command accessible from top menu for Team managers
    Given I have an associated swimmer on a team manager account and have already signed-in
    When I open the drop-down top menu to see the available commands
    Then I should see the 'link-chrono' command

  Scenario: chrono command accessible from top menu for Admins
    Given I have Admin grants and have already signed-in and at the root page
    When I open the drop-down top menu to see the available commands
    Then I should see the 'link-chrono' command

  Scenario: using chrono requires authentication but also grants
    Given I am not signed in
    And I have a confirmed account
    When I browse to '/chrono'
    Then I get redirected to '/users/sign_in'
    When I fill the log-in form as the confirmed user
    Then the user row is signed-in
    And a flash 'search_view.errors.invalid_request' message is present
    And I am at the root page

  Scenario: no pending requests from the current user
    Given I have an associated swimmer on a team manager account and have already signed-in
    When I browse to '/chrono'
    Then I see the chrono index container with any remaining row for my user

  Scenario: some pending requests from the current user
    Given I have an associated swimmer on a team manager account and have already signed-in
    And there is a chrono recording request from the current_user with sibling rows
    When I browse to '/chrono'
    Then I can see the chrono index page including the latest request row with details
    When I delete the latest pending chrono request
    Then I see the chrono index container with any remaining row for my user
    And I see that the deleted request is missing from the index

  Scenario: some pending requests from the current user with Admin grants
    Given I have Admin grants and have already signed-in and at the root page
    And there is a chrono recording request from the current_user with sibling rows
    When I browse to '/chrono'
    Then I can see the chrono index page including the latest request row with details
    When I download the chrono request as a JSON file
    Then I can see the chrono request details in the JSON file structure
