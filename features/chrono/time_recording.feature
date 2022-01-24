# language:en

Feature: Chrono time recording setup
  As a logged-in user
  After detailed Meeting or Workshop event setup
  I want to be able to record the elapsed time of the event
  So that I can enqueue its results for later processing

  Background: user sign-in & correct starting page
    Given I have an associated swimmer and have already signed-in
    And I browse to '/chrono'
    When I click on the new recording button
    Then I am redirected to the Chrono setup page
    When I select 'workshop' as the event container type
    And I type 'MASTER CSI 2021' as selection for the 'season' pre-filled select field
    And I type '2° Trial CSI RE' as selection for the 'user_workshop' Select2 field
    Then I click on the 'next' button at the end of form step '1'
    And I see that form step '2' is displayed
    When I type 'Comunale Ferretti' as selection for the 'swimming_pool' Select2 field
    And I type '25 M' as selection for the 'pool_type' pre-filled select field
    And I type 'Reggio Emilia' as selection for the 'city' Select2 field
    And I type 'Reggio Emilia' as free input for the 'city_area' field
    And I see that 'IT' is already set as 'city_country_code' field
    Then I click on the 'next' button at the end of form step '2'
    And I see that form step '3' is displayed
    When I see that the current date is already set as the date of the event
    And I type '100 DO' as selection for the 'event_type' Select2 field
    Then I click on the 'next' button at the end of form step '3'
    And I see that form step '4' is displayed
    When I see that my associated swimmer is already set as subject
    And I type 'CSI Ober Ferrari' as selection for the 'team' Select2 field
    And I type 'M35' as selection for the 'category_type' Select2 field
    Then I click on the 'next' button at the end of form step '4'
    And I see that form step '5' is displayed
    When I see that the chosen swimmer is shown in the chrono summary
    And I click on the go to chrono button
    Then I am redirected to the Chrono recording page

  Scenario: invidivual event time recording with editing
    Given I should see the timer 'save' button 'disabled'
    And I should see the timer 'lap' button 'disabled'

    # Sub-scenario: RECORDING
    When I click on the timer 'start/stop' button
    Then I should see the timer 'lap' button 'enabled'
    And I wait for 1 seconds
    Then I click on the timer 'lap' button
    And I wait for 2 seconds
    Then I click on the timer 'lap' button
    And I wait for 3 seconds
    Then I click on the timer 'lap' button
    And I wait for 1 seconds
    When I click on the timer 'start/stop' button
    Then I should see a minimum of 7 seconds for the total elapsed time
    And I should see a list of 4 laps with the following times:
      | lap | time |
      |   1 |    1 |
      |   2 |    2 |
      |   3 |    3 |
      |   4 |    1 |
    And I should see the timer 'save' button 'enabled'

    # Sub-scenario: EDITING
    When I click to edit lap 1 timing with 10 seconds
    And I click to edit lap 2 timing with 11 seconds
    And I click to edit lap 3 timing with 14 seconds
    Then I should see a list of 4 laps with the following times:
      | lap | time |
      |   1 |   10 |
      |   2 |   11 |
      |   3 |   14 |
      |   4 |    2 |

    # Sub-scenario: SAVING / COMMITING
    When I click on the timer save button accepting the confirmation request
    Then I am redirected to the Chrono index page
    And I can see the chrono index page with an expandable row with details
