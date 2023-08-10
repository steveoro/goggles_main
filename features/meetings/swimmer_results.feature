# language:en

Feature: Show specific swimmer results for a specific meeting
  As an anonymous user
  I want to be able to browse the swimmer results page
  For any available meeting found in the database
  For either a swimmer of my choosing or my default associated swimmer if none specified
  (By design, in this page the 'report missing' buttons won't be available)

  Scenario: browsing directly to swimmer results w/o login
    Given I am not signed in
    And I have already selected a random meeting with available results
    When I browse to see the selected meeting swimmer results page
    Then I get redirected to '/'
    And a flash 'search_view.errors.invalid_request' message is present

  Scenario: w/o login browsing to swimmer results from meeting details
    Given I am not signed in
    And I have already selected a random meeting with available results
    When I browse to see the selected meeting details
    And I have chosen a random result among the current meeting details
    And I scroll toward the end of the page to see the bottom of the page
    And I click on the chosen meeting event section, waiting for it to load
    Then I see the results of the chosen meeting event
    And I scroll toward the end of the page to see the bottom of the page
    When I click on the swimmer name on the chosen result row, selecting it
    And I wait until the slow-rendered page portion 'section#meeting-swimmer-results' is visible
    Then I am at the chosen swimmer results page for the current meeting
    And I see the title with the link to go to the swimmer radiography
    And I see the swimmer results header table
    But I can't see any of the 'report missing' ('type1b') buttons on the results of the page
    And I can't see any of the 'report mistake' ('type1b1') buttons on the results of the page
    And I can't see any of the lap edit buttons on the whole page

  Scenario: signed-in w/o specific grants & browsing to swimmer results
    Given I am already signed-in and at the root page
    And I have already selected a random meeting with available results
    When I browse to see the selected meeting details
    And I have chosen a random result among the current meeting details
    And I scroll toward the end of the page to see the bottom of the page
    And I click on the chosen meeting event section, waiting for it to load
    Then I see the results of the chosen meeting event
    And I scroll toward the end of the page to see the bottom of the page
    When I click on the swimmer name on the chosen result row, selecting it
    And I wait until the slow-rendered page portion 'section#meeting-swimmer-results' is visible
    Then I am at the chosen swimmer results page for the current meeting
    And I see the title with the link to go to the swimmer radiography
    And I see the swimmer results header table
    And I can't see any of the 'report missing' ('type1b') buttons on the results of the page
    And I can't see any of the 'report mistake' ('type1b1') buttons on the results of the page
    And I can't see any of the lap edit buttons on the whole page

  Scenario: signed-in w/ a swimmer & browsing own swimmer results shows the "report mistake" buttons
    Given I have a confirmed account with associated swimmer and existing MIRs
    And I sign-in with my existing account
    And I have already selected a random meeting and an event from any of my available results
    When I browse to see the selected meeting details
    And I have chosen a random row from my own results
    And I scroll toward the end of the page to see the bottom of the page
    And I click on the chosen meeting event section, waiting for it to load
    Then I see the results of the chosen meeting event
    And I scroll toward the end of the page to see the bottom of the page
    When I click on the swimmer name on the chosen result row, selecting it
    And I wait until the slow-rendered page portion 'section#meeting-swimmer-results' is visible
    Then I am at the chosen swimmer results page for the current meeting
    And I see the title with the link to go to the swimmer radiography
    And I see the swimmer results header table
    And I can't see any of the 'report missing' ('type1b') buttons on the results of the page
    And I can't see any of the lap edit buttons on the whole page
    But I can see the 'report mistake' ('type1b1') buttons on the results of the page

  Scenario: signed-in team manager browsing managed swimmer results shows every available management button
    Given I have a confirmed team manager account managing some existing MIRs
    And I sign-in with my existing account
    And I have already selected a random meeting and an event from any of my available results
    When I browse to see the selected meeting details
    And I have chosen a random row from the results of my associated team
    And I scroll toward the end of the page to see the bottom of the page
    And I click on the chosen meeting event section, waiting for it to load
    Then I see the results of the chosen meeting event
    And I scroll toward the end of the page to see the bottom of the page
    When I click on the swimmer name on the chosen result row, selecting it
    And I wait until the slow-rendered page portion 'section#meeting-swimmer-results' is visible
    Then I am at the chosen swimmer results page for the current meeting
    And I see the title with the link to go to the swimmer radiography
    And I see the swimmer results header table
    And I can't see any of the 'report missing' ('type1b') buttons on the results of the page
    But I can see the 'report mistake' ('type1b1') buttons on the results of the page
    And I can see the lap edit buttons on the page
