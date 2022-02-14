# language:en

Feature: Show team details
  As an anonymous user
  I want to be able to browse to the details page
  For any available team found in the database

  Scenario: browsing to a team details page from the search results
    Given I am not signed in
    And there are more than 5 teams matching my query 'Swimming'
    When I browse to '/'
    And I search for 'Swimming'
    Then the 'team' search results are displayed, all matching 'Swimming'
    When I click on the first 'team' result to browse to its detail page
    Then I am at the show page for the details of the team
