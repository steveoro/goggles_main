# Goggles Main Db ComboBox -> Autocomplete Migration Plan

## Scope

This plan defines the full replacement of all `ComboBox::Db*` lookup components with new components based on:

- `app/components/combo_box/autocomplete_component.rb`
- `app/components/combo_box/autocomplete_component.html.haml`

The migration includes component classes/templates, view call sites, Stimulus wiring, specs, and Cucumber steps.

## Goals

- Remove every `ComboBox::Db*Component` usage from `goggles_main`.
- Keep current form contracts stable (`*_id`, `*_label`, and related hidden fields).
- Keep current user behavior unchanged in Chrono and Issues forms.
- Standardize on `autocomplete-lookup` controller and TomSelect-only markup.
- Complete cleanup in the same pass (no long-lived compatibility layer).

## Out of Scope

- API endpoint redesign (`/api/v3/...`) or payload shape changes.
- Chrono flow redesign beyond lookup-component migration.
- Non-ComboBox lookup pages/controllers not using `ComboBox::Db*` components.

## Current Baseline Inventory

### Legacy Db Component Definitions

- `app/components/combo_box/db_lookup_component.rb`
- `app/components/combo_box/db_lookup_component.html.haml`
- `app/components/combo_box/db_city_component.rb`
- `app/components/combo_box/db_city_component.html.haml`
- `app/components/combo_box/db_swimmer_component.rb`
- `app/components/combo_box/db_swimmer_component.html.haml`
- `app/components/combo_box/db_swimming_pool_component.rb`
- `app/components/combo_box/db_swimming_pool_component.html.haml`

### Legacy Render Call Sites to Replace

- `app/views/chrono/new.html.haml`
  - `DbLookupComponent`: season, meeting, user_workshop, pool_type, event_type, team, category_type
  - `DbSwimmingPoolComponent`: swimming_pool
  - `DbCityComponent`: city
  - `DbSwimmerComponent`: swimmer
- `app/views/issues/_form_type0.html.haml`
  - `DbLookupComponent`: team
- `app/views/issues/_form_type1a.html.haml`
  - `DbLookupComponent`: meeting
  - `DbCityComponent`: city
- `app/views/issues/_form_type1b.html.haml`
  - `DbLookupComponent`: event_type, team
  - `DbSwimmerComponent`: swimmer
- `app/views/issues/_form_type3b.html.haml`
  - `DbSwimmerComponent`: swimmer
- `app/components/combo_box/db_city_component.html.haml`
  - nested `DbLookupComponent` render for city selector

### Existing New-Stack Artifacts Already Available

- `app/components/combo_box/autocomplete_component.rb`
- `app/components/combo_box/autocomplete_component.html.haml`
- `app/javascript/controllers/autocomplete_lookup_controller.js`
- `app/assets/stylesheets/lookup.scss` (`.autocomplete-lookup` block)
- `spec/components/combo_box/autocomplete_component_spec.rb`
- partial adoption in `app/views/tools/fin_score.html.haml`

## Target Architecture

### Component Family (Post-Migration)

1. Keep `ComboBox::AutocompleteComponent` as generic base selector.
2. Add Autocomplete-based specializations replacing each legacy sibling:
   - `ComboBox::AutocompleteCityComponent`
   - `ComboBox::AutocompleteSwimmerComponent`
   - `ComboBox::AutocompleteSwimmingPoolComponent`
3. Specializations must delegate base select rendering to `AutocompleteComponent` and keep existing side fields.

### Contract Compatibility Rules

- Preserve the existing IDs/names used by forms and controllers:
  - `<base_name>_select`
  - `<base_name>_id`
  - `<base_name>_label`
  - additional hidden fields used today (`swimmer_complete_name`, `swimming_pool_pool_type_id`, etc.)
- Preserve `bound_query_param` behavior for city lookup (`country_code`).
- Preserve free-text semantics (`id = 0`, new-item LED behavior).
- Preserve default-row preselection behavior for all specialized widgets.

## Detailed Delivery Plan

### Phase 0 - Freeze Baseline and Prepare

- Capture and lock current call-site inventory listed above.
- Confirm no additional `ComboBox::Db*Component` usage outside current list.
- Run baseline focused checks before edits:
  - `bundle exec rspec spec/components/combo_box`
  - `bundle exec rspec spec/views/issues/new.html.haml_spec.rb spec/views/tools/fin_score.html.haml_spec.rb`
  - `bundle exec cucumber features/chrono/new_rec_setup.feature features/chrono/time_recording.feature`

### Phase 1 - Build Autocomplete Replacements

- Create new component classes/templates for city/swimmer/swimming_pool based on the generic `AutocompleteComponent`.
- For each specialization, port legacy behavior 1:1:
  - hidden fields population
  - default row mapping/decorator usage
  - extra companion fields (city area/country, swimmer year/gender)
  - static options fallback when values are supplied
- Add or extend shared spec examples for `autocomplete-lookup` data contract so all replacements are verified consistently.

### Phase 2 - Replace All View Call Sites

- Replace all `ComboBox::DbLookupComponent.new(...)` calls with `ComboBox::AutocompleteComponent.new(...)` keyword form.
- Replace all sibling calls:
  - `DbCityComponent` -> `AutocompleteCityComponent`
  - `DbSwimmerComponent` -> `AutocompleteSwimmerComponent`
  - `DbSwimmingPoolComponent` -> `AutocompleteSwimmingPoolComponent`
- Keep layout wrappers and Bootstrap grid classes unchanged.
- Keep all base names unchanged to avoid downstream breakage.

### Phase 3 - Stimulus Controller Consolidation

- Treat `autocomplete_lookup_controller.js` as canonical.
- Ensure all critical fixes remain present while migrating all views:
  - preselected option synchronization on connect
  - `$`-prefixed internal key filtering when copying option/detail objects
  - nested field propagation for city/pool/swimmer bindings
- Remove any residual template dependency on `data-controller="lookup"`.
- Decide end-state of `lookup_controller.js`:
  - delete if truly unused after replacement, or
  - keep temporarily only if non-ComboBox templates still require it (must be documented with follow-up removal task).

### Phase 4 - Specs and Cucumber Migration

- Component specs:
  - migrate coverage from `spec/components/combo_box/db_*_component_spec.rb` to new `autocomplete_*` specs
  - keep semantic parity with previous expectations
- Shared examples:
  - replace/rename old `DbLookupComponent` shared examples in `spec/support/shared_component_examples.rb`
  - assert new data attributes (`data-autocomplete-lookup-*`) and select class (`.autocomplete-lookup__select`)
- View specs:
  - update selectors in `spec/views/issues/new.html.haml_spec.rb` and related files for new wrapper/controller attributes
- Cucumber:
  - update wording and step definitions still referring to "Select2 field"
  - keep same user-level behavior in Chrono setup features
  - validate JS helper scripts against TomSelect API (`select.tomselect`) only

### Phase 5 - Legacy Removal and Cleanup

- Remove legacy files:
  - `app/components/combo_box/db_*_component.rb`
  - `app/components/combo_box/db_*_component.html.haml`
  - legacy db component specs once replacement coverage is green
- Remove stale comments/docstrings mentioning Select2 where no longer true.
- Run formatting/linting only for touched files.

## Validation Gates

Run in this order during migration:

1. `bundle exec rspec spec/components/combo_box/autocomplete_component_spec.rb`
2. `bundle exec rspec spec/components/combo_box`
3. `bundle exec rspec spec/views/issues/new.html.haml_spec.rb spec/views/tools/fin_score.html.haml_spec.rb`
4. `bundle exec cucumber features/chrono/new_rec_setup.feature`
5. `bundle exec cucumber features/chrono/time_recording.feature`
6. `bundle exec cucumber features/tools/fin_score.feature`
7. Final checkpoint:
   - `bundle exec rspec`
   - `bundle exec cucumber`

## Risk Register and Mitigations

- Risk: hidden field regressions break form POST payloads.
  - Mitigation: explicit assertions for every hidden field in component specs + Chrono Cucumber coverage.
- Risk: default-row preselection lost on initial render.
  - Mitigation: dedicated spec contexts for API + preset values and controller `syncInitialSelection` assertions.
- Risk: city/swimming_pool chained updates fail due to nested map handling.
  - Mitigation: focused JS-enabled feature checks on Chrono step 2 and issue forms.
- Risk: stale Select2-specific Cucumber wording and helpers mislead maintenance.
  - Mitigation: rename steps to Autocomplete/TomSelect terminology in same migration.

## Done Criteria

- No render call uses `ComboBox::DbLookupComponent`, `DbCityComponent`, `DbSwimmerComponent`, or `DbSwimmingPoolComponent`.
- No `db_*_component` files remain under `app/components/combo_box/`.
- No ComboBox template uses `data-controller="lookup"`.
- All migrated specs/features listed in Validation Gates are green.
- Chrono setup and Issues forms retain current functional behavior and submitted params.

## Post-Migration Follow-Up (Optional)

- If `lookup_controller.js` remains for unrelated consumers, create a short follow-up plan to remove it once those consumers migrate.
- Extend Autocomplete shared examples to enforce behavior for future ComboBox additions.
