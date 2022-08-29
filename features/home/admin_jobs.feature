# language:en

Feature: Background Job UI for Admins only
    Only as an admin user
    I want to be able to see in the top menu the jobs web-UI command
    And be able to browse to this jobs web-UI page

  Scenario: command hidden for anonymous users
    Given I am not signed in
    And I browse to '/'
    When I open the drop-down top menu to see the available commands
    Then I should NOT see the 'link-jobs' command

    When I browse to '/jobs'
    Then I get redirected to '/'
    And a flash 'search_view.errors.invalid_request' message is present

  Scenario: command hidden for a normal users
    Given I have a confirmed account
    And I sign-in with my existing account
    And I browse to '/'
    When I open the drop-down top menu to see the available commands
    Then I should NOT see the 'link-jobs' command

    When I browse to '/jobs'
    Then I get redirected to '/'
    And a flash 'search_view.errors.invalid_request' message is present

  Scenario: command shown for a user with admin grants
    Given I have a confirmed account with admin grants
    And I sign-in with my existing account
    And I browse to '/'
    When I open the drop-down top menu to see the available commands
    Then I should see the 'link-jobs' command

    When I browse to '/jobs'
    Then I can see the main Jobs web UI page
