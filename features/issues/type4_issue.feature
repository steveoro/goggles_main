# language:en

Feature: Reporting an issue of type "4"
  As a logged-in user
  I want to be able to report an issue of type "4"
  ("generic application error or bug")

  Scenario: a new type "4" request can be issued only by a signed-in user
    Given I am not signed in
    But I have a confirmed account
    When I browse to '/issues/faq_index'
    Then I get redirected to '/users/sign_in'
    When I fill the log-in form as the confirmed user
    Then I am at the '/issues/faq_index' page
    And I can see the issues FAQ breadcrumb title
    And I see the nav tab with the link to my issues grid
    And I see the expandable section for issues 'type4'
    When I click to expand the issues section 'type4'
    Then I see the issue form 'frm-type4'

    When I fill the 'expected' field with 'Simple result browsing'
    And I fill the 'outcome' field with 'Everything exploded'
    And I fill the 'reproduce' field with 'click on the red button and wait'
    And I scroll toward the end of the page to see the bottom of the form
    And I click on '#issues-type4-post-btn' accepting the confirmation request
    Then I get redirected to '/issues/my_reports'
    And a flash 'issues.sent_ok' message is present
    And I see my newly created issue
