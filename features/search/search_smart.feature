# language:en

@javascript
Feature: Search anything from the root page: desktop, lg-size
  At the root page of the app
  As an anonymous user
  I want to be able to perform a search with a single query
  For any swimmer, team, meeting or swimming pool

  Scenario: Successful search, swimmer matches + pagination
    Given there are > 5 swimmers matching my query 'Anna'
    When I browse to the root page
    And I search for 'Anna'
    Then the 'swimmer' search results are displayed, all matching 'Anna'
    And the pagination controls are visible

  Scenario: Successful search, swimmer matches, no pagination
    Given there are <= 5 swimmers matching my query 'Steve'
    When I browse to the root page
    And I search for 'Steve'
    Then the 'swimmer' search results are displayed, all matching 'Steve'
    And the pagination controls are not present
