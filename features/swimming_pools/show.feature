# language:en

Feature: Show swimming pool details
  As an anonymous user
  I want to be able to browse to the details page
  For any available swimming pool found in the database

  Scenario: browsing to a swimming pool details page from the search results
    Given I am not signed in
    And there are more than 5 swimming_pools matching my query 'comunale'
    When I browse to '/'
    And I search for 'comunale'
    Then the 'swimming_pool' search results are displayed, all matching 'comunale'
    When I click on the first 'swimming_pool' result to browse to its detail page
    Then I am at the show page for the details of the swimming pool
