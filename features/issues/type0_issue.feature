# language:en

Feature: Reporting an issue of type "0"
  As a logged-in user
  I want to be able to report an issue of type "0"
  ("request account ugrade to Team manager")

  Scenario: a new type "0" request can be issued only by a signed-in user
    Given I am not signed in
    But I have a confirmed account
    When I browse to '/issues/new_type0'
    Then I get redirected to '/users/sign_in'
    When I fill the log-in form as the confirmed user
    Then I am at the '/issues/new_type0' page
    And I see the issue form 'frm-type0'

    When I type 'Lake Ramiro Swimming Club ASD' as selection for the 'team' Select2 field
    And I choose to manage season at index 0 in form type0
    And I click on '#issues-type0-post-btn' accepting the confirmation request
    Then I get redirected to '/issues/my_reports'
    And a flash 'issues.sent_ok' message is present
    And I see my newly created issue
