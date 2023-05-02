# language:en

Feature: Reporting an issue of type "3b"
  As a logged-in user
  I want to be able to report an issue of type "3b"
  ("change swimmer association - free select")

  Scenario: a new type "3b" request can be issued only by a signed-in user
    Given I am not signed in
    But I have a confirmed account
    When I browse to '/issues/faq_index'
    Then I get redirected to '/users/sign_in'
    When I fill the log-in form as the confirmed user
    Then I am at the '/issues/faq_index' page
    And I can see the issues FAQ breadcrumb title
    And I see the nav tab with the link to my issues grid
    And I see the expandable section for issues 'type3b'
    When I click to expand the issues section 'type3b'
    Then I see the issue form 'frm-type3b'

    When I type 'LIGABUE MARCO' as selection for the 'swimmer' Select2 field
    And I click on '#issues-type3b-post-btn' accepting the confirmation request
    Then I get redirected to '/issues/my_reports'
    And a flash 'issues.sent_ok' message is present
    And I see my newly created issue
