# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Goggles Main is the Rails 8.1 / Ruby 3.4 client UI app (v7+) of the Goggles framework (swimming meeting results). It is a thin UI layer: **all models, DB structure, migrations and most domain logic live in the `goggles_db` engine gem** (git source), mounted at `/` in `config/routes.rb`. Models are therefore namespaced `GogglesDb::*` (e.g. `GogglesDb::User`, `GogglesDb::GrantChecker`) and aren't defined under `app/models` here. Data writes for most entities go through the separate `goggles_api` service (see `api_sessions_controller.rb`, JWT sessions).

Stack: MariaDB (primary DB), SQLite for SolidQueue/SolidCache/SolidCable (`storage/*.sqlite3`), Haml views, ViewComponent, Datagrid, Devise (+ omniauth/Google sign-in), Turbo/Stimulus via importmap, Propshaft + dartsass-rails, Mission Control Jobs at `/jobs` (admins only).

## Commands

```bash
bin/dev                                   # Procfile.dev: server + dartsass:watch (plain `rails s` does NOT rebuild SCSS)
bin/rails dartsass:build                  # rebuild app/assets/builds/application.css after .scss changes
bin/rails db:rebuild from=test to=development   # custom task: restore DB from db/dump/<from>.sql.bz2
./update_engine.sh                        # bundle update goggles_db (skips the LFS test dump)

bundle exec rspec                         # unit/component/request/view specs
bundle exec rspec spec/path/file_spec.rb:LINE   # single example
bundle exec cucumber features/<area>/x.feature  # browser (Capybara) E2E features
bundle exec rubocop                       # Ruby lint (config: .rubocop.yml + .rubocop_todo.yml)
bundle exec haml-lint app/views app/components  # Haml lint
bundle exec brakeman                      # security scan
```

`Guardfile` wires guard-rspec/rubocop/haml_lint/brakeman/cucumber for watch mode. CI is CircleCI (`.circleci/config.yml`), which splits rspec and cucumber (several Capybara drivers: headless_chrome and mobile/tablet emulations) across containers.

## Architecture

- **Controllers** (`app/controllers`): one per area (meetings, swimmers, teams, laps, issues, goggle_cups, chrono, …), plus `users/` (Devise/omniauth overrides) and `goggles_db/` (overrides for engine controllers).
- **Components** (`app/components`): ViewComponents grouped by domain (`mir`, `mrr`, `mprg`, `meeting`, `laps`, …), each a `.rb` + `.html.haml` pair. Specs in `spec/components` use `spec/support/shared_component_examples.rb`.
- **Decorators** (`app/decorators`): wrap engine models for display; see `shared_decorator_examples.rb`.
- **Grids** (`app/grids`): Datagrid tables inheriting `BaseGrid`.
- **Strategies** (`app/strategies`):
  - `solver/` — `Solver::Factory` + per-entity strategies (subclasses of `BaseStrategy`) that resolve/lookup entities from issue-report ("IQ") request data; `iq_solver_service.rb` drives them.
  - `meeting_stats/` — event/category/team stats; `team_records_pdf.rb` — PDF export.
- **Jobs** (`app/jobs`): SolidQueue jobs (import processor, issue/stats cleaners); config in `config/initializers/solid_queue.rb`.
- **Auth**: Devise on `GogglesDb::User`; roles/permissions come from `GogglesDb::GrantChecker` (admin / team manager flags set on the controller as `@current_user_is_admin` / `@current_user_is_manager`). Rate limiting via `rack-attack`.
- Default locale is `:it` (`config/locale.rb`, i18n files under `config/locales`); cucumber features and E2E steps rely on Italian UI strings.

## Testing notes

- Tests need a populated MariaDB `goggles_test` (restore from the engine's `test.sql.bz2` dump into `db/dump`). DB credentials are in `config/database.yml`; `config/master.key` is required.
- Engine factories (`factory_bot_rails`, ffaker) are used for fixtures.
- Cucumber auth scenarios must be session-isolated across Capybara drivers — follow `docs/authentication_test_isolation_pattern.md` before touching auth steps/hooks in `features/`.
- `.agents/skills/goggles-main-e2e/SKILL.md` documents manual E2E setup (seeded users, test password reset, dev server gotchas such as the SQLite schema-dump failure on `db:migrate` and the `@base_year` SQL session variable used by Goggles Cup base timings).
- Other deployment docs: `docs/docker_localhost.md`, `docs/production_containers.md`; compose files `docker-compose.{dev,staging,prod}.yml`.
