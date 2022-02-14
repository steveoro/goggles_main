# language:en

Feature: My Dashboard
  As a logged-in user
  I want to be able to browse to a dashboard page
  That has shortcuts to the most important features
  Also, if I have team management grants
  I want to be able to manage the meeting reservations from my dashboard

  Scenario: accessing the dashboard requires authentication
    Given I am not signed in
    And I have a confirmed account
    When I browse to '/home/dashboard'
    Then I get redirected to '/users/sign_in'
    When I fill the log-in form as the confirmed user
    Then the user row is signed-in
    And a flash 'devise.sessions.signed_in' message is present
    And I am at my dashboard page

  Scenario: logged-in user without associated swimmer browsing the dashboard
    Given I am already signed-in and at the root page
    And I browse to '/home/dashboard'
    Then I am at my dashboard page
    And a flash 'home.my.errors.no_associated_swimmer' message is present
    And I see the button <button_id> <css_status>
    Examples:
      | button_id                | css_status |
      | 'btn-my-past-meetings'   | ''         |
      | 'btn-my-future-meetings' | 'disabled' |
      | 'btn-my-workshops'       | ''         |
      | 'btn-my-radiography'     | 'disabled' |
      | 'btn-my-stats'           | 'disabled' |
      | 'btn-plan-meeting'       | 'missing'  |
      | 'btn-team-reservations'  | 'missing'  |

  Scenario: logged-in user with associated swimmer browsing the dashboard
    Given I have an associated swimmer and have already signed-in
    And I browse to '/home/dashboard'
    Then I am at my dashboard page
    And I see the button <button_id> <css_status>
    Examples:
      | button_id                | css_status |
      | 'btn-my-past-meetings'   | ''         |
      | 'btn-my-future-meetings' | 'disabled' |
      | 'btn-my-workshops'       | ''         |
      | 'btn-my-radiography'     | ''         |
      | 'btn-my-stats'           | 'disabled' |
      | 'btn-plan-meeting'       | 'missing'  |
      | 'btn-team-reservations'  | 'missing'  |

  Scenario: logged-in user with associated swimmer and team manager grants browsing the dashboard
    Given I have an associated swimmer on team manager account and have already signed-in
    And I browse to '/home/dashboard'
    Then I am at my dashboard page
    And I see the button <button_id> <css_status>
    Examples:
      | button_id                | css_status |
      | 'btn-my-past-meetings'   | ''         |
      | 'btn-my-future-meetings' | 'disabled' |
      | 'btn-my-workshops'       | ''         |
      | 'btn-my-radiography'     | ''         |
      | 'btn-my-stats'           | 'disabled' |
      | 'btn-plan-meeting'       | 'disabled' |
      | 'btn-team-reservations'  | 'disabled' |
