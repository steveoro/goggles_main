# language:en

@throttle
Feature: Too many anonymous requests
  As an anonymous user
  When I make too many requests without signing in
  I see a page explaining that I need to log in
  And I can still access the sign-in page from the top menu bar

  Background: anonymous user
    Given I am not signed in

  Scenario: browsing normally under the limit works fine
    Given the anonymous request limit is set to 500
    When I browse to '/'
    Then I see the search box ready to use

  Scenario: exceeding the anonymous request limit shows the throttle page
    Given the anonymous request limit is set to 2
    And I have made 3 anonymous requests
    When I browse to '/'
    Then I get redirected to '/home/too_many_requests'
    And I see the 'too-many-requests' section
