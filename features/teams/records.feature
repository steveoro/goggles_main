# language:en

Feature: Team records page
    As a logged-in user
    I want to browse the individual records for a team
    either all-time or filtered by championship year
    arranged in events x categories grids for each gender and pool type

  Scenario: accessing the team records page requires authentication
    Given I have an associated swimmer on a confirmed account
    But I am not signed in
    When I browse to '/teams/show/1'
    And I click on '#btn-records'
    But the team records page is not displayed
    And I get redirected to the sign-in page
    And a flash 'devise.failure.unauthenticated' message is present
    When I fill the log-in form as the confirmed user
    And I wait up to 90 seconds for the '#records-accordion' element to appear
    Then the user row is signed-in
    And a flash 'devise.sessions.signed_in' message is present
    And I am at the team records page for team ID 1

  Scenario: logged-in user browsing the "all time" team records grids
    Given I am already signed-in and at the root page
    When I browse to '/teams/show/1'
    And I click on '#btn-records'
    And I wait up to 90 seconds for the '#records-accordion' element to appear
    Then I am at the team records page for team ID 1
    And I see the team records tabs
    And I see the 4 pool x gender team records grids
    When I expand the first team records grid
    Then I see its events x categories matrix with record cells
    And I see the PDF export button

  Scenario: logged-in user filtering the records by championship year
    Given I am already signed-in and at the root page
    When I browse to '/teams/records/1'
    And I wait up to 90 seconds for the '#records-accordion' element to appear
    Then I see the championship year tabs
    When I click on a different championship year tab
    And I wait up to 90 seconds for the '#records-accordion' element to appear
    Then I see the 4 pool x gender team records grids

  Scenario: downloading the PDF export of the records grids
    Given I am already signed-in and at the root page
    When I browse to '/teams/records/1'
    Then I see the PDF export button
    When I click on '#btn-records-pdf'
    Then a PDF file for the team records grids is downloaded
