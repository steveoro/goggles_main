# language:en

Feature: Chrono time recording setup
  As a logged-in user
  I want to be able to setup all the details regarding the type of Meeting or Workshop for an event
  So that I can record the elapsed times of any event with an embedded chronometer

  Background: API is working, user sign-in & correct starting page
    Given I have an associated swimmer and have already signed-in
    When I browse to '/chrono'
    And I click on the new recording button
    Then I am redirected to the Chrono setup page

  Scenario: invidivual event time recording setup for a meeting
    Given I select 'meeting' as the event container type
    And I see that my associated swimmer is already set as subject
    When I type 'MASTER FIN 2021' as selection for the 'season' pre-filled select field
    And I type '18° Trofeo De Akker' as selection for the 'meeting' Select2 field
    And I type 'Comunale Carmen Longo' as selection for the 'swimming_pool' Select2 field
    And I type '50 M' as selection for the 'pool_type' pre-filled select field
    And I type 'Bologna' as selection for the 'city' Select2 field
    And I type 'Bologna' as free input for the 'city_area' field
    And I see that 'IT' is already set as 'city_country_code' field
    And I see that the current date is already set as the date of the event
    And I type '100 RANA' as selection for the 'event_type' Select2 field
    And I type 'CSI Ober Ferrari' as selection for the 'team' Select2 field
    And I type 'M40' as selection for the 'category_type' Select2 field
    And I click on the go to chrono button
    Then I am redirected to the Chrono recording page
    And I see that the chosen swimmer is shown in the chrono header
    And I see that the current date is shown in the chrono header
    And I see that '18° Trofeo De Akker' is included in the chrono header
    And I see that 'Comunale Carmen Longo' is included in the chrono header
    And I see that '100 RANA' is included in the chrono header
    And I see that 'M40' is included in the chrono header

  Scenario: invidivual event time recording setup for a workshop
    Given I select 'workshop' as the event container type
    And I see that my associated swimmer is already set as subject
    When I type 'MASTER CSI 2021' as selection for the 'season' pre-filled select field
    And I type '1° Trial CSI RE' as selection for the 'user_workshop' Select2 field
    And I type 'Ferrari' as selection for the 'swimming_pool' Select2 field
    And I type '50 M' as selection for the 'pool_type' pre-filled select field
    And I type 'Reggio Emilia' as selection for the 'city' Select2 field
    And I type 'Reggio Emilia' as free input for the 'city_area' field
    And I see that 'IT' is already set as 'city_country_code' field
    And I see that the current date is already set as the date of the event
    And I type '50 FA' as selection for the 'event_type' Select2 field
    And I type 'CSI Ober Ferrari' as selection for the 'team' Select2 field
    And I type 'M50' as selection for the 'category_type' Select2 field
    And I click on the go to chrono button
    Then I am redirected to the Chrono recording page
    And I see that the chosen swimmer is shown in the chrono header
    And I see that the current date is shown in the chrono header
    And I see that '1° Trial CSI RE' is included in the chrono header
    And I see that 'Ferrari' is included in the chrono header
    And I see that '50 FA' is included in the chrono header
    And I see that 'M50' is included in the chrono header

  # Scenario: relay event time recording setup for a meeting
  #   # TODO (future development)

  # Scenario: relay event time recording setup for a workshop
  #   # TODO (future development)
