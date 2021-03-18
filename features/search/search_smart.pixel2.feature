# language:en

@headless_chrome_pixel2
Feature: Search anything from the root page: desktop, lg-size
  At the root page of the app
  As an anonymous user
  I want to be able to perform a search with a single query
  For any swimmer, team, meeting or swimming pool

  Scenario Outline: Successful search with matches & pagination
    Given there are more than <min_count> <model_name>s matching my query <query_string>
    When I browse to '/'
    And I search for <query_string>
    Then the '<model_name>' search results are displayed, all matching <query_string>
    And the pagination controls are visible
    Examples:
      | model_name    | query_string | min_count |
      | swimmer       | 'Anna'       |         5 |
      | team          | 'Swimming'   |         5 |
      | meeting       | 'prova'      |         5 |
      | swimming_pool | 'comunale'   |         5 |

  Scenario Outline: Successful search with matches but no pagination
    Given there are no more than <max_count> <model_name>s matching my query <query_string>
    When I browse to '/'
    And I search for <query_string>
    Then the '<model_name>' search results are displayed, all matching <query_string>
    And the pagination controls are not present
    # (No meetings in examples on purpose: it's difficult to have <= 5 search matches)
    Examples:
      | model_name    | query_string | max_count |
      | swimmer       | 'Steve'      |         5 |
      | team          | 'Abbottton'  |         5 |
      | swimming_pool | 'ferretti'   |         5 |

  Scenario: Unsuccessful search
    Given there are no swimmers matching my query 'zzz'
    And there are no teams matching my query 'zzz'
    And there are no meetings matching my query 'zzz'
    And there are no swimming_pools matching my query 'zzz'
    When I browse to '/'
    And I search for 'zzz'
    Then no search results are visible
    And a flash alert is shown about the empty results
