# language:en

Feature: Reporting an issue of type "1b"
  As a logged-in user
  I want to be able to report an issue of type "1b"
  ("missing result in existing Meeting")

  Scenario: signed-in user issues a new type "1b" request but there's no swimmer
    Given I am already signed-in and at the root page
    And there are more than 5 meetings matching my query 'Riccione'
    When I search for 'Riccione'
    Then the 'meeting' search results are displayed, all matching 'Riccione|ITALIANI|NAZIONALI'
    When I click on the first 'meeting' result to browse to its detail page
    Then I am at the show page for the details of the meeting
    And I can see the 'report missing' ('type1b') buttons on the results of the page
    When I click a random 'type1b' button on the page
    Then I am at the new issue 'type1b' page
    And I see the issue form 'frm-type1b'
    And I see that the 'swimmer' Select2 field is disabled
    And the issue 'type1b' form 'notice.no_associated_swimmer' text is visible
    And the issue 'type1b' form 'notice.cant_manage' text is visible

  Scenario: signed-in user w/ associated swimmer issues a new type "1b" request with swimmer R/O
    Given I have an associated swimmer on a confirmed account
    And I sign-in with my existing account
    And there are more than 5 meetings matching my query 'Riccione'
    When I search for 'Riccione'
    Then the 'meeting' search results are displayed, all matching 'Riccione|ITALIANI|NAZIONALI'
    When I click on the first 'meeting' result to browse to its detail page
    Then I am at the show page for the details of the meeting
    And I can see the 'report missing' ('type1b') buttons on the results of the page
    When I click a random 'type1b' button on the page
    Then I am at the new issue 'type1b' page
    And I see the issue form 'frm-type1b'
    And I see that the 'swimmer' Select2 field is disabled
    And the issue 'type1b' form 'notice.cant_manage' text is visible
    But the issue 'type1b' form 'notice.no_associated_swimmer' text is not visible
    And I see that my associated swimmer is already set as subject

    When I type '100 RANA' as selection for the 'event_type' Select2 field
    And I fill the result timing with random values
    And I click on '#issues-type1b-post-btn' accepting the confirmation request
    Then I get redirected to '/issues/my_reports'
    And a flash 'issues.sent_ok' message is present
    And I see my newly created issue

  Scenario: signed-in team manager issues a new type "1b" request in free-form
    Given I have a confirmed team manager account managing some existing MIRs
    And I sign-in with my existing account
    And there are more than 5 meetings matching my query 'Riccione'
    When I search for 'Riccione'
    Then the 'meeting' search results are displayed, all matching 'Riccione|ITALIANI|NAZIONALI'
    When I click on the first 'meeting' result to browse to its detail page
    Then I am at the show page for the details of the meeting
    And I can see the 'report missing' ('type1b') buttons on the results of the page
    When I click a random 'type1b' button on the page
    Then I am at the new issue 'type1b' page
    And I see the issue form 'frm-type1b'
    But the issue 'type1b' form 'notice.cant_manage' text is not visible
    And I see that the 'swimmer' Select2 field is enabled

    When I type '100 DORSO' as selection for the 'event_type' Select2 field
    And I type 'LIGABUE MARCO' as selection for the 'swimmer' Select2 field
    And I fill the result timing with random values
    And I click on '#issues-type1b-post-btn' accepting the confirmation request
    Then I get redirected to '/issues/my_reports'
    And a flash 'issues.sent_ok' message is present
    And I see my newly created issue
