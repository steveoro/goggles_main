# language:en

Feature: Show specific team results for a specific meeting
  As an anonymous user
  I want to be able to browse the team results page
  For any available meeting found in the database
  For either a team of my choosing or the default associated team if none specified

  Scenario: browsing directly to team results w/o login
    Given I am not signed in
    And I have already selected a random meeting with available results
    When I browse to see the selected meeting team results page
    Then I get redirected to '/'
    And a flash 'search_view.errors.invalid_request' message is present

  Scenario: w/o login browsing to team results from meeting details
    Given I am not signed in
    And I have already selected a random meeting with available results
    When I browse to see the selected meeting details
    And I have chosen a random result among the current meeting details
    And I click on the chosen meeting event section, waiting for it to load
    Then I see the results of the chosen meeting event
    When I click on the team name on the chosen result row, selecting it
    And I wait until the slow-rendered page portion 'section#meeting-team-results' is visible
    Then I am at the chosen team results page for the current meeting
    And I see the title with the link to go to the team radiography
    And I see the team results header
    And I see the team swimmers grid
    And I see the team events grid
    But I can't see any of the 'report missing' ('type1b') buttons on the results of the page
    And I can't see any of the 'report mistake' ('type1b1') buttons on the results of the page
    And I can't see any of the lap edit buttons on the whole page

  Scenario: signed-in w/o specific grants & browsing to team results only shows the "report missing" buttons
    Given I am already signed-in and at the root page
    And I have already selected a random meeting with available results
    When I browse to see the selected meeting details
    And I have chosen a random result among the current meeting details
    And I click on the chosen meeting event section, waiting for it to load
    Then I see the results of the chosen meeting event
    When I click on the team name on the chosen result row, selecting it
    And I wait until the slow-rendered page portion 'section#meeting-team-results' is visible
    Then I am at the chosen team results page for the current meeting
    And I see the title with the link to go to the team radiography
    And I see the team results header
    And I see the team swimmers grid
    And I see the team events grid
    And I can see the 'report missing' ('type1b') buttons on the results of the page
    But I can't see any of the 'report mistake' ('type1b1') buttons on the results of the page
    And I can't see any of the lap edit buttons on the whole page

  Scenario: signed-in w/ a swimmer & browsing own team results shows also the "report mistake" buttons
    Given I have a confirmed account with associated swimmer and existing MIRs
    And I sign-in with my existing account
    And I have already selected a random meeting and an event from any of my available results
    When I browse to see the selected meeting details
    And I have chosen a random row from the results of my associated team
    And I click on the chosen meeting event section, waiting for it to load
    Then I see the results of the chosen meeting event
    When I click on the team name on the chosen result row, selecting it
    And I wait until the slow-rendered page portion 'section#meeting-team-results' is visible
    Then I am at the chosen team results page for the current meeting
    And I see the title with the link to go to the team radiography
    And I see the team results header
    And I see the team swimmers grid
    And I see the team events grid
    And I can see the 'report missing' ('type1b') buttons on the results of the page
    And I can see the 'report mistake' ('type1b1') buttons on the results of the page
    But I can't see any of the lap edit buttons on the whole page

  Scenario: signed-in team manager browsing managed team results shows every management button
    Given I have a confirmed team manager account managing some existing MIRs
    And I sign-in with my existing account
    And I have already selected a random meeting and an event from any of my available results
    When I browse to see the selected meeting details
    And I have chosen a random row from the results of my associated team
    And I click on the chosen meeting event section, waiting for it to load
    Then I see the results of the chosen meeting event
    When I click on the team name on the chosen result row, selecting it
    And I wait until the slow-rendered page portion 'section#meeting-team-results' is visible
    Then I am at the chosen team results page for the current meeting
    And I see the title with the link to go to the team radiography
    And I see the team results header
    And I see the team swimmers grid
    And I see the team events grid
    And I can see the 'report missing' ('type1b') buttons on the results of the page
    And I can see the 'report mistake' ('type1b1') buttons on the results of the page
    And I can see the lap edit buttons on the page
