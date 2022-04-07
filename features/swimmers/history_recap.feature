# language:en

Feature: Swimmer History main page ('History recap')
  As a logged-in user
  I want to be able to see the list of event types any swimmer has attended
  And browse to a detailed history page enlisting all results for that event type

  Scenario: accessing the history recap requires authentication
    Given I have an associated swimmer on a confirmed account
    And I have a chosen a random swimmer with existing MIRs
    But I am not signed in
    When I browse to the radiography of the chosen swimmer
    And I click on '#swimmer-buttons #btn-stats'
    Then I get redirected to the sign-in page
    When I fill the log-in form as the confirmed user
    Then the user row is signed-in
    And a flash 'devise.sessions.signed_in' message is present
    And I am at the history recap page of the chosen swimmer
    And I can see the chosen swimmer's name as subtitle of the history recap page

  Scenario: logged-in user without associated swimmer browsing the history recap
    Given I am already signed-in and at the root page
    And I have a chosen a random swimmer with existing MIRs
    When I browse to the radiography of the chosen swimmer
    And I click on '#swimmer-buttons #btn-stats'
    Then I am at the history recap page of the chosen swimmer
    And I can see the chosen swimmer's name as subtitle of the history recap page
    And I see the overall pie graph for the event types
    And I see the list of attended event types
    When I click on random event type link on the history recap
    Then I am at the detailed history page for the chosen event type and swimmer
