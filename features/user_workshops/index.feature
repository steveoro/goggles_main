# language:en

Feature: My user workshops index
  As a logged-in user
  I want to be able to see the list of workshops I have attended or created
  And filter the list either by workshop date or name
  And browse to the details of each workshop

  Scenario: accessing the index list requires authentication
    Given I have an associated swimmer on a confirmed account
    But I am not signed in
    When I browse to '/user_workshops'
    Then I get redirected to '/users/sign_in'
    When I fill the log-in form as the confirmed user
    Then the user row is signed-in
    And a flash 'devise.sessions.signed_in' message is present
    And I am at my workshops page

  Scenario: logged-in user without associated swimmer browsing the index
    Given I am already signed-in and at the root page
    When I browse to '/user_workshops'
    Then I get redirected to '/'
    And a flash 'home.my.errors.no_associated_swimmer' message is present

  Scenario: logged-in user with results browsing the index list
    Given I have a confirmed account with associated swimmer and existing user results
    And I sign-in with my existing account
    When I browse to '/user_workshops'
    Then I am at my workshops page
    And I see my workshops title
    And I see the link to go back to the dashboard
    And I see the index grid list with filtering and pagination controls

    Given my associated swimmer is already the chosen swimmer for the meeting list
    When I filter the workshops list by an earlier date than the first row present on the grid
    Then I see the applied filter in the top row label and at least the first workshop in the list
    When I filter the workshops list by a portion of the first name found on the grid
    Then I see the applied filter in the top row label and at least the first workshop in the list
    When I click on the first row to see the details of the first workshop
    Then I am at the show page for the details of the workshop
