---
name: goggles-main-e2e
description: End-to-end testing guide for goggles_main, covering dev server setup, seeded user login, and the Goggles Cup base-year selector.
---

# End-to-end testing guide for `goggles_main`

## Dev environment basics

- Ruby is pinned by `.versions.conf` (currently `ruby-3.4.13`, gemset `goggles7-rails8.1`). In non-interactive shells select it explicitly: `source "$HOME/.rvm/scripts/rvm" && rvm use ruby-3.4.13@goggles7-rails8.1`. Do not rely on machine-specific `/home/ubuntu` paths.
- The app uses MariaDB on the local socket (`/var/run/mysqld/mysqld.sock`) and `root` with no password by default.
- `config/master.key` must contain the `GOGGLES_MAIN_MASTER_KEY` secret.
- `storage/` must be a real directory in local development/test because SQLite Solid databases can live there. Production Docker is different: queue/cable are MariaDB-backed (`goggles_queue`, `goggles_cable`) and a dedicated `jobs` container runs the Solid Queue supervisor.
- DB is seeded/restored from `db/dump/test.sql.bz2` using the custom `db:rebuild` task:
  - `RAILS_ENV=development bin/rails db:rebuild from=test to=development`
  - `RAILS_ENV=development bin/rails db:migrate`
- Note: `db:migrate` may fail at the schema-dump step with `SQLite3::SQLException: near "SHOW"` on the SQLite `cache`/`queue` databases because the `scenic-mysql_adapter` view-dumper is applied to all connections. The primary DB migrations usually complete; if not, set `config.active_record.dump_schema_after_migration = false` in `config/environments/development.rb` for the test run. Ensure the `sqlite3` CLI is installed if you keep `schema_format: :sql` for SQLite.
- `app/assets/builds/application.css` is pre-built by dartsass-rails: a plain `rails server` does NOT recompile sass. After any `.scss` change either run `bin/rails dartsass:build` + hard-reload, or start the app with `bin/dev` (Procfile.dev runs `dartsass:watch`). Otherwise computed styles silently use the stale CSS.

## Test user

- Seeded users are in the dump. To log in as one, reset its password in a runner:
  ```
  user = GogglesDb::User.order(:id).first
  user.password = 'Password123!'
  user.password_confirmation = 'Password123!'
  user.save!
  ```
- Then sign in at `/users/sign_in` using the email and `Password123!`.
- The sign-in form fields are `name="user[email]"` and `name="user[password]"`; the submit button text is `Accedi`.

## Goggles Cup base-year selector

- Radiography URL: `/swimmers/show/:id`
- Goggles Cup page URL: `/swimmers/goggles_cup_base_timings/:id`
- Link on the radiography page: anchor text `Tempi base Goggles Cup`
- Form fields on the Goggles Cup page:
  - `input[name="base_year"]` (number field)
  - submit button text `Seleziona anno base`
- Default locale is `:it`; the base-year label is `Anno base del campionato: %{base_year}`.

## Goggle Cup team-manager browse

- Sign in as a manager for the target team (e.g. `leegaweb@gmail.com` / `Password123!` for team `Lake Ramiro Swimming Club ASD`).
- The `Goggle Cup` command appears in the top `comandi` dropdown when `@current_user_is_manager` or `@current_user_is_admin` is true; link id is `#link-goggle-cups`.
- Browse page URL: `/goggle_cups`
- Form fields:
  - `select[name="season_year"]`
  - hidden `input[name="team_id"]` set by the `team` autocomplete combo-box (selected label visible in the `ComboBox` widget)
  - submit button text `Cerca`
- After searching, available cups appear in `#goggle-cup-titles`.
- Clicking a cup title requests `/goggle_cups/:id/ranking` with `data-turbo-stream="true"` and replaces `#goggle-cup-ranking` with the rendered `_ranking` partial.
- The ranking shows swimmer name, total score, and a current-vs-old meeting table.
- A `Mostra tempi base` toggle expands a collapsible base timings section (Bootstrap `data-toggle="collapse"`) when base rows are present.

## Known gotcha: SQL `@base_year` session variable

- `GogglesDb::GogglesCup3yBaseTimings.with_base_year(year)` executes `SET @base_year = <year>`; the variable is connection-local.
- The helper function `goggles_db_base_year()` falls back to the computed championship year only when `@base_year` is NULL.
- Current `SwimmersController#default_base_year` explicitly executes `SET @base_year = NULL` before calling the function, and `GoggleCupsController#with_base_year` resets the variable in an ensure block. If fallback behavior looks stale, verify those resets rather than assuming an old unmerged branch is required.

## Production/local queue distinction

Local development/test examples in this file refer to SQLite files under `storage/`. Do not use them to reason about production queue locking: current production compose uses MariaDB queue/cable DBs plus the `goggles-jobs` service.

## Devin Secrets Needed

- `GOGGLES_MAIN_MASTER_KEY` for `config/master.key`.
