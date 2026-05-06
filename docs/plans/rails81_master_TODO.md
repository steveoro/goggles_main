# Goggles Main Rails 8.1 - TODOs

- [~] Laps/relay modal lifecycle stabilization (Cucumber)
  after a successful save, should reload the part with the laps

- [ ] redesign drop-down autocomplete components to use Turbo Streams instead of jQuery (compare with the one using TomSelect used in AdminHub)
  - [ ] redesign component
  - [ ] replace usage in whole app

- [ ] when navigating back and forth from the team's and swimmer's result pages, going back to the meeting#show page doesn't keep the already retrieved details (complex restructuring)

- [ ] Move existing cron jobs to Solid Queue (backup, import queues and other maintenance tasks)

- [ ] Update target container: test locally with Docker compose first
  - [ ] Investigate alternative: Kamal (=> the whole deploy flow has to change)

- [ ] Chrono redesign follow-up plan (separate post-stabilization phase)

- [ ] design parametric views to improve and speed-up meeting details display
