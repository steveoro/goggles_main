# language:en

Feature: Compute delta timings
  As a logged-in user
  In order to quickly compute the delta timings from a set of laps
  I want to input manually a finite set of timings
  And retrieve their resulting delta-t with the previous time for each row

  Scenario: delta-t calculator command directly accessible from the top menu
    Given I am not signed in
    When I browse to '/'
    And I open the drop-down top menu to see the available commands
    Then I should see the 'link-compute-deltas' command

  Scenario: using the delta-t calculator requires authentication
    Given I am not signed in
    And I have a confirmed account
    When I browse to 'tools/delta_timings'
    Then I get redirected to '/users/sign_in'
    When I fill the log-in form as the confirmed user
    Then the user row is signed-in
    And a flash 'devise.sessions.signed_in' message is present
    And I am at the delta-time calculator page

  Scenario Outline: compute delta-t and output text
    Given I am already signed-in and at the root page
    And I browse to '/tools/delta_timings'
    When I insert 0, 31 and 25 in the timing row 0
    And I insert 1, 7 and 32 in the timing row 1
    And I insert 1, 39 and 42 in the timing row 2
    And I insert 2, 23 and 57 in the timing row 3
    And I click on the compute delta-t button
    Then I see "0'31\"25" as the resulting delta-T value for row 0
    And I see "0'36\"07" as the resulting delta-T value for row 1
    And I see "0'32\"10" as the resulting delta-T value for row 2
    And I see "0'44\"15" as the resulting delta-T value for row 3

    When I click on the compute delta-t TXT output button
    Then the output delta text dialog appears
    And I see "0'31\"25" as one of the output delta-T text values
    And I see "0'36\"07" as one of the output delta-T text values
    And I see "0'32\"10" as one of the output delta-T text values
    And I see "0'44\"15" as one of the output delta-T text values
