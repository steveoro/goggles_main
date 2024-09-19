# language:en

Feature: Standard landing or root page
  As an anonymous user
  At the root page of the app
  I can see the version of the app
  I can follow the link to read more information about the app
  I can follow the link to read terms of use & privacy policy
  I can go to the page with a contact form
  And I can enter directly a search query

  Background: anonymous user
    Given I am not signed in

  Scenario: checking the landing page
    When I browse to '/'
    Then I see the version of the app at the bottom of the page
    And I see a link to read more information about the app
    And I see a link to read terms of use & privacy policy
    And I see a link to the contact form
    And I see the search box ready to use

  Scenario: browsing the about page
    When I browse to '/home/about'
    Then I see the 'updated-calendars' section
    And I see the 'about' section
    And I see the 'how-does-it-work' section
    And I see the 'who-we-are' section
    And I see the 'contributing' section
    And I see the 'faq' section
    And I see the 'privacy-policy' section
    And I see the 'legal-terms' section
    And I see the link to go back to the root page

  Scenario: using the contact us form requires authentication
    Given I have a confirmed account
    When I browse to '/home/contact_us'
    Then I get redirected to '/users/sign_in'
    When I fill the log-in form as the confirmed user
    Then the user row is signed-in
    And a flash 'devise.sessions.signed_in' message is present
    And I see the contact form
    When I fill in the contact form with a test message
    And I click on '#contact-us-send-btn' accepting the confirmation request
    Then I get redirected to '/'
    And a flash 'contact_us.message_sent' message is present
