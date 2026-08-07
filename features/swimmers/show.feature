# language:en

Feature: Show swimmer details ('Radiography')
  As a visitor
  I want to browse any swimmer's radiography page
  And follow the available detail links (signing in when required)

  Scenario: browsing to a swimmer details page from the search results
    Given I am not signed in
    And there are more than 5 swimmers matching my query 'Anna'
    When I browse to '/'
    And I search for 'Anna'
    Then the 'swimmer' search results are displayed, all matching 'Anna'
    When I click on the first 'swimmer' result to browse to its detail page
    Then I am at the show page for the details of the swimmer
    And I see the swimmer's details table
    And I see the swimmer's details toolbar buttons

  Scenario: accessing Goggles Cup base timings from radiography requires authentication
    Given I have an associated swimmer on a confirmed account
    And I have a chosen a random swimmer with existing MIRs
    But I am not signed in
    When I browse to the radiography of the chosen swimmer
    And I see the swimmer's details table
    And I click on '#goggles-cup-base-timings'
    Then I get redirected to the sign-in page
    When I fill the log-in form as the confirmed user
    Then the user row is signed-in
    And a flash 'devise.sessions.signed_in' message is present
    And I am at the Goggles Cup base timings page of the chosen swimmer
    And I can see the chosen swimmer's name as subtitle of the Goggles Cup base timings page
    And I see the Goggles Cup base timings info note
    And I see the Goggles Cup base timings results table

  Scenario: logged-in user browsing Goggles Cup base timings from radiography
    Given I am already signed-in and at the root page
    And I have a chosen a random swimmer with existing MIRs
    When I browse to the radiography of the chosen swimmer
    And I see the swimmer's details table
    And I click on '#goggles-cup-base-timings'
    Then I am at the Goggles Cup base timings page of the chosen swimmer
    And I can see the chosen swimmer's name as subtitle of the Goggles Cup base timings page
    And I see the Goggles Cup base timings info note
    And I see the Goggles Cup base timings results table
