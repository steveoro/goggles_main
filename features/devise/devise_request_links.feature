# language:en

@headless_chrome
Feature: User can request new management links: desktop, lg-size
  As an anonymous user with an existing account
  I want to be able to request a new links via email address
  In order to confirm my account, reset my password or unlock my account

  Scenario Outline: Successful link request
    Given I have <account_type>
    When I browse to <browse_location>
    When I fill the email input with my address
    And I click on '#send-request-btn'
    Then a flash 'devise.<controller_name>.send_instructions' message is present
    Examples:
      | account_type           | browse_location           | controller_name |
      | an unconfirmed account | '/users/confirmation/new' | confirmations   |
      | a locked account       | '/users/unlock/new'       | unlocks         |
      | a confirmed account    | '/users/password/new'     | passwords       |

  Scenario Outline: Failing link request
    Given I have <account_type>
    When I browse to <browse_location>
    And I fill the email input with a non-existing address
    And I click on '#send-request-btn'
    Then an error message from the edit form is present
    Examples:
      | account_type           | browse_location           |
      | an unconfirmed account | '/users/confirmation/new' |
      | a locked account       | '/users/unlock/new'       |
      | a confirmed account    | '/users/password/new'     |
