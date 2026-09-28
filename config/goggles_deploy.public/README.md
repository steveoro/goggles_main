# About `goggles_deploy`

`goggles_deploy` is the minimal project structure needed to set up the running application using the available Docker images or to prepare a cold-deploy server from a bare-metal machine.


## Setup for `goggles_deploy`

Just copy the files and replicate the folder structure to a dedicated project directory:

```bash
$> cp -R <PATH_TO_RAILS_ROOT>/config/goggles_deploy.public <DESTINATION_PATH>/goggles_deploy
```

The resulting `goggles_deploy` folder holds secrets, volumes, and deploy scripts only.

**Compose source of truth:** `goggles_main/docker-compose.prod.yml` in the application repo.
`deploy_prod.sh` pulls the release image and extracts that file into `goggles_deploy/` each deploy, so you do not hand-sync a separate `docker-compose.prod.yml`.

**Environment config source of truth:** `config/environments/production.rb` (and `staging.rb`) ship inside the Docker image. Do not copy or bind-mount environment files into the deploy directory.

The deploy scripts update the running containers from Docker Hub images (provided the ENV variables are set). Do not pass `--build` on the server.

The `logrotate` configuration file contains a sample setup that allows to rotate all log files & have recurrent backups on a daily basis (if installed on the `crontab` of the running host).

SMTP and other secrets belong in encrypted credentials (`bin/rails credentials:edit` in the app repo). Production mailer host defaults (`master-goggles.org`) live in the repository `production.rb`.


## Missing files

You'll still need to have the following sensitive files in order to have a fully functional `goggles_deploy` run directory:

- goggles_deploy/.env
- goggles_deploy/master-api.key
- goggles_deploy/master-main.key

- goggles_deploy/crontab_check.sh (=> to be copied under ~)
- goggles_deploy/deploy_prod.sh (=> to be copied under ~)

Before the first deploy of an image that uses credential-backed SMTP, add an `smtp` section to the app credentials (`address`, `port`, `user_name`, `password`, and optional `authentication` / `enable_starttls_auto`).

`.env` must **not** contain `DOCKERHUB_USERNAME` or `DOCKERHUB_PASSWORD`. Those are supplied only to `deploy_prod.sh` by CircleCI (or a manual export) for `docker login`, then discarded. Compose still resolves image names via `${DOCKERHUB_USERNAME:-steveoro}` from the deploy shell environment.

## Persistent Solid support databases

Solid Queue and Solid Cable run on **MariaDB** databases (`goggles_queue`, `goggles_cable`) inside the shared `goggles-db` container — no SQLite files are used in production. `rails db:prepare` at container startup creates them (if missing) and loads their schemas from `db/*_schema.rb`. The Rails cache is in-process memory (`:memory_store`).

The `storage.prod` volume bind-mount (`~/Projects/goggles_deploy/storage.prod` → `/app/storage`) must still persist across deploys: it holds ActiveStorage uploads and is shared by the `api`, `main`, and `jobs` services.

Legacy SQLite files (`production_{queue,cache,cable}.sqlite3*`) left over in `storage.prod` from older releases are dormant and can be deleted.

On first rollout after removing a host-copied `production.rb`, delete the obsolete `goggles_deploy/production.rb` file if it still exists on the server.

Check out the Wiki for more information on how to recreate these files from scratch.
