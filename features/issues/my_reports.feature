# language:en

Feature: Reported issues list
  As a logged-in user
  I want to be able to access the list of any issues I may have reported
  And I want to be able to also manage them (see the details or kill a request already sent)

  Scenario: accessing the "My reports" list requires authentication
    Given I am not signed in
    But I have a confirmed account
    When I browse to '/issues/my_reports'
    Then I get redirected to '/users/sign_in'
    When I fill the log-in form as the confirmed user
    Then I am at the '/issues/my_reports' page
    And I can see the My issues breadcrumb title
    And I see the nav tab with the link to the issues FAQ
    And I can see the empty grid of my issues

    # TODO: (c)RUD issue row management, random type
