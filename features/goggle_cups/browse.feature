# language:en

Feature: Browse Goggle Cups
  As a team manager
  I want to browse pre-computed Goggle Cups for the teams I manage
  And view the stored rankings with base timings

  Background:
    Given I have an associated swimmer on a team manager account and have already signed-in
    And I have a pre-computed Goggle Cup for my managed team in "2025" for an enrolled swimmer

  Scenario: browsing and viewing a Goggle Cup ranking as a team manager
    Given I browse to "/"
    When I open the drop-down top menu to see the available commands
    Then I should see the "link-goggle-cups" command
    When I click on "#link-goggle-cups"
    Then I am still at the "/goggle_cups" path
    When I select "2025" as the championship year and my managed team
    And I click on the "Cerca" button
    Then I should see the cup title button
    When I click on the cup title
    Then I should see the swimmer name in the computed ranking
    And I should see the base timings toggle for the swimmer
