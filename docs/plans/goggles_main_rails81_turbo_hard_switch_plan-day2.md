# Goggles Main Rails 8.1 Turbo baseline Plan

This plan restarts the Rails 8.1 hard-switch from a verified baseline and advances phase-by-phase only when focused request/view RSpec + Cucumber + RuboCop acceptance gates are green.

## Goals

- Replace the previous hard-switch plan with an up-to-date, test-gated execution plan.
- Recover baseline stability before any further migration work.
- Keep Turbo/Stimulus migration and Solid Queue migration aligned with no regressions.

## Current Baseline (Observed)

- Turbo migration is partially implemented across search, tools, taggings, swimmers, meetings, laps, and relay laps.
- Legacy cleanup is incomplete (`@rails/ujs` boot still present; legacy `*.js.erb` files still present).
- `spec/requests/tools_controller_spec.rb` currently fails against new JSON/Turbo behavior.
- `spec/views/home/index.html.haml_spec.rb` currently fails (`#loading-indicator` expectation mismatch with current Turbo/Stimulus rendering).
- `db/queue_schema.rb` is malformed/truncated and must be regenerated/fixed before relying on queue DB setup.
- Solid Queue is configured in app/runtime/deploy files, but migration verification is not yet tracked as an explicit phase stream.

## Global Execution Rules

- Stop-the-line policy: do not start next phase until current phase acceptance gates are green.
- Focused phase suite first, then rolling regression checks.
- Keep changes scoped to the active phase and immediate regressions only.
- Update this plan status after each phase completion with evidence (commands + outcomes).

## Test Gate Model (Used in Every Phase)

Each phase is complete only when all are green:

1. Focused RSpec request/logic pack (request/spec files mapped to phase scope).
2. Focused RSpec view pack (`spec/views` files mapped to phase scope).
3. Focused Cucumber pack (feature files mapped to phase scope).
4. `rubocop` on changed files (or equivalent targeted lint run).
5. Rolling regression smoke pack (high-risk cross-phase flows).

Checkpoint cadence for broader confidence:

- Full `spec/requests` pack after Phases 0, 2, 4, 6, 8.
- Full `spec/views` pack after Phases 0, 2, 4, 6, 8.
- Full Cucumber pack at least after Phases 4 and 8 (or earlier if regression signals appear).

## Phase 0 — Stabilization Baseline (Mandatory) - COMPLETED

### Scope

- Reconcile controller/spec contract drift introduced by early Turbo conversions.
- Fix queue infrastructure baseline before feature migration continues.
- Establish focused test packs and command aliases used by all next phases.

### Work Items

- Tools request contract alignment:
  - Reconcile `ToolsController` responses (HTML vs JSON/Turbo expectations).
  - Update `spec/requests/tools_controller_spec.rb` (and shared examples if needed) to reflect intentional behavior.
- Queue baseline repair:
  - Regenerate/restore `db/queue_schema.rb` from `db/queue_migrate` and ensure it is structurally valid.
  - Verify `config/database.yml` queue DB mapping for all envs.
- Solid Queue operational baseline:
  - Validate `bin/jobs`, `Procfile.dev`, and Mission Control `/jobs` access expectations.
  - Ensure deploy templates under `config/goggles_deploy.public/*` remain consistent with Rails 8.1 queue/cache choices.
- Define rolling regression smoke pack and phase-focused command matrix.

### Acceptance Criteria

- RSpec focused: (currently green)
  - `spec/requests/tools_controller_spec.rb`
  - `spec/requests/home_controller_spec.rb`
  - `spec/requests/search_controller_spec.rb`
- View specs focused: (currently green)
  - `spec/views/home/index.html.haml_spec.rb`
  - `spec/views/tools/fin_score.html.haml_spec.rb`
  - `spec/views/tools/delta_timings.html.haml_spec.rb`
  - `spec/views/search/search_result.html.haml_spec.rb`
  - `spec/views/home/dashboard.html.haml_spec.rb`
- Cucumber focused: (currently green)
  - `features/tools/fin_score.feature`
  - `features/tools/delta_timings.feature`
  - `features/home/landing_page.feature`
  - `features/home/admin_jobs.feature`
  - `features/search/search_smart.feature`
- RuboCop:
  - Targeted run on changed files.
- Queue/Solid Queue checks:
  - Queue schema loads cleanly.
  - Jobs worker boots and `/jobs` authorization behavior matches feature expectations.

## Phase 1 — Sign-in, Landing, Search, Tools, Devise Helper - COMPLETED

### Scope

- Finalize Phase-1 migration from baseline, including any pending Turbo/Stimulus contract cleanup.

### Work Items

- Complete search frame contract verification and fallback behavior.
- Finish tools JSON/Turbo contract and remove legacy responder assumptions.
- Verify Devise swimmer lookup flow remains Turbo-safe.
- Remove obsolete Phase-1 legacy responders if still active.

### Acceptance Criteria

- RSpec focused:
  - `spec/requests/search_controller_spec.rb`
  - `spec/requests/tools_controller_spec.rb`
  - `spec/requests/lookup_controller_spec.rb`
  - Relevant Devise request specs under `spec/requests/users/*`
- View specs focused:
  - `spec/views/home/index.html.haml_spec.rb`
  - `spec/views/tools/fin_score.html.haml_spec.rb`
  - `spec/views/tools/delta_timings.html.haml_spec.rb`
  - `spec/views/lookup/matching_swimmers.html.haml_spec.rb`
  - `spec/views/search/search_result.html.haml_spec.rb`
- Cucumber focused:
  - `features/devise/devise_sign_in.feature`
  - `features/devise/devise_sign_up.feature`
  - `features/devise/devise_account_edit.feature`
  - `features/home/landing_page.feature`
  - `features/search/search_smart.feature`
  - `features/tools/fin_score.feature`
  - `features/tools/delta_timings.feature`
- RuboCop targeted green.
- Rolling regression smoke pack green.

### Current ISSUES:

- Modal controller needs to be updated to work with Bootstrap 5.3+ (aria-hidden attribute);
  - although out of scope, app/components/laps/edit_modal_component.html.haml seems to have a working dismiss cross button (but still relies on app/views/laps/edit_modal.js.erb), whereas delta timings output modal (app/views/tools/delta_timings.html.haml) doesn't have a working dismiss button (but ESC or clicking outside of it does dismiss the modal)

## Phase 2 — Calendars, Dashboard, Taggings - COMPLETED

### Scope

- Complete and harden calendar/dashboard favorites + tagging Turbo flows.

### Acceptance Criteria

- RSpec focused:
  - `spec/requests/calendars_controller_spec.rb`
  - `spec/requests/taggings_controller_spec.rb`
  - `spec/requests/home_controller_spec.rb`
- View specs focused:
  - `spec/views/calendars/current.html.haml_spec.rb`
  - `spec/views/calendars/starred.html.haml_spec.rb`
  - `spec/views/calendars/starred_map.html.haml_spec.rb`
  - `spec/views/home/dashboard.html.haml_spec.rb`
- Cucumber focused:
  - `features/calendar/current.feature`
  - `features/calendar/starred.feature`
  - `features/calendar/starred_map.feature`
  - `features/home/dashboard.feature`
- RuboCop targeted green.
- Rolling regression smoke pack green.

### Phase 2 Closure Report (2026-04-28)

- Changed files:
  - `spec/requests/taggings_controller_spec.rb`
  - `features/step_definitions/calendars/given_any_calendars_steps.rb`
  - `features/step_definitions/calendars/calendars_steps.rb`
- Focused RSpec request command + result:
  - `bin/rspec spec/requests/calendars_controller_spec.rb spec/requests/taggings_controller_spec.rb spec/requests/home_controller_spec.rb` -> green (`46 examples, 0 failures`)
- Focused RSpec view command + result:
  - `bin/rspec spec/views/calendars/current.html.haml_spec.rb spec/views/calendars/starred.html.haml_spec.rb spec/views/calendars/starred_map.html.haml_spec.rb spec/views/home/dashboard.html.haml_spec.rb` -> green (`88 examples, 0 failures`)
- Focused Cucumber command + result:
  - `bundle exec cucumber features/calendar/current.feature features/calendar/starred.feature features/calendar/starred_map.feature features/home/dashboard.feature` -> green (`30 scenarios, 203 steps passed`)
- RuboCop command + result:
  - `bin/rubocop spec/requests/taggings_controller_spec.rb features/step_definitions/calendars/given_any_calendars_steps.rb features/step_definitions/calendars/calendars_steps.rb` -> green (`3 files inspected, no offenses`)
- Rolling regression smoke pack + result:
  - `bin/rspec spec/requests/home_controller_spec.rb spec/requests/search_controller_spec.rb spec/requests/tools_controller_spec.rb spec/views/home/index.html.haml_spec.rb spec/views/search/search_result.html.haml_spec.rb spec/views/tools/fin_score.html.haml_spec.rb spec/views/tools/delta_timings.html.haml_spec.rb` -> green (`92 examples, 0 failures`)
  - `bundle exec cucumber features/home/landing_page.feature features/search/search_smart.feature features/tools/fin_score.feature features/tools/delta_timings.feature` -> green (`18 scenarios, 122 steps passed`)

## Phase 3 — Swimmers, Teams, Swimming Pools - COMPLETED

### Scope

- Finalize Turbo behavior for swimmer stats expansion and related navigation.

### Acceptance Criteria

- RSpec focused:
  - `spec/requests/swimmers_controller_spec.rb`
  - `spec/requests/teams_controller_spec.rb`
  - `spec/requests/swimming_pools_controller_spec.rb`
- View specs focused:
  - `spec/views/swimmers/show.html.haml_spec.rb`
  - `spec/views/swimmers/history.html.haml_spec.rb`
  - `spec/views/swimmers/history_recap.html.haml_spec.rb`
  - `spec/views/teams/show.html.haml_spec.rb`
  - `spec/views/teams/current_swimmers.html.haml_spec.rb`
  - `spec/views/swimming_pools/show.html.haml_spec.rb`
- Cucumber focused:
  - `features/swimmers/show.feature`
  - `features/swimmers/history.feature`
  - `features/swimmers/history_recap.feature`
  - `features/teams/show.feature`
  - `features/teams/current_swimmers.feature`
  - `features/swimming_pools/show.feature`
- RuboCop targeted green.
- Rolling regression smoke pack green.

### Phase 3 Closure Report (2026-04-28)

- Changed files:
  - `spec/requests/swimmers_controller_spec.rb`
  - `features/step_definitions/search/search_steps.rb`
  - `features/step_definitions/swimmers/swimmers_steps.rb`
  - `features/step_definitions/meetings/meetings_steps.rb`
  - `app/decorators/swimmer_decorator.rb`
  - `app/decorators/team_decorator.rb`
  - `app/decorators/swimming_pool_decorator.rb`
- Focused RSpec request command + result:
  - `bin/rspec spec/requests/swimmers_controller_spec.rb spec/requests/teams_controller_spec.rb spec/requests/swimming_pools_controller_spec.rb` -> green (`27 examples, 0 failures`)
- Focused RSpec view command + result:
  - `bin/rspec spec/views/swimmers/show.html.haml_spec.rb spec/views/swimmers/history.html.haml_spec.rb spec/views/swimmers/history_recap.html.haml_spec.rb spec/views/teams/show.html.haml_spec.rb spec/views/teams/current_swimmers.html.haml_spec.rb spec/views/swimming_pools/show.html.haml_spec.rb` -> green (`89 examples, 0 failures`)
- Focused Cucumber command + result:
  - `bundle exec cucumber features/swimmers/show.feature features/swimmers/history.feature features/swimmers/history_recap.feature features/teams/show.feature features/teams/current_swimmers.feature features/swimming_pools/show.feature` -> green (`9 scenarios, 86 steps passed`)
- RuboCop command + result:
  - `bin/rubocop spec/requests/swimmers_controller_spec.rb features/step_definitions/search/search_steps.rb features/step_definitions/swimmers/swimmers_steps.rb features/step_definitions/meetings/meetings_steps.rb app/decorators/swimmer_decorator.rb app/decorators/team_decorator.rb app/decorators/swimming_pool_decorator.rb` -> green (`7 files inspected, no offenses`)
- Rolling regression smoke pack + result:
  - `bin/rspec spec/requests/home_controller_spec.rb spec/requests/search_controller_spec.rb spec/requests/tools_controller_spec.rb spec/views/home/index.html.haml_spec.rb spec/views/search/search_result.html.haml_spec.rb` -> green (`76 examples, 0 failures`)
  - `bundle exec cucumber features/home/landing_page.feature features/search/search_smart.feature` -> green (`12 scenarios, 77 steps passed`)

## Phase 4 — Meetings and User Workshops

### Scope

- Complete meeting section expansion contract and workshop navigation parity.

### Acceptance Criteria

- RSpec focused:
  - `spec/requests/meetings_controller_spec.rb`
  - `spec/requests/user_workshops_controller_spec.rb`
- View specs focused:
  - `spec/views/meetings/index.html.haml_spec.rb`
  - `spec/views/meetings/show.html.haml_spec.rb`
  - `spec/views/meetings/team_results.html.haml_spec.rb`
  - `spec/views/meetings/swimmer_results.html.haml_spec.rb`
  - `spec/views/meetings/for_team.html.haml_spec.rb`
  - `spec/views/meetings/for_swimmer.html.haml_spec.rb`
  - `spec/views/user_workshops/index.html.haml_spec.rb`
  - `spec/views/user_workshops/show.html.haml_spec.rb`
  - `spec/views/user_workshops/for_team.html.haml_spec.rb`
  - `spec/views/user_workshops/for_swimmer.html.haml_spec.rb`
- Cucumber focused:
  - `features/meetings/index.feature`
  - `features/meetings/show.feature`
  - `features/meetings/team_results.feature`
  - `features/meetings/swimmer_results.feature`
  - `features/meetings/for_team.feature`
  - `features/meetings/for_swimmer.feature`
  - `features/user_workshops/index.feature`
  - `features/user_workshops/show.feature`
  - `features/user_workshops/for_team.feature`
  - `features/user_workshops/for_swimmer.feature`
- RuboCop targeted green.
- Rolling regression smoke pack green.
- Checkpoint: full `spec/requests` pass.

### Phase 4 Closure Report (2026-04-28)

- Changed files:
  - `app/controllers/meetings_controller.rb`
  - `app/controllers/user_workshops_controller.rb`
  - `app/decorators/meeting_decorator.rb`
  - `app/decorators/user_workshop_decorator.rb`
  - `app/views/meetings/_show_event_section.html.haml`
  - `spec/requests/meetings_controller_spec.rb`
  - `spec/views/user_workshops/for_swimmer.html.haml_spec.rb`
  - `features/step_definitions/general_steps.rb`
  - `features/step_definitions/meetings/meetings_steps.rb`
  - `features/step_definitions/user_workshops/user_workshops_steps.rb`
- Focused RSpec request command + result:
  - `bin/rspec spec/requests/meetings_controller_spec.rb spec/requests/user_workshops_controller_spec.rb` -> green (`53 examples, 0 failures`)
- Focused RSpec view command + result:
  - `bin/rspec spec/views/meetings/index.html.haml_spec.rb spec/views/meetings/show.html.haml_spec.rb spec/views/meetings/team_results.html.haml_spec.rb spec/views/meetings/swimmer_results.html.haml_spec.rb spec/views/meetings/for_team.html.haml_spec.rb spec/views/meetings/for_swimmer.html.haml_spec.rb spec/views/user_workshops/index.html.haml_spec.rb spec/views/user_workshops/show.html.haml_spec.rb spec/views/user_workshops/for_team.html.haml_spec.rb spec/views/user_workshops/for_swimmer.html.haml_spec.rb` -> green (`94 examples, 0 failures`)
- Focused Cucumber command + result:
  - `bundle exec cucumber features/meetings/index.feature features/meetings/show.feature features/meetings/team_results.feature features/meetings/swimmer_results.feature features/meetings/for_team.feature features/meetings/for_swimmer.feature features/user_workshops/index.feature features/user_workshops/show.feature features/user_workshops/for_team.feature features/user_workshops/for_swimmer.feature` -> green (`36 scenarios, 361 steps passed`)
- RuboCop command + result:
  - `bin/rubocop app/controllers/meetings_controller.rb app/controllers/user_workshops_controller.rb app/decorators/meeting_decorator.rb app/decorators/user_workshop_decorator.rb spec/requests/meetings_controller_spec.rb spec/views/user_workshops/for_swimmer.html.haml_spec.rb features/step_definitions/general_steps.rb features/step_definitions/meetings/meetings_steps.rb features/step_definitions/user_workshops/user_workshops_steps.rb` -> green (`9 files inspected, no offenses`)
- Rolling regression smoke pack + result:
  - `bin/rspec spec/requests/home_controller_spec.rb spec/requests/search_controller_spec.rb spec/requests/tools_controller_spec.rb spec/views/home/index.html.haml_spec.rb spec/views/search/search_result.html.haml_spec.rb spec/views/tools/fin_score.html.haml_spec.rb spec/views/tools/delta_timings.html.haml_spec.rb` -> green (`92 examples, 0 failures`)
  - `bundle exec cucumber features/home/landing_page.feature features/search/search_smart.feature features/tools/fin_score.feature features/tools/delta_timings.feature` -> green (`18 scenarios, 122 steps passed`)
- Checkpoint packs:
  - `bin/rspec spec/views` -> green (`476 examples, 0 failures`)
  - `bin/rspec spec/requests` -> **not green** (`385 examples, 24 failures, 1 pending`), with failures scoped to `spec/requests/laps_controller_spec.rb` and `spec/requests/relay_laps_controller_spec.rb` (Phase 5/6 scope, not introduced by Phase 4 meetings/user workshops changes).

## Phase 5 — Laps Management

### Scope

- Complete MIR/UR lap CRUD Turbo flow and remove obsolete `laps/*.js.erb` responders.

### Acceptance Criteria

- RSpec focused:
  - `spec/requests/laps_controller_spec.rb`
- View specs focused:
  - Add/maintain Turbo template view specs for laps updates, then run:
    - `spec/views/laps/edit_modal.turbo_stream.erb_spec.rb`
    - `spec/views/laps/update.turbo_stream.erb_spec.rb`
- Cucumber focused:
  - `features/laps/mir_laps_crud.feature`
  - `features/laps/ur_laps_crud.feature`
- RuboCop targeted green.
- Rolling regression smoke pack green.

## Phase 6 — Relay Laps Management

### Scope

- Complete relay lap CRUD Turbo flow and remove obsolete `relay_laps/*.js.erb` responders.

### Acceptance Criteria

- RSpec focused:
  - `spec/requests/relay_laps_controller_spec.rb`
- View specs focused:
  - Add/maintain Turbo template view specs for relay laps updates, then run:
    - `spec/views/relay_laps/edit_modal.turbo_stream.erb_spec.rb`
    - `spec/views/relay_laps/update.turbo_stream.erb_spec.rb`
- Cucumber focused:
  - `features/relay_laps/mrr_laps_crud.feature`
- RuboCop targeted green.
- Rolling regression smoke pack green.
- Checkpoint: full `spec/requests` pass.

## Phase 7 — Issues and Chrono

### Scope

- Finalize all mutation actions and interaction flows for issues + chrono.

### Acceptance Criteria

- RSpec focused:
  - `spec/requests/issues_controller_spec.rb`
  - `spec/requests/chrono_controller_spec.rb`
- View specs focused:
  - `spec/views/issues/faq_index.html.haml_spec.rb`
  - `spec/views/issues/my_reports.html.haml_spec.rb`
  - `spec/views/issues/new.html.haml_spec.rb`
  - `spec/views/chrono/index.html.haml_spec.rb`
  - `spec/views/chrono/new.html.haml_spec.rb`
  - `spec/views/chrono/rec.html.haml_spec.rb`
- Cucumber focused:
  - `features/issues/*.feature`
  - `features/chrono/index.feature`
  - `features/chrono/new_rec_setup.feature`
  - `features/chrono/time_recording.feature`
- RuboCop targeted green.
- Rolling regression smoke pack green.

## Phase 8 — Final Hard Cut and Suite Closure

### Scope

- Remove all remaining legacy UJS surfaces and close migration with full-suite confidence.

### Work Items

- Remove `@rails/ujs` startup from `app/javascript/application.js`.
- Remove obsolete `*.js.erb` files no longer used by migrated flows.
- Remove stale route/controller format coupling and dead compatibility branches.
- Confirm Solid Queue + Mission Control behavior in dev/test/staging/prod configs after final cleanup.

### Acceptance Criteria

- Focused RSpec for files touched in this phase + full `spec/requests` + full `spec/views` pass.
- Full Cucumber suite pass.
- RuboCop (targeted + project standard pass used in CI).
- No unresolved regression in rolling smoke pack.

## Reporting Template (Per Phase)

For each phase closure, record:

- Changed files
- Focused RSpec command(s) + result
- Focused view-spec command(s) + result
- Focused Cucumber command(s) + result
- RuboCop command(s) + result
- Regression notes (if any) and whether phase is blocked/open
