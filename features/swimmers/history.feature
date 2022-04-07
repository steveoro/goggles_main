# language:en

Feature: Swimmer History details page
  As a logged-in user
  I want to be able to see the list of all results
  Filtered for a specific swimmer and a specific event type

  Scenario: accessing the history detail requires authentication
    Given I have an associated swimmer on a confirmed account
    And I have a chosen a random swimmer with existing MIRs
    And I have a chosen a random event type for the already chosen swimmer
    But I am not signed in
    When I browse to the history detail page for the chosen swimmer and event type
    Then I get redirected to the sign-in page
    When I fill the log-in form as the confirmed user
    Then the user row is signed-in
    And a flash 'devise.sessions.signed_in' message is present
    Then I am at the detailed history page for the chosen event type and swimmer
    And I can see the chosen swimmer's name as subtitle of the history detail page

  Scenario: logged-in user without associated swimmer browsing the history recap
    Given I am already signed-in and at the root page
    And I have a chosen a random swimmer with existing MIRs
    And I have a chosen a random event type for the already chosen swimmer
    When I browse to the history detail page for the chosen swimmer and event type
    Then I am at the detailed history page for the chosen event type and swimmer
    And I can see the chosen swimmer's name as subtitle of the history detail page
    And I see the history event line graph for the event types
    And I see the history datagrid for the event results
    And I see the history datagrid filtering controls
    When I click on random result link on the history detail grid
    Then I am at the show page for the details of the meeting
