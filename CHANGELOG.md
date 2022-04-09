## Relevant Version History / current working features:

_Please, add the latest build info on top of the list; use Version::MAJOR only after gold release; keep semantic versioning in line with framework's_

- **0.3.51** [Steve A.] re-sync w/ base engine
- **0.3.50** [Steve A.] re-sync with base engine; bump Rails to 6.0.4.7 for security fixes; additional specs
- **0.3.48** [Steve A.] re-sync with base engine; added: improved user dashboard, stats to /team & /swimmer details, current_swimmers to /teams, meetings & workshops filtered grids to /team & /swimmer, history_recap & history (w/ graphs) to /swimmer + lots of code improvements
- **0.3.46** [Steve A.] minor bundle security fixes; re-sync with base engine
- **0.3.43** [Steve A.] added a more versatile wait statement when checking for meeting/show readiness in Cucumber specs to improve test stability
- **0.3.42** [Steve A.] upgrade to Rails 6.0.4.6 due to security fixes
- **0.3.41** [Steve A.] updated Stimulus to v3; added wizard-form for /chrono/new with overall summary & crude validation; added "new" flag icon to DbLookupComponents; crude user dashboard & team swimmers list
- **0.3.39** [Steve A.] re-synch w/ DB structure 1.95.3; added /fin_score compute feature; additional specs for all /chrono endpoints
- **0.3.29** [Steve A.] upgrade to Rails 6.0.4.1 due to security fixes
- **0.3.20** [Steve A.] re-synch w/ DB structure 1.92.3 (data clean-up)
- **0.3.11** [Steve A.] data fixes for laps; fixes for sorter strategies; slightly improved user_workshop/show page; DB structure 1.92.0
- **0.3.06** [Steve A.] swimming_pool association in UserResult is no longer optional; minimal support for UserWorkshops in search & show
- **0.3.01** [Steve A.] improved structure for import_queues & helpers; data migrations, misc fixes; fully integrated Chrono controllers
- **0.2.18** [Steve A.] upgraded gem set due to security fixes; added support for UserWorkshop, UserResult & UserLap
- **0.2.11** [Steve A.] captcha protection for user registrations
- **0.2.05** [Steve A.] fixed Semaphore configuration for production deploys
- **0.2.01** [Steve A.] improved build pipeline, mailer template styles and localhost configuration
- **0.1.93** [Steve A.] revised Docker builds & continuous deployment procedure
- **0.1.80** [Steve A.] custom Devise views & improved layouts; added OAuth2 support for Google & Facebook direct login
- **0.1.76** [Steve A.] aligned with GogglesAPI configuration; "open" search/smart feature
- **0.1.1** [Steve A.] initial Project boilerplate & CI config
