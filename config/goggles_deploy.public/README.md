# About `goggles_deploy`

`goggles_deploy` is the minimal project structure needed to set up the running application using the available Docker images or to prepare a cold-deploy server from a bare-metal machine.


## Setup for `goggles_deploy`

Just copy the files and replicate the folder structure to a dedicated project directory:

```bash
$> cp -R <PATH_TO_RAILS_ROOT>/config/goggles_deploy.public <DESTINATION_PATH>/goggles_deploy
```

The resulting `goggles_deploy` folder can be used to run the docker-compose scripts in it.

The deploy scripts can be used to force a running service to update the images for its running containers (provided the ENV variables are set).

The `logrotate` configuration file contains a sample setup that allows to rotate all log files & have recurrent backups on a daily basis (if installed on the `crontab` of the running host).

The bespoke versions of `production.rb` & `staging.rb` environment files are supposed to be used on the deploy server because of the default URL used for sending out e-mails. Beside that, those should be equal to the ones stored in `config/environments`.

Be advised also that if you plan to send out e-mails from localhost, you'll obviously need a running MTA service running and then use the same environment files from `config/environments`.


## Missing files

You'll still need to have the following sensible files in order to have a fully functional `goggles_deploy` run directory:

- goggles_deploy/.env
- goggles_deploy/crontab_check.sh
- goggles_deploy/master-api.key
- goggles_deploy/master-main.key

Check out the Wiki for more information on how to recreate these files from scratch.
