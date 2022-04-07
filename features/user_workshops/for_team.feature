# language:en

Feature: Workshops index for any team
  As an anonymous user
  I want to be able to see the list of workshops for a specific team
  And filter the list either by workshop date or name
  And browse to the details of each workshop

  Background: accessing the workshop list for a chosen team does not require authentication
    Given I am not signed in
    And I have a chosen a random team with existing user results
    When I visit the workshops page for the chosen team
    Then I see the team's name in the meeting or workshop list title
    And I see the index grid list with filtering and pagination controls

  Scenario: browsing the workshop list for a team
    When I click on the first row to see the details of the first workshop
    Then I am at the show page for the details of the workshop

  Scenario: filtering the workshop list for a swimmer by date
    When I filter the workshops list by an earlier date than the first row present on the grid
    Then I see the applied filter in the top row label and at least the first workshop in the list

  Scenario: filtering the workshop list for a swimmer by workshop name or a portion of it
    When I filter the workshops list by a portion of the first name found on the grid
    Then I see the applied filter in the top row label and at least the first workshop in the list
