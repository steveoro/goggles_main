# language:en

Feature: User can request account reactivation
  As an anonymous user with an existing deactivated account
  I want to be able to request a reactivation by email address

  Scenario Outline: Successful request
    Given I have a deactivated account
    And NO reactivation requests by me are pending
    When I browse to '/home/reactivate'
    When I fill the email input with my address
    And I click on '#send-request-btn'
    Then a flash 'devise.customizations.reactivation.msg.ok_sent' message is present
    And only 1 reactivation request by me is queued

  Scenario Outline: No request: invalid email
    Given I have a deactivated account
    When I browse to '/home/reactivate'
    And I fill the email input with a non-existing address
    And I click on '#send-request-btn'
    Then a flash 'devise.customizations.reactivation.msg.error_not_existing' message is present
    And NO reactivation requests by me are pending

  Scenario Outline: No request: account already active
    Given I have a confirmed account
    When I browse to '/home/reactivate'
    When I fill the email input with my address
    And I click on '#send-request-btn'
    Then a flash 'devise.customizations.reactivation.msg.error_not_deactivated' message is present
    And NO reactivation requests by me are pending

  Scenario Outline: No request: already queued
    Given I have a deactivated account
    And there is a single reactivation request by me already queued
    When I browse to '/home/reactivate'
    When I fill the email input with my address
    And I click on '#send-request-btn'
    Then a flash 'devise.customizations.reactivation.msg.error_already_requested' message is present
    And only 1 reactivation request by me is queued
