# language:en

Feature: Current season Calendar
  As a logged-in user
  I want to be able to check the list of current and still "open" meetings
  For any of the latest available championship seasons
  And I want to be able to "star" them as interesting for me
  Also, if I have team management grants
  I want to be able to tag any of these meeting as interesting for one of my teams

  Scenario: calendar access requires authentication but not an associated swimmer
    Given I am not signed in
    But I have a confirmed account
    And there are at least 3 calendar rows available
    And at least 2 calendar rows are not expired
    When I browse to '/calendars/current'
    Then I get redirected to '/users/sign_in'
    When I fill the log-in form as the confirmed user
    Then I am at the Calendars 'current' page
    And I can see the pagination controls on the calendar current page when there are enough rows
    And I can see the calendar row star button enabled or disabled depending on the row status
    But I cannot see the team row tag button available in any row

  Scenario: logged-in user without associated swimmer, tagging/untagging a row for himself
    Given I am already signed-in and at the root page
    And there are at least 3 calendar rows available
    And at least 2 calendar rows are not expired
    When I browse to '/calendars/current'
    Then I am at the Calendars 'current' page
    And I can see the pagination controls on the calendar current page when there are enough rows
    And I can see the calendar row star button enabled or disabled depending on the row status
    But I cannot see the team row tag button available in any row
    When I choose a row from the displayed calendar page to be starred for myself
    And I click to tag for myself the chosen calendar row
    Then I can see the chosen calendar row has been starred
    When I click to tag for myself the chosen calendar row
    Then I can see the chosen calendar row has been unstarred

  Scenario: logged-in user with Team Management grants, tagging/untagging a row for a team
    Given I have an associated swimmer on a team manager account and have already signed-in
    And there are at least 3 calendar rows available
    And at least 2 calendar rows are not expired
    When I browse to '/calendars/current'
    Then I am at the Calendars 'current' page
    And I can see the pagination controls on the calendar current page when there are enough rows
    And I can see the calendar row star button enabled or disabled depending on the row status
    And I can see the calendar team star button enabled or disabled depending on the row status
    When I choose a row from the displayed calendar page for team tagging
    And I click to tag the chosen calendar row for one of my teams
    Then the team star modal appears
    When I select the first team on the list to be tagged for the calendar
    And I click the team selection modal to confirm the default selection
    Then I can see the chosen calendar row has been tagged for the team
    When I click to tag the chosen calendar row for one of my teams
    And the team star modal appears
    And I click the team selection modal to confirm the default selection
    Then I can see the chosen calendar row has been untagged for the team
