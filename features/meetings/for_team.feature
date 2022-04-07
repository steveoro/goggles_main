# language:en

Feature: Past meetings index for any team
  As an anonymous user
  I want to be able to see the list of meetings for a specific team
  And filter the list either by meeting date or name
  And browse to the details of each meeting

  Background: accessing the meeting list for a chosen team does not require authentication
    Given I am not signed in
    And I have a chosen a random team with existing MIRs
    When I visit the meetings page for the chosen team
    Then I see the team's name in the meeting or workshop list title
    And I see the index grid list with filtering and pagination controls

  Scenario: browsing the meeting list for a team
    When I click on the first row to see the details of the first meeting
    Then I am at the show page for the details of the meeting

  Scenario: filtering the meeting list for a team by date
    When I filter the meetings list by an earlier date than the first row present on the grid
    Then I see the applied filter in the top row label and at least the first meeting in the list

  Scenario: filtering the meeting list for a team by meeting name or a portion of it
    When I filter the meetings list by a portion of the first name found on the grid
    Then I see the applied filter in the top row label and at least the first meeting in the list
