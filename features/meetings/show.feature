# language:en

Feature: Show meeting details
  As an anonymous user
  I want to be able to browse to the details page
  For any available meeting found in the database

  Scenario: browsing to meeting details from the search results w/o login
    Given I am not signed in
    And there are more than 5 meetings matching my query 'Riccione'
    When I browse to '/'
    And I search for 'Riccione'
    Then the 'meeting' search results are displayed, all matching 'Riccione|ITALIANI|NAZIONALI'
    When I click on the first 'meeting' result to browse to its detail page
    Then I am at the show page for the details of the meeting
    When I choose a random event from the clickable list of the meeting
    And I click on the chosen meeting event section, waiting for it to load
    Then I see the results of the chosen meeting event
    But I can't see any of the 'report missing' ('type1b') buttons on the results of the page
    And I can't see any of the 'report mistake' ('type1b1') buttons on the results of the page
    And I can't see any of the lap edit buttons on the whole page

  Scenario: signed-in w/o specific grants & browsing meeting details only shows the "report missing" buttons
    Given I am already signed-in and at the root page
    And there are more than 5 meetings matching my query 'Riccione'
    When I search for 'Riccione'
    Then the 'meeting' search results are displayed, all matching 'Riccione|ITALIANI|NAZIONALI'
    When I click on the first 'meeting' result to browse to its detail page
    Then I am at the show page for the details of the meeting
    When I choose a random event from the clickable list of the meeting
    And I click on the chosen meeting event section, waiting for it to load
    Then I see the results of the chosen meeting event
    And I can see the 'report missing' ('type1b') buttons on the results of the page
    But I can't see any of the 'report mistake' ('type1b1') buttons on the results of the page
    And I can't see any of the lap edit buttons on the whole page

  Scenario: signed-in w/ a swimmer & browsing own meeting results shows also the "report mistake" buttons
    Given I have a confirmed account with associated swimmer and existing MIRs
    And I sign-in with my existing account
    And I have already selected a random meeting and an event from any of my available results
    When I browse to see the selected meeting details
    And I am at the show page for the details of the meeting
    And I click on the chosen meeting event section, waiting for it to load
    Then I see the results of the chosen meeting event
    And I can see the 'report missing' ('type1b') buttons on the results of the page
    And I can see the 'report mistake' ('type1b1') buttons on the results of the page
    But I can't see any of the lap edit buttons on the whole page

  Scenario: signed-in team manager browsing managed meeting results shows every management button
    Given I have a confirmed team manager account managing some existing MIRs
    And I sign-in with my existing account
    And I have already selected a random meeting and an event from any of my available results
    When I browse to see the selected meeting details
    And I am at the show page for the details of the meeting
    And I click on the chosen meeting event section, waiting for it to load
    Then I see the results of the chosen meeting event
    And I can see the 'report missing' ('type1b') buttons on the results of the page
    And I can see the 'report mistake' ('type1b1') buttons on the results of the page
    And I can see the lap edit buttons on the page
