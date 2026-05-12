# Authentication Test Isolation Pattern

Complete guide for preventing session leakage in Cucumber authentication tests, especially on CircleCI with different Capybara drivers.

---

## Table of Contents

1. [The Problem](#the-problem)
2. [Root Cause](#root-cause)
3. [The Solution](#the-solution)
4. [Step Definitions](#step-definitions)
5. [Usage Examples](#usage-examples)
6. [Implementation Details](#implementation-details)
7. [Testing Instructions](#testing-instructions)
8. [Files Modified](#files-modified)
9. [When to Use Each Pattern](#when-to-use-each-pattern)
10. [Fallback Plan](#fallback-plan)

---

## The Problem

When running Cucumber tests with different Capybara drivers (especially on CircleCI), session state can leak between test steps, causing authentication tests to fail intermittently.

### Symptoms

Tests failing on CircleCI with user **already signed in** when they should be anonymous:

- `type3b_issue.feature` - fails with `headless_chrome`
- `type1b1_issue.feature` - fails with `headless_chrome_galaxys20`
- `type3c_issue.feature` - fails with `headless_chrome_ipadair`

**Observable behavior:**

- Test expects anonymous user to be redirected to sign-in page
- But user is already authenticated, so redirect doesn't happen
- HTML artifacts show profile links: "Profilo (username)"
- User is authenticated BEFORE the test even starts browsing
- Works fine on localhost, fails only on CI

---

## Root Cause

There are **TWO** related but distinct problems:

### 1. Early `@current_user` Initialization

Setting `@current_user` **before** testing anonymous access can trigger subtle session initialization in some Capybara drivers, especially in concurrent test runs.

### 2. Session Leakage from Previous Tests

**Session persistence between test scenarios** on CircleCI. Despite having Before/After hooks with `Warden.test_reset!` and `Capybara.reset_session!`, certain Capybara drivers maintain session state from PREVIOUS test files.

This is a test execution **ORDER** issue compounded by driver-specific session handling.

**The second issue is more insidious** because it appears as if the current test is failing, when actually a PREVIOUS test didn't clean up properly.

---

## The Solution

A **three-layered approach** to ensure complete test isolation:

### Layer 1: Nuclear Session Cleanup

Use `Given no user session exists` as the **FIRST step** of scenarios testing anonymous access.

### Layer 2: Credentials-Only Pattern

Store only credentials (`@user_credentials`), NOT the user object (`@current_user`), before testing anonymous access.

### Layer 3: Warden Test Mode

Hooks ensure Warden test mode is active with proper cleanup between scenarios.

---

## Step Definitions

### 1. Nuclear Option: `Given no user session exists`

**Location:** `features/step_definitions/devise/explicit_logout_steps.rb`

This is the **most aggressive** cleanup step that performs:

1. Reset Warden session (`Warden.test_reset!`)
2. Reset Capybara session (`Capybara.reset_session!`)
3. Clear instance variables (`@current_user = nil`, `@user_credentials = nil`)
4. Delete all browser cookies explicitly
5. Visit root page to force clean browser state
6. **Verify** no sign-out link present (fails fast if cleanup didn't work)

```ruby
Given('no user session exists') do
  Warden.test_reset!
  Capybara.reset_session!
  
  @current_user = nil
  @user_credentials = nil
  
  # For Selenium drivers, explicitly delete all browser cookies
  begin
    if page.driver.respond_to?(:browser) && page.driver.browser.respond_to?(:manage)
      page.driver.browser.manage.delete_all_cookies
    end
  rescue StandardError => e
    Rails.logger.debug { "Cookie deletion skipped: #{e.message}" }
  end
  
  visit('/')
  wait_for_ajax && sleep(1)
  
  # VERIFY: no user is signed in
  expect(page).to have_no_css('#link-logout', visible: :all)
end
```

**Use this as the FIRST step** of any scenario testing anonymous access on CI.

### 2. Creating User Without Session: `Given there is a confirmed account available`

**Location:** `features/step_definitions/devise/given_any_user_steps.rb`

Creates a user in the database but stores **only credentials**, not the user object:

```ruby
Given('there is a confirmed account available') do
  user = FactoryBot.create(:user, current_sign_in_at: nil)
  expect(user.confirmed_at).to be_present
  expect(user.current_sign_in_at).to be nil
  # Store only credentials, not the user object itself
  @user_credentials = { email: user.email, password: user.password }
end
```

### 3. Signing In With Credentials: `When I fill the log-in form with the available credentials`

**Location:** `features/step_definitions/devise/signin_signup_steps.rb`

Uses `@user_credentials` to sign in, then sets `@current_user` **after** successful authentication:

```ruby
When('I fill the log-in form with the available credentials') do
  expect(@user_credentials).to be_present
  wait_for_ajax && sleep(2)
  find_by_id('login-box', visible: true)
  fill_in('user_email', with: @user_credentials[:email])
  fill_in('user_password', with: @user_credentials[:password])
  btn = find_by_id('login-btn', visible: true)
  page.scroll_to(btn)
  wait_for_ajax && sleep(0.5)
  btn.click
  # NOW set @current_user after successful sign-in
  @current_user = GogglesDb::User.find_by(email: @user_credentials[:email])
end
```

### 4. Alternative: Retrieve User Later

**Location:** `features/step_definitions/devise/given_any_user_steps.rb`

If needed, retrieves the user from `@user_credentials` and sets `@current_user`:

```ruby
Given('I retrieve the confirmed account') do
  expect(@user_credentials).to be_present
  @current_user = GogglesDb::User.find_by(email: @user_credentials[:email])
  expect(@current_user).to be_a(GogglesDb::User).and be_valid
  expect(@current_user.confirmed_at).to be_present
end
```

---

## Usage Examples

### ✅ Correct Pattern (Bulletproof for CI)

```gherkin
Scenario: feature requires authentication
  # Phase 0: Nuclear cleanup from any previous test (CRITICAL for CI)
  Given no user session exists
  
  # Phase 1: Test anonymous access (no @current_user set)
  And there is a confirmed account available
  When I browse to '/protected/page'
  Then I get redirected to '/users/sign_in'
  
  # Phase 2: Sign in and test authenticated access (@current_user set during login)
  When I fill the log-in form with the available credentials
  Then I am at the '/protected/page' page
  And I can use the protected features
```

### ❌ Incorrect Pattern (DON'T USE)

```gherkin
Scenario: feature requires authentication
  # WRONG: Setting @current_user before testing anonymous access
  Given I have a confirmed account      # <-- Sets @current_user immediately
  And I am not signed in                # <-- May not fully clear session in all drivers
  When I browse to '/protected/page'
  Then I get redirected to '/users/sign_in'  # <-- FAILS: user already signed in
```

---

## Implementation Details

### Warden Test Mode Configuration

**Location:** `features/support/hooks.rb`

```ruby
# Enable Warden test mode at the start of the test suite
BeforeAll do
  Warden.test_mode!
end

# Ensure clean state BEFORE each scenario starts
Before do
  Warden.test_reset!
  Capybara.reset_session!
  
  # For Selenium drivers: explicitly delete all cookies (if browser is active)
  begin
    page.driver.browser.manage.delete_all_cookies if page.driver.respond_to?(:browser)
  rescue StandardError => e
    Rails.logger.debug { "Cookie deletion skipped: #{e.message}" }
  end
end

# Also reset after each scenario
After do
  Warden.test_reset!
  Capybara.reset_session!
end

AfterAll do
  Warden.test_reset!
end
```

This ensures complete session cleanup between scenarios, working together with the credentials-only pattern.

### Why This Works

| Issue | Previous Approach | New Approach |
|-------|------------------|--------------|
| Session from previous test | Hooks run between scenarios | Explicit cleanup IN scenario |
| Browser cookies persist | Implicit cleanup may skip | Explicit cookie deletion |
| Timing/race conditions | Hooks fire asynchronously | Sequential, synchronous cleanup |
| Hard to debug failures | Silent failures | Verification step fails fast |
| Driver-specific behavior | Assumed hooks work everywhere | Tested against specific drivers |
| Early session init | Create user first | Create credentials only |

---

## Testing Instructions

### 1. Verify Locally

Tests should still pass on localhost with the new pattern.

### 2. Push to CircleCI

Watch for these specific test/driver combinations:

- `type3b_issue.feature:8` with `CAPYBARA_DRV=headless_chrome`
- `type1b1_issue.feature:8` with `CAPYBARA_DRV=headless_chrome_galaxys20`
- `type3c_issue.feature:8` with `CAPYBARA_DRV=headless_chrome_ipadair`

### 3. Check Artifacts

If tests still fail, download artifacts and verify:

- Screenshot should show NO user profile link in header
- HTML should not contain `<a ... id="link-account">Profilo (...)</a>`
- Redirect to `/users/sign_in` should succeed

If the verification step fails (`expect(page).to have_no_css('#link-logout')`), you'll immediately know WHERE the cleanup failed.

---

## Files Modified

### New Step Definitions

- `features/step_definitions/devise/explicit_logout_steps.rb` - Nuclear cleanup step

### Updated Step Definitions

- `features/step_definitions/devise/given_any_user_steps.rb` - Credential-only steps
- `features/step_definitions/devise/signin_signup_steps.rb` - Credential-based login

### Updated Configuration

- `features/support/hooks.rb` - Warden test mode configuration

### Updated Feature Files

- `features/issues/type3b_issue.feature` - Uses new pattern
- `features/issues/type3c_issue.feature` - Uses new pattern
- `features/issues/type1b1_issue.feature` - Uses new pattern

---

## When to Use Each Pattern

### Use Nuclear + Credentials-Only Pattern When:

- Testing authentication guards (redirect from anonymous to sign-in)
- Running on multiple Capybara drivers
- Running on CI (CircleCI, GitHub Actions, etc.)
- Need bulletproof test isolation
- Test has failed on CI but works locally

### Use Traditional Pattern When:

- Already starting signed-in (e.g., "I am already signed-in and at the root page")
- Not testing anonymous access behavior
- Local development only
- No session isolation issues observed

---

## Fallback Plan

If tests STILL fail on CircleCI after implementing this pattern:

### 1. Check Test Execution Order

Some test **before** these might need similar cleanup. Consider adding `Given no user session exists` to other scenarios.

### 2. Add to More Scenarios

If failures spread to other feature files, they likely also need the nuclear cleanup step.

### 3. Consider Background Step

If ALL scenarios in a feature file need cleanup, add it to the feature-level Background:

```gherkin
Feature: Issues
  
  Background:
    Given no user session exists
  
  Scenario: ...
```

### 4. Driver-Level Investigation

Might need driver-specific session handling. Check if specific drivers need additional cleanup:

```ruby
# In hooks.rb
After do |scenario|
  if Capybara.current_driver.to_s.include?('galaxys20')
    # Driver-specific cleanup
  end
end
```

### 5. Increase Wait Times

Session cleanup might need more time to propagate:

```ruby
Given('no user session exists') do
  # ... cleanup steps ...
  sleep(2) # Increase from 1 to 2 seconds
end
```

---

## Related Context

This solution evolved through three iterations:

1. **First attempt:** Added `Warden.test_mode!` and `Warden.test_reset!` to hooks
2. **Second attempt:** Credentials-only pattern to prevent `@current_user` initialization
3. **Final solution:** Nuclear cleanup step for CI session leakage

All three layers work together to provide complete test isolation.

---

## Additional Resources

- Devise documentation: https://github.com/heartcombo/devise
- Warden wiki: https://github.com/wardencommunity/warden/wiki
- Capybara session management: https://github.com/teamcapybara/capybara#resetting-sessions
