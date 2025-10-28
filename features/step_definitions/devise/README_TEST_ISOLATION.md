# Test Isolation Pattern for Authentication Tests

## Problem

When running Cucumber tests with different Capybara drivers (especially on CircleCI), session state can leak between test steps, causing authentication tests to fail intermittently.

**Failure symptoms:**

- Test expects anonymous user to be redirected to sign-in page
- But user is already authenticated, so redirect doesn't happen
- Happens specifically with certain drivers: `headless_chrome`, `headless_chrome_galaxys20`, `headless_chrome_ipadair`

## Root Cause

Setting `@current_user` **before** testing anonymous access can trigger subtle session initialization in some Capybara drivers, especially in concurrent test runs.

## Solution: Credentials-Only Pattern

Use a **two-phase approach** that strictly separates user creation from session state:

### Phase 1: Anonymous Access Testing

- Create user in database
- Store **only credentials** (not the user object)
- Test anonymous redirect (no `@current_user` variable exists)

### Phase 2: Authenticated Access Testing

- Fill login form with stored credentials
- Set `@current_user` after successful sign-in
- Continue with authenticated tests

## Step Definitions

### Creating User Without Session

```gherkin
Given there is a confirmed account available
```

This creates a user in the database but stores only `@user_credentials` (email/password), **not** `@current_user`.

### Signing In With Credentials

```gherkin
When I fill the log-in form with the available credentials
```

This uses `@user_credentials` to sign in, then sets `@current_user` after successful authentication.

### Alternative: Retrieve User Later

```gherkin
Given I retrieve the confirmed account
```

If needed, this retrieves the user from `@user_credentials` and sets `@current_user`.

## Example: Correct Pattern

```gherkin
Scenario: feature requires authentication
  # Phase 1: Test anonymous access (no @current_user set)
  Given there is a confirmed account available
  When I browse to '/protected/page'
  Then I get redirected to '/users/sign_in'

  # Phase 2: Sign in and test authenticated access (@current_user set during login)
  When I fill the log-in form with the available credentials
  Then I am at the '/protected/page' page
  And I can use the protected features
```

## Example: Incorrect Pattern (DON'T USE)

```gherkin
Scenario: feature requires authentication
  # WRONG: Setting @current_user before testing anonymous access
  Given I have a confirmed account      # <-- Sets @current_user
  And I am not signed in                # <-- May not fully clear session in all drivers
  When I browse to '/protected/page'
  Then I get redirected to '/users/sign_in'  # <-- FAILS: user already signed in
```

## Implementation Details

**Step: "there is a confirmed account available"**

```ruby
Given('there is a confirmed account available') do
  user = FactoryBot.create(:user, current_sign_in_at: nil)
  # Store only credentials, not the user object
  @user_credentials = { email: user.email, password: user.password }
end
```

**Step: "I fill the log-in form with the available credentials"**

```ruby
When('I fill the log-in form with the available credentials') do
  expect(@user_credentials).to be_present
  # ... fill form with @user_credentials[:email] and [:password] ...
  # After sign-in completes, NOW set @current_user
  @current_user = GogglesDb::User.find_by(email: @user_credentials[:email])
end
```

## Warden Test Mode

The hooks also configure Warden test mode for proper session cleanup:

```ruby
# features/support/hooks.rb
Before do
  Warden.test_mode!
end

After do
  Warden.test_reset!
end
```

This ensures complete session cleanup between scenarios, working together with the credentials-only pattern.

## When to Use Each Pattern

**Use credentials-only pattern when:**

- Testing authentication guards (redirect from anonymous to sign-in)
- Running on multiple Capybara drivers
- Need bulletproof test isolation

**Use traditional pattern when:**

- Already starting signed-in (e.g., "I am already signed-in and at the root page")
- Not testing anonymous access behavior
- Local development only

## Files Modified

- `features/step_definitions/devise/given_any_user_steps.rb` - New credential steps
- `features/step_definitions/devise/signin_signup_steps.rb` - New login step
- `features/support/hooks.rb` - Warden test mode configuration
- `features/issues/type3b_issue.feature` - Updated to use new pattern
- `features/issues/type3c_issue.feature` - Updated to use new pattern

## Related Issues

- CircleCI test failures with specific Capybara drivers
- Session leakage between test scenarios
- Devise authentication not fully reset between tests
