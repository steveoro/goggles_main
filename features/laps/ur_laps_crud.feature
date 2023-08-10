# language:en

Feature: Laps modal editor management for UserResults
  As a logged-in user with Team management grants
  I want to be able to view, create or edit the lap timings
  For any result from a Workshop of mine or my team mates

  Scenario: signed-in team manager browsing results and managing laps
    Given I have a confirmed team manager account managing some existing URs
    And I sign-in with my existing account
    And I have already selected a random workshop from any of my available results
    When I browse to see the selected workshop details
    Then I am at the show page for the details of the workshop
    And I can see the lap edit buttons on the page

    When I select a random user result from my chosen team
    And I click the button to manage its laps
    Then the laps management modal dialog pops up showing its contents
    And I can see the overall result on the last row of the table

    When I choose to add a 25m lap
    Then I see another empty lap row is added (only if the last distance is less than the goal)

    When I fill the last lap row with some random timing values
    And I click to save my edited lap
    Then I see my chosen lap has been correctly saved
    And I scroll toward the end of the page to see the bottom of the page
    And I dismiss the lap modal editor by clicking on the close button

    When I click the button to manage its laps
    And I see my chosen lap has been correctly saved
    And I click to delete my chosen lap and confirm the deletion
    Then I can see the chosen lap is no longer shown in the editor
    And I dismiss the lap modal editor by clicking on the close button
