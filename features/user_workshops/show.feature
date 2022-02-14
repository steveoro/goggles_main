# language:en

Feature: Show user workshop details
  As an anonymous user
  I want to be able to browse to the details page
  For any available workshop found in the database

  Scenario: browsing to a workshop details page from the search results
    Given I am not signed in
    And there are more than 5 workshops matching my query 'Lake'
    When I browse to '/'
    And I search for 'Lake'
    Then the 'workshop' search results are displayed, all matching 'Lake'
    When I click on the first 'workshop' result to browse to its detail page
    Then I am at the show page for the details of the workshop
