# language:en

Feature: Reporting an issue of type "3c"
  As a logged-in user
  I want to be able to report an issue of type "3c"
  ("edit swimmer details - free text")

  Scenario: a new type "3c" request can be issued only by a signed-in user
    Given there is a confirmed account available
    When I browse to '/issues/faq_index'
    Then I get redirected to '/users/sign_in'
    When I fill the log-in form with the available credentials
    Then I am at the '/issues/faq_index' page
    And I can see the issues FAQ breadcrumb title
    And I see the nav tab with the link to my issues grid
    And I see the expandable section for issues 'type3c'
    When I click to expand the issues section 'type3c'
    Then I see the issue form 'frm-type3c'

    When I fill the 'type3c_first_name' field with 'LALO'
    And I fill the 'type3c_last_name' field with 'SALAMANCA'
    And I fill the 'type3c_year_of_birth' field with '1956'
    And I select 'MAS' for the 'type3c_gender_type_id' select field
    And I scroll toward the end of the page to see the bottom of the page
    And I click on '#issues-type3c-post-btn' accepting the confirmation request
    Then I get redirected to '/issues/my_reports'
    And a flash 'issues.sent_ok' message is present
    And I see my newly created issue
