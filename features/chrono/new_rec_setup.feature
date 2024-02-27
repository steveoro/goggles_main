# language:en

Feature: Chrono time recording setup
  As a logged-in user with Team management grants
  I want to be able to setup all the details regarding the type of Meeting or Workshop for an event
  So that I can record the elapsed times of any event with an embedded chronometer

  Background: API is working, user sign-in & correct starting page
    Given I have an associated swimmer on a team manager account and have already signed-in
    When I browse to '/chrono'
    And I click on the new recording button
    Then I am redirected to the Chrono setup page


  Scenario: invidivual event time recording setup for a meeting
    Given I select 'meeting' as the event container type
    When I type 'MASTER FIN' as selection for the 'season' pre-filled select field
    And I type '18° Trofeo De Akker' as selection for the 'meeting' Select2 field
    Then I click on the 'next' button at the end of form step '1'
    And I see that form step '2' is displayed
    When I type 'Comunale Carmen Longo' as selection for the 'swimming_pool' Select2 field
    And I type '50 M' as selection for the 'pool_type' pre-filled select field
    And I type 'Bologna' as selection for the 'city' Select2 field
    And I type 'Bologna' as free input for the 'city_area' field
    And I see that 'IT' is already set as 'city_country_code' field
    Then I click on the 'next' button at the end of form step '2'
    And I see that form step '3' is displayed
    When I see that the current date is already set as the date of the event
    And I type '100 RANA' as selection for the 'event_type' Select2 field
    Then I click on the 'next' button at the end of form step '3'
    And I see that form step '4' is displayed
    When I see that my associated swimmer is already set as subject
    And I type 'CSI Ober Ferrari' as selection for the 'team' Select2 field
    And I type 'M40' as selection for the 'category_type' Select2 field
    Then I click on the 'next' button at the end of form step '4'
    And I see that form step '5' is displayed
    When I see that the chosen swimmer is shown in the chrono summary
    And I see that the current date is shown in the chrono summary
    And I see that '100 RANA' is included in the chrono summary
    And I click on the go to chrono button
    Then I am redirected to the Chrono recording page
    And I see that the chosen swimmer is shown in the chrono summary
    And I see that the current date is shown in the chrono summary
    And I see that '18° Trofeo De Akker' is included in the chrono summary
    And I see that 'Comunale Carmen Longo' is included in the chrono summary
    And I see that '100 RANA' is included in the chrono summary
    And I see that 'M40' is included in the chrono summary


  Scenario: invidivual event time recording setup for a workshop
    Given I select 'workshop' as the event container type
    When I type 'MASTER CSI' as selection for the 'season' pre-filled select field
    And I type '1° Trial CSI RE' as selection for the 'user_workshop' Select2 field
    Then I click on the 'next' button at the end of form step '1'
    And I see that form step '2' is displayed
    When I type 'Ferrari' as selection for the 'swimming_pool' Select2 field
    And I type '50 M' as selection for the 'pool_type' pre-filled select field
    And I type 'Reggio Emilia' as selection for the 'city' Select2 field
    And I type 'Reggio Emilia' as free input for the 'city_area' field
    And I see that 'IT' is already set as 'city_country_code' field
    Then I click on the 'next' button at the end of form step '2'
    And I see that form step '3' is displayed
    When I see that the current date is already set as the date of the event
    And I type '50 FA' as selection for the 'event_type' Select2 field
    Then I click on the 'next' button at the end of form step '3'
    And I see that form step '4' is displayed
    When I see that my associated swimmer is already set as subject
    And I type 'CSI Ober Ferrari' as selection for the 'team' Select2 field
    And I type 'M50' as selection for the 'category_type' Select2 field
    Then I click on the 'next' button at the end of form step '4'
    And I see that form step '5' is displayed
    When I see that the chosen swimmer is shown in the chrono summary
    And I see that the current date is shown in the chrono summary
    And I see that '50 FA' is included in the chrono summary
    And I click on the go to chrono button
    Then I am redirected to the Chrono recording page
    And I see that the chosen swimmer is shown in the chrono summary
    And I see that the current date is shown in the chrono summary
    And I see that '1° Trial CSI RE' is included in the chrono summary
    And I see that 'Ferrari' is included in the chrono summary
    And I see that '50 FA' is included in the chrono summary
    And I see that 'M50' is included in the chrono summary

  # Scenario: relay event time recording setup for a meeting
  #   # TODO (future development)

  # Scenario: relay event time recording setup for a workshop
  #   # TODO (future development)
