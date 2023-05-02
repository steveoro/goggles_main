# language:en

Feature: Reported issues list
  As a logged-in user
  I want to be able to access the list of any issues I may have reported
  And I want to be able to also manage them (see the details or kill a request already sent)

  Scenario: accessing "My reports" list requires authentication
    Given I am not signed in
    But I have a confirmed account
    When I browse to '/issues/my_reports'
    Then I get redirected to '/users/sign_in'
    When I fill the log-in form as the confirmed user
    Then I am at the '/issues/my_reports' page
    And I can see the My issues breadcrumb title
    And I see the nav tab with the link to the issues FAQ
    And I can see the empty grid of my issues

  Scenario: accessing "My reports" list and deleting a row (signed-in w/ a swimmer)
    Given I am already signed-in and at the root page
    And there are some issue reports from the current_user
    When I browse to '/issues/my_reports'
    Then I am at the '/issues/my_reports' page
    And I can see the My issues breadcrumb title
    And I see the nav tab with the link to the issues FAQ
    And I see the grid with the issues created by me
    When I choose an issue row to be deleted, accepting the confirmation request
    Then I can see that the chosen issue row has been deleted
