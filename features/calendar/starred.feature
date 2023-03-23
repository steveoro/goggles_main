# language:en

Feature: Current season Calendar "starred" meetings
  As a logged-in user
  I want to be able to check the list of "starred" and still "open" meetings
  That should include any meeting starred by me or by my team manager
  From this list, I also want to be able to untag them, when possible
  (Untagging team-starred meetings should require team management grants)

  Scenario: accessing & untagging in the "starred" calendar requires authentication but not an associated swimmer
    Given I am not signed in
    But I have a confirmed account
    And there are at least 5 calendar rows available
    And at least 3 calendar rows are not expired
    And at least 2 calendar rows are already starred for me
    When I browse to '/calendars/starred'
    Then I get redirected to '/users/sign_in'
    When I fill the log-in form as the confirmed user
    Then I am at the Calendars 'starred' page
    And I can see the pagination controls on the calendar starred page when there are enough rows
    And I can see the calendar row star button enabled or disabled depending on the row status
    But I cannot see the team row tag button available in any row
    And I can only see starred calendar rows
    When I choose a row from the displayed calendar page to be unstarred
    And I click to tag for myself the chosen calendar row
    Then I can see the chosen calendar row has been unstarred for me

  Scenario: logged-in user with Team Management grants, taging/untagging a row for a team
    Given I have an associated swimmer on a team manager account and have already signed-in
    And there are at least 5 calendar rows available
    And at least 3 calendar rows are not expired
    And at least 2 calendar rows are already starred for me
    When I browse to '/calendars/starred'
    Then I am at the Calendars 'starred' page
    And I can see the pagination controls on the calendar starred page when there are enough rows
    And I can only see starred calendar rows
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
