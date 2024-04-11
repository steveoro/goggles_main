# language:en

Feature: Show user workshop details
  As an anonymous user
  I want to be able to browse to the details page
  For any available workshop found in the database

  Scenario: browsing to a workshop details from the search results w/o login
    Given I am not signed in
    And there are more than 5 workshops matching my query 'Lake'
    When I browse to '/'
    And I search for 'Lake'
    Then the 'workshop' search results are displayed, all matching 'Lake'
    When I click on the first 'workshop' result to browse to its detail page
    Then I am at the show page for the details of the workshop
    But I can't see any of the 'report missing' ('type1b') buttons on the results of the page
    And I can't see any of the 'report mistake' ('type1b1') buttons on the results of the page
    And I can't see any of the lap edit buttons on the whole page

  Scenario: signed-in w/o specific grants & browsing workshop details only shows the "report missing" buttons
    Given I am already signed-in and at the root page
    And there are more than 5 workshops matching my query 'Workshop'
    When I search for 'Sukmouth Workshop'
    Then the 'workshop' search results are displayed, all matching 'Sukmouth Workshop'
    When I click on the first 'workshop' result to browse to its detail page
    Then I am at the show page for the details of the workshop
    And I can see the 'report missing' ('type1b') buttons on the results of the page
    But I can't see any of the 'report mistake' ('type1b1') buttons on the results of the page
    And I can't see any of the lap edit buttons on the whole page

  Scenario: signed-in w/ a swimmer & browsing own workshop results shows also the "report mistake" buttons
    Given I have a confirmed account with associated swimmer and existing user results
    And I sign-in with my existing account
    And I have already selected a random workshop from any of my available results
    When I browse to see the selected workshop details
    Then I am at the show page for the details of the workshop
    And I can see the 'report missing' ('type1b') buttons on the results of the page
    And I can see the 'report mistake' ('type1b1') buttons on the results of the page
    But I can't see any of the lap edit buttons on the whole page

  Scenario: signed-in team manager browsing managed workshop results shows every management button
    Given I have a confirmed team manager account managing some existing URs
    And I sign-in with my existing account
    And I have already selected a random workshop from any of my available results
    When I browse to see the selected workshop details
    Then I am at the show page for the details of the workshop
    And I can see the lap edit buttons on the page
    And I can see the 'report missing' ('type1b') buttons on the results of the page
    And I can see the 'report mistake' ('type1b1') buttons on the results of the page
