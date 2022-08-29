# language:en

Feature: Show meeting details
  As an anonymous user
  I want to be able to browse to the details page
  For any available meeting found in the database

  Scenario: browsing to a meeting details page from the search results
    Given I am not signed in
    And there are more than 5 meetings matching my query 'Riccione'
    When I browse to '/'
    And I search for 'Riccione'
    Then the 'meeting' search results are displayed, all matching 'Riccione|CAMPIONATI ITALIANI|CAMPIONATI NAZIONALI'
    When I click on the first 'meeting' result to browse to its detail page
    Then I am at the show page for the details of the meeting
