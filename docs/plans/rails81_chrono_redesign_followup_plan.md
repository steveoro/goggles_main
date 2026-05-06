# Goggles Main Chrono Redesign Follow-Up Plan

## Scope

This plan starts after Rails 8.1 stabilization is green and focuses only on Chrono UX and architecture.
It does not reopen the completed Turbo hard-switch streams outside Chrono.

## Why Redesign

- The current Chrono flow relies on brittle multi-step form scripting and DOM-dependent Cucumber helpers.
- Lap editing and setup interactions are functional but fragile under browser/runtime variability.
- The feature should stay aligned with modern Turbo + Stimulus patterns and minimize test-only hacks.

## Target Outcomes

- Keep current product capability: setup -> record laps -> edit laps -> enqueue import payload.
- Reduce front-end fragility by removing implicit state coupling across wizard steps.
- Make the recording grid deterministic and directly testable without selector fallbacks.
- Improve manager UX for mobile/desktop while preserving existing domain behavior.

## Redesign Architecture

### A) Setup Flow Contract

- Replace step-to-step hidden field coupling with a single canonical setup payload.
- Use explicit Stimulus value/state object serialized into hidden JSON.
- Submit setup with one contract endpoint that validates and returns either:
  - `chrono/rec` with resolved context, or
  - `chrono/new` with structured validation errors.

### B) Recording Grid Contract

- Keep a single Stimulus `chrono` controller as source of truth for lap rows.
- Render rows from structured lap data only (no mixed text/input representations).
- Store lap rows in predictable shape:
  - `order`, `minutes_from_start`, `seconds_from_start`, `hundredths_from_start`, `length_in_meters`, `label`.
- Make edit/delete actions pure state transforms followed by re-render.

### C) Commit Contract

- Keep `chrono_commit` POST payload schema explicit and versioned.
- Validate server-side adapter compatibility before enqueue.
- Return success/error feedback with Turbo-native navigation and flash messaging.

## Delivery Phases

### Phase 1 - Baseline Hardening

- Add request specs for `chrono/new`, `chrono/rec`, and `chrono/commit` contracts.
- Add system/feature smoke for full happy path and one validation-failure path.
- Capture current payload schema in docs and enforce with spec fixtures.

### Phase 2 - Setup Wizard Rewrite

- Replace ad-hoc per-field side effects with explicit setup state object.
- Normalize lookup components to one integration pattern (TomSelect + hidden ID/label fields).
- Remove inline handlers (`onclick` and `onsubmit` overrides) from setup page.

### Phase 3 - Recording Grid Rewrite

- Refactor lap table rendering to stable semantic hooks for tests.
- Ensure edit interactions are keyboard/click safe and accessible.
- Remove fallback-only selector logic from Chrono feature steps.

### Phase 4 - Commit and Queue UX

- Improve commit feedback (success summary, recoverable error states, retry path).
- Confirm enqueue behavior with ActiveJob/Solid Queue test coverage.
- Validate admin visibility expectations for resulting queued work.

### Phase 5 - Cleanup and Removal

- Remove obsolete compatibility code in Chrono step definitions.
- Remove stale comments and dead code paths in controller/views/JS.
- Final rubocop + focused suite + full suite checkpoint.

## Test Gates

Run in order for each phase:

1. `bundle exec rspec spec/requests/chrono_controller_spec.rb` (and related chrono request specs)
2. `bundle exec cucumber features/chrono/time_recording.feature`
3. Impacted focused packs (`features/home/admin_jobs.feature` if queue UX touched)
4. Full checkpoints:
   - `bundle exec rspec spec/requests`
   - `bundle exec rspec spec/views`
   - `bundle exec cucumber`

## Risks and Mitigations

- Risk: setup regressions from lookup component behavior changes.
  - Mitigation: contract tests around submitted setup payload + explicit fixture coverage.
- Risk: timing flakiness in feature tests.
  - Mitigation: assert on stable lap state, not transient render timing.
- Risk: queue integration drift.
  - Mitigation: keep commit payload versioned and validated in request/job specs.

## Done Criteria

- Chrono setup/record/edit/commit flows pass on full Cucumber run without Chrono-specific selector hacks.
- Chrono request contracts are covered and green in request specs.
- No inline JS submit/legacy coupling remains in Chrono setup flow.
- Full migration checkpoints remain green after Chrono redesign merge.
