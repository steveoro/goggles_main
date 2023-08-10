# language:en

Feature: Reporting an issue of type "1a"
  As a logged-in user
  I want to be able to report an issue of type "1a"
  ("new Meeting URL for data-import")

  Scenario: a new type "1a" request can be issued only by a signed-in user
    Given I am not signed in
    But I have a confirmed account
    When I browse to '/issues/faq_index'
    Then I get redirected to '/users/sign_in'
    When I fill the log-in form as the confirmed user
    Then I am at the '/issues/faq_index' page
    And I can see the issues FAQ breadcrumb title
    And I see the nav tab with the link to my issues grid
    And I see the expandable section for issues 'type1a'
    When I click to expand the issues section 'type1a'
    Then I see the issue form 'frm-type1a'

    When I type '18° Trofeo De Akker' as selection for the 'meeting' Select2 field
    And I type 'Bologna' as selection for the 'city' Select2 field
    And I type 'Bologna' as free input for the 'city_area' field
    And I see that 'IT' is already set as 'city_country_code' field
    And I see that the current date is already set as the date of the event
    And I fill-in the results URL for the issue form with a random URL
    And I scroll toward the end of the page to see the bottom of the page
    And I click on '#issues-type1a-post-btn' accepting the confirmation request
    Then I get redirected to '/issues/my_reports'
    And a flash 'issues.sent_ok' message is present
    And I see my newly created issue
