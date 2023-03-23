# language:en

Feature: Current season Calendar "starred" map
  As a logged-in user
  I want to be able to check all the "starred" and still "open" meetings
  from an actual map that displays their location

  Scenario: accessing & untagging in the "starred" calendar requires authentication but not an associated swimmer
    Given I am not signed in
    But I have a confirmed account
    And there are at least 5 calendar rows available
    And at least 3 calendar rows are not expired
    And at least 2 calendar rows are already starred for me
    When I browse to '/calendars/starred_map'
    Then I get redirected to '/users/sign_in'
    When I fill the log-in form as the confirmed user
    Then I am at the Calendars 'starred_map' page
    And I see the calendars map container
    And I see the calendars nav link to go back to the starred list
