# language:en

Feature: RelayLaps modal editor management for MRRs-MRSs-RLs
  As a logged-in user with Team management grants
  I want to be able to view, create or edit the relay lap timings
  For any relay result from a Meeting of mine or my team mates
  Relay sections with swimmer will be handled as a one with their sub-laps
  Thus, deleting a swimmer fraction will also remove any associated relay (sub-)lap together with it

  Note: this feature scenario is tailored only for "long MRRs" (4x100/4x200)
  so that the widget for sublap management will be indeed rendered and available

  Scenario: signed-in team manager browsing results and managing relay laps and sub-laps
    Given I have a confirmed team manager account managing some existing MRRs with possible sublaps
    And I sign-in with my existing account
    And I have already selected a random meeting and a relay result from any of my available managed teams
    When I browse to see the selected meeting details
    Then I am at the show page for the details of the meeting
    When I scroll toward the end of the page to see the bottom of the page
    And I click on the chosen meeting event section, waiting for it to load
    Then I see the results of the chosen meeting event
    And I scroll toward the end of the page to see the bottom of the page
    And I can see the lap edit buttons on the page

    When I click the button to manage its relay laps
    Then the relay laps management modal dialog pops up showing its contents
    And there is a MRS edit form row with support for RelayLaps for each row belonging to the MRR

    When I add a new relay swimmer if allowed or select the last MRS section
    And I fill the last relay swimmer row with some random timing values
    And I scroll toward the end of the page to see the bottom of the page
    And I click to save my edited relay 'lap' row
    Then I see a successful flash notice on the lap-editor dialog header
    And I see my edited timing are present in the chosen row

    When I scroll toward the end of the page to see the bottom of the page
    And I dismiss the lap modal editor by clicking on the close button
    And I expand the chosen MRR details
    Then I see the chosen MRS row has updated the MRR details

    When I click the button to manage its relay laps
    And I add a new relay sub-lap if allowed or possibly select the last sub-lap available
    And I fill the last sub-lap row with some random timing values
    And I click to save my edited relay 'sublap' row
    Then I see a successful flash notice on the lap-editor dialog header
    And I see my edited timing are present in the chosen row

    When I scroll toward the end of the page to see the bottom of the page
    And I dismiss the lap modal editor by clicking on the close button
    And I expand the chosen MRR details
    Then I see the chosen sub-lap row has updated the MRR details in the event section

    When I click the button to manage its relay laps
    And I click to delete my chosen relay swimmer and confirm the deletion
    Then I can see the chosen lap is no longer shown in the editor

    When I scroll toward the end of the page to see the bottom of the page
    And I dismiss the lap modal editor by clicking on the close button
    Then The chosen MRS row is not shown anymore in the MRR details
