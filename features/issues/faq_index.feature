# language:en

Feature: Issues FAQ index
  As a logged-in user
  I want to be able to read the list of commonly known issue types
  With links and explanations to report them

  Scenario: accessing the issues FAQ index requires authentication
    Given I have a confirmed account
    And I am not signed in
    When I browse to '/issues/faq_index'
    Then I get redirected to '/users/sign_in'
    When I fill the log-in form as the confirmed user
    Then I am at the '/issues/faq_index' page
    And I can see the issues FAQ breadcrumb title
    And I see the nav tab with the link to my issues grid
    And I see the expandable section for issues 'type1a'
    And I see the expandable section for issues 'type1b'
    And I see the expandable section for issues 'type1c'
    And I see the expandable section for issues 'type1d'
    And I see the expandable section for issues 'type2a'
    And I see the expandable section for issues 'type2b'
    And I see the expandable section for issues 'type3a'
    And I see the expandable section for issues 'type3b'
    And I see the expandable section for issues 'type3c'
    And I see the expandable section for issues 'type4'
