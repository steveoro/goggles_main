# language:en

@headless_chrome_iphone4
Feature: Maintenance switch
  At any moment, by setting the "maintenance mode" on
  Any request should be redirected to a static maintenance page
  Conversely, if the "maintenance mode" is off
  I shouldn't be able to browse to the maintenance page

  Scenario Outline: Maintenance mode on, request gets redirected
    Given maintenance mode is 'on'
    When I browse to <destination_path>
    Then I get redirected to '/maintenance'
    And I can see the maintenance page
    Examples:
      | destination_path       |
      | '/'                    |
      | '/search/smart'        |
      | '/home/about_us'       |
      | '/home/about_this'     |
      | '/home/contact_us'     |
      | '/home/privacy_policy' |
      | '/swimmer/show'        |
      | '/tools/fin_score'     |

  Scenario: Maintenance mode on, browsing to the maintenance page itself
    Given maintenance mode is 'on'
    When I browse to '/maintenance'
    Then I can see the maintenance page

  Scenario: Maintenance mode off, browsing to the maintenance page itself
    Given maintenance mode is 'off'
    When I browse to '/maintenance'
    Then I get redirected to '/'
