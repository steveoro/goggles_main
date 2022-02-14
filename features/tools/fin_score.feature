# language:en

Feature: Compute FIN target score or target timing
  As a logged-in user
  In order to compute the target FIN score from a result time
  Or in order to compute the target timing from a resulting FIN score
  I want to select any kind of event, pool, gender and category types
  And I want to be able to compute its target value given either the resulting score or its timing

  Scenario: using the score calculator requires authentication
    Given I am not signed in
    And I have a confirmed account
    When I browse to 'tools/fin_score'
    Then I get redirected to '/users/sign_in'
    When I fill the log-in form as the confirmed user
    Then the user row is signed-in
    And a flash 'devise.sessions.signed_in' message is present
    And I am at the FIN score & time calculator page

  # [Steve, 20211206] *UNSTABLE*/FLAKY: skipped
  # - sometimes the stub is detected, sometimes it is not
  # - see features/support/webmock.rb
  # - even with "--no-strict-flaky --retry 2" as Cucumber options it still fails sometimes
  @api @skip
  Scenario Outline: compute target score
    Given I am already signed-in and at the root page
    And I browse to '/tools/fin_score'
    When I select <event_type>, <pool_type>, <category_type> and <gender_type> as FIN score parameters
    And I insert <minutes>, <seconds> and <hundredths> as FIN target timing
    And I click on the request FIN target score button
    Then I can see a non-zero FIN target score result
    Examples:
      | event_type | pool_type | category_type | gender_type | minutes | seconds | hundredths |
      | '200 DO' | '50 M' | 'M40' | 'F' | 2 | 55 | 50 |
      | '50 RA'  | '50 M' | 'M50' | 'M' | 0 | 35 | 0  |
      | '100 RA' | '50 M' | 'M45' | 'M' | 1 | 24 | 36 |

  @api @skip
  Scenario Outline: compute target timing
    Given I am already signed-in and at the root page
    And I browse to '/tools/fin_score'
    When I select <event_type>, <pool_type>, <category_type> and <gender_type> as FIN score parameters
    And I insert <score> as FIN target score
    And I click on the request FIN target timing button
    Then I can see a non-zero FIN target timing result
    Examples:
      | event_type | pool_type | category_type | gender_type | score |
      | '50 DO'  | '25 M' | 'M50' | 'F' | 851 |
      | '100 FA' | '50 M' | 'M45' | 'M' | 852 |
      | '200 RA' | '25 M' | 'M35' | 'F' | 853 |
