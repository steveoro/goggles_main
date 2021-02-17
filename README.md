# Goggles Main

[![Build Status](https://steveoro.semaphoreci.com/badges/goggles_main/branches/master.svg?style=shields)](https://steveoro.semaphoreci.com/projects/goggles_main)
[![Maintainability](https://api.codeclimate.com/v1/badges/5179d7eefd4cd93bfba1/maintainability)](https://codeclimate.com/github/steveoro/goggles_main/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/5179d7eefd4cd93bfba1/test_coverage)](https://codeclimate.com/github/steveoro/goggles_main/test_coverage)
[![codecov](https://codecov.io/gh/steveoro/goggles_main/branch/main/graph/badge.svg?token=47SXT4CXGP)](https://codecov.io/gh/steveoro/goggles_main)
![](https://api.kindspeech.org/v1/badge)


Main client UI app for version 7 and onward.


## Wiki & HOW-TOs

- [Official Framework Wiki :link:](https://github.com/steveoro/goggles_db/wiki) (v. 7+)
- [API docs  :link:](https://github.com/steveoro/goggles_api#goggles-api-readme)



## Requires

- Ruby 2.7.2
- Rails 6.0.3
- MariaDb 10.3.25+ or any other MySql equivalent version


## Configuration

All framework app projects (except for the mountable engines) handle multiple configurations for execution, development & deployment.

You can use each project in the framework:

- as a full-blown, stand-alone, local installation (by cloning the source repo on `localhost`)
- as a service composed from individual containers (either by rebuilding the individual containers from scratch or by pulling the images from their DockerHub repository)
- in any other mixed way, be it the application running on `localhost` while accessing the DB inside a container or vice-versa.


## Further information

Check out our [Wiki :link:](https://github.com/steveoro/goggles_db/wiki) and the README files from each subproject for more information. In particular:

- [Suggested tools for development](https://github.com/steveoro/goggles_api#suggested-tools)
- [Repository credentials: management and creation](https://github.com/steveoro/goggles_db/wiki/HOWTO-dev-Goggles_credentials)
- [How to update the GogglesDb gem](https://github.com/steveoro/goggles_api#source-dependencies--how-to-update-gogglesdb)
- [DB setup](https://github.com/steveoro/goggles_db#database-setup)
- [How to run the test suite](https://github.com/steveoro/goggles_api#how-to-run-the-test-suite) (can be applied to `goggles_main` as well)
- [Dev workflow](https://github.com/steveoro/goggles_api#dev-workflow-for-contributors)
- [Getting started: GogglesAPI & container usage](https://github.com/steveoro/goggles_db/wiki/HOWTO-dev-docker_usage_for_GogglesApi#getting-started-setup-and-usage-as-a-composed-docker-service) (can be applied to `goggles_main` as well)


* * *


## Deployment instructions

:construction: TODO :construction:


* * *


## Contributing
1. Clone the project.
2. Make a new custom branch for your changes, naming the branch accordingly (i.e. use prefixes like: `feature-`, `fix-`, `upgrade-`, ...).
3. When you think you're done, make sure you type `guard` (+`Enter`) and wait for the whole spec suite to end.
4. Make sure your branch is locally green (:green_heart:) before submitting the pull request.
5. Await the PR's review by the maintainers.


## License
The application is available as open source under the terms of the [LGPL-3.0 License](https://opensource.org/licenses/LGPL-3.0).

[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fsteveoro%2Fgoggles_main.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2Fsteveoro%2Fgoggles_main?ref=badge_large)


## Supporting

Check out the "sponsor" button at the top of the page.
