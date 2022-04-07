# language:en

Feature: Show swimmer details ('Radiography')
  As an anonymous user
  I want to be able to browse to the details page
  For any available swimmer found in the database

  Scenario: browsing to a swimmer details page from the search results
    Given I am not signed in
    And there are more than 5 swimmers matching my query 'Anna'
    When I browse to '/'
    And I search for 'Anna'
    Then the 'swimmer' search results are displayed, all matching 'Anna'
    When I click on the first 'swimmer' result to browse to its detail page
    Then I am at the show page for the details of the swimmer
    And I see the swimmer's details table
    And I see the swimmer's details toolbar buttons
