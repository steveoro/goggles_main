# Goggles Main Rails 8.1 Turbo Hard Switch Plan

This plan executes an 8–9 day hard switch to Turbo Frames/Streams + Stimulus across prioritized UX flows (including Tools + Devise in Phase 1), removing legacy Rails UJS `remote: true` and `*.js.erb` interactions without compatibility shims.

## Scope

- In scope:
  - Full replacement of legacy AJAX/UJS patterns in prioritized flows:
    1) Sign-in + landing + search + tools + devise helper
    2) Calendars/dashboard
    3) Swimmers/teams/swimming pools
    4) Meetings/user workshops
    5) Laps management
    6) Relay laps management
    7) Issues + chrono
    8) Final sweep (remaining legacy surfaces)
  - Controller/view/JS updates required for Turbo-native request/response behavior.
  - Removal of Rails UJS startup and legacy `js.erb` endpoints once each flow is migrated.
- Out of scope:
  - Feature redesigns and unrelated business logic refactors.
  - Backward compatibility layer for old UJS requests.

## Hard-Switch Rules

- No dual rendering mode per feature once a phase starts; move directly to Turbo/Stimulus contract.
- Temporary breakage between phases is accepted.
- Keep each phase vertically complete for its target UX (controller + view + front-end behavior + smoke checks).
- After plan approval, keep synchronized copies in:
  - `/home/steve/.windsurf/plans/goggles_main_rails81_turbo_hard_switch_plan-9475f6.md`
  - `/home/steve/Projects/goggles_main/docs/plans/<same-name>.md`

## Current Legacy Surface (migration inventory)

- Legacy UJS boot:
  - `app/javascript/application.js` (`@rails/ujs` + `Rails.start()`).
- `remote: true` view entry points:
  - `app/views/tools/fin_score.html.haml`
  - `app/views/tools/delta_timings.html.haml`
  - `app/views/meetings/show.html.haml`
  - `app/views/swimmers/history_recap.html.haml`
  - `app/views/laps/_edit_table_row.html.haml`
  - `app/views/relay_laps/_edit_relay_swimmer_row.html.haml`
  - `app/views/relay_laps/_edit_relay_lap_row.html.haml`
  - `app/components/laps/edit_modal_component.html.haml`
  - `app/components/relay_laps/edit_button_component.html.haml`
  - `app/components/relay_laps/edit_modal_contents_component.html.haml`
  - `app/components/grid/row_star_button_component.html.haml`
- `js.erb` responders to eliminate:
  - `app/views/laps/edit_modal.js.erb`
  - `app/views/laps/update.js.erb`
  - `app/views/relay_laps/edit_modal.js.erb`
  - `app/views/relay_laps/update.js.erb`
  - `app/views/meetings/show_event_section.js.erb`
  - `app/views/swimmers/event_type_stats.js.erb`
  - `app/views/taggings/by_user.js.erb`
  - `app/views/taggings/by_team.js.erb`
  - `app/views/tools/compute_fin_score.js.erb`
  - `app/views/tools/compute_deltas.js.erb`

## Migration Pattern (applied in every phase)

1. Replace `remote: true` with Turbo-driven `form_with` / `button_to` / `link_to ... data: { turbo_method: ... }`.
2. Replace controller `request.xhr?` gates with Turbo-compatible request acceptance (`turbo_frame_request?`, `format.turbo_stream`, or standard HTML for frame-targeted partials).
3. Replace `js.erb` with one of:
   - `turbo_stream` templates (DOM updates), or
   - frame-contained HTML partial responses.
4. Move UI effects (loading indicators, modal open/close, small animations) to Stimulus controllers.
5. Smoke-test and then remove obsolete `js.erb` file(s) for that flow.

## Phase Plan (8–9 days)

### Phase 1 (Day 1–2): Sign-in + Landing + Search + Tools + Devise helper

- Controllers:
  - `SearchController#smart`
  - `ToolsController#compute_fin_score`, `#compute_deltas`
  - `LookupController#matching_swimmers`
- Views/components/assets:
  - `app/views/home/index.html.haml`
  - `app/views/goggles/_search_box.html.haml`
  - `app/views/search/_refreshed_content.html.haml`
  - `app/views/tools/fin_score.html.haml`
  - `app/views/tools/delta_timings.html.haml`
  - `app/views/devise/registrations/_edit_user_id.html.haml`
  - `app/javascript/controllers/search_controller.js`
  - `app/javascript/controllers/remote_partial_controller.js`
- Work:
  - Finalize Turbo frame contract for search results (`search-results` frame always present in response path).
  - Convert tools calculators from UJS/js.erb to Turbo or Stimulus fetch+HTML/JSON updates.
  - Keep Devise swimmer lookup fully Stimulus-driven (already fetch-based) and ensure endpoint/request format is Turbo-safe.
  - Remove phase-owned `js.erb` tool/search responders if any remain.
- Verification:
  - Sign-in/sign-up edit profile flow with swimmer lookup update.
  - Landing page search submit + pagination/swipe without "Content missing".
  - Tools score/time + delta computations with loading indicators.

### Phase 2 (Day 3): Calendars + dashboard shell + favorites/tagging actions

- Controllers:
  - `CalendarsController` (`current`, `starred`, `starred_map`)
  - `HomeController#dashboard` (interaction points)
  - `TaggingsController#by_user`, `#by_team`
- Views/components:
  - Dashboard and calendar entry views/partials using star toggles.
  - `app/components/grid/row_star_button_component.html.haml` (+ team-star component surfaces)
- Work:
  - Replace tagging UJS links and `taggings/*.js.erb` with Turbo Stream row-target updates.
  - Ensure dashboard interactions do not depend on rails-ujs method spoofing.
- Verification:
  - Toggle star/unstar from dashboard and calendar-related lists.
  - Confirm row-level icon updates and failure messages work with Turbo.

### Phase 3 (Day 4): Swimmers + teams + swimming pools

- Controllers:
  - `SwimmersController` (`show`, `history_recap`, `event_type_stats`, `history`)
  - `TeamsController` (`show`, `current_swimmers`)
  - `SwimmingPoolsController#show`
- Views:
  - `app/views/swimmers/history_recap.html.haml`
  - `app/views/swimmers/event_type_stats.js.erb` (to replace)
- Work:
  - Replace remote stats expansion (`event_type_stats`) with Turbo frame/stream partial updates.
  - Keep team/pool navigation fully Turbo-compatible (no UJS assumptions).
- Verification:
  - Swimmer history recap expansions/collapses render correctly.
  - Team/pool drill-down navigation and back/forward behavior.

### Phase 4 (Day 5): Meetings + user workshops

- Controllers:
  - `MeetingsController#show_event_section` (+ show/team_results/swimmer_results integration)
  - `UserWorkshopsController` key navigation actions
- Views:
  - `app/views/meetings/show.html.haml`
  - `app/views/meetings/show_event_section.js.erb` (to replace)
- Work:
  - Convert meeting event-section lazy loading from UJS/js.erb to Turbo frame sections.
  - Align request guards with Turbo frame requests.
- Verification:
  - Expand multiple meeting sections sequentially.
  - Verify team/swimmer result subpages remain coherent with lap edit entry points.

### Phase 5 (Day 6): Laps management

- Controllers:
  - `LapsController` (`edit_modal`, `create`, `update`, `destroy`)
- Views/components:
  - `app/views/laps/_edit_table_row.html.haml`
  - `app/views/laps/edit_modal.js.erb` (to replace)
  - `app/views/laps/update.js.erb` (to replace)
  - `app/components/laps/edit_modal_component.html.haml`
- Work:
  - Replace modal/table row mutation JS with Turbo Stream updates.
  - Replace remote delete/update links/forms with Turbo-native forms and method handling.
  - Keep delta row and parent MIR row refresh behavior equivalent.
- Verification:
  - Open modal, add lap, edit lap, delete lap, and confirm MIR row sync.

### Phase 6 (Day 7): Relay laps management

- Controllers:
  - `RelayLapsController` (`edit_modal`, `create`, `update`, `destroy`)
- Views/components:
  - `app/views/relay_laps/_edit_relay_swimmer_row.html.haml`
  - `app/views/relay_laps/_edit_relay_lap_row.html.haml`
  - `app/views/relay_laps/edit_modal.js.erb` (to replace)
  - `app/views/relay_laps/update.js.erb` (to replace)
  - `app/components/relay_laps/edit_button_component.html.haml`
  - `app/components/relay_laps/edit_modal_contents_component.html.haml`
- Work:
  - Mirror Phase 5 strategy for relay-specific row hierarchy and modal updates.
  - Preserve alert and row replacement semantics through Turbo Streams.
- Verification:
  - Add/remove swimmer fractions, add/remove sub-laps, update timings, check parent MRR refresh.

### Phase 7 (Day 8): Issues reporting + Chrono queue UX

- Controllers:
  - `IssuesController` (create/destroy/reporting forms)
  - `ChronoController` (`index`, `new`, `rec`, `commit`, `delete`, `download`)
- Views:
  - Issue form/report pages and chrono pages with non-idempotent actions.
- Work:
  - Ensure all mutation actions use Turbo-compatible form submissions and confirmations.
  - Remove any remaining UJS-only method/confirm assumptions.
- Verification:
  - Create issue flows and delete flow.
  - Chrono: rec -> commit -> index queue -> delete/download.

### Phase 8 (Day 9): Final hard cut + cleanup

- Remove rails-ujs boot and legacy dependencies:
  - Update `app/javascript/application.js` to remove `@rails/ujs` import/start.
- Remove remaining `remote: true` occurrences and obsolete `js.erb` files.
- Route/format cleanup:
  - Remove stale `format: :javascript` coupling where replaced by Turbo streams/frames.
- Full regression sweep of prioritized flows.

## Testing Strategy

- Per-phase targeted checks first, then broader smoke checks.
- Minimum per-phase validation:
  - Happy path + one invalid request path.
  - Browser console free of Turbo frame/content errors.
  - No 404s for replaced assets/templates.
- Final Day 9 checks:
  - Full login-to-search journey.
  - Meeting + lap + relay-lap edit loops.
  - Issues and chrono end-to-end actions.

## Risks and Controls

- Risk: Mixed UJS/Turbo behavior causes duplicate submits or DOM race conditions.
  - Control: remove `remote: true` and `js.erb` atomically per flow.
- Risk: Controller rejects Turbo requests due to `request.xhr?` checks.
  - Control: phase-level request guard rewrite before UI switch.
- Risk: Modal-heavy lap flows regress visually.
  - Control: keep dedicated Stimulus modal controller for open/close/loading states while Turbo handles content.

## Done Criteria

- No `remote: true` remains in targeted flows.
- No active `js.erb` responders in migrated flows.
- No Rails UJS startup in `application.js`.
- Prioritized UX chain works end-to-end on Turbo/Stimulus with importmap + propshaft.
