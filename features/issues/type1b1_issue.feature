# language:en

Feature: Reporting an issue of type "1b1"
  As a logged-in user
  I want to be able to report an issue of type "1b1"
  ("wrong result in existing Meeting")

  Scenario: reporting an issue of type "1b1" requires an associated swimmer
    Given I have a confirmed account with associated swimmer and existing MIRs
    And I sign-in with my existing account
    And I have already selected a random meeting from any of my available results
    When I browse to see the selected meeting details
    Then I am at the show page for the details of the meeting
    When I choose a random event from the clickable list of the meeting
    And I click on the chosen meeting event section, waiting for it to load
    Then I see the results of the chosen meeting event
    And I can see the 'report mistake' ('type1b1') buttons on the results of the page

    When I click a random 'type1b1' button on the page
    Then I am at the new issue 'type1b1' page
    And the active nav tab is 'type1b1'
    And I see the issue form 'frm-type1b1'

    When I fill the result timing with a random correction
    And I click on '#issues-type1b1-post-btn' accepting the confirmation request
    Then I get redirected to '/issues/my_reports'
    And a flash 'issues.sent_ok' message is present
    And I see my newly created issue
