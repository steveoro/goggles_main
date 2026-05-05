# Goggles Main Rails 8.1 Turbo Closure Tracker

This tracker supersedes the execution flow previously split between:

- `docs/plans/goggles_main_rails81_turbo_hard_switch_plan-day1.md`
- `docs/plans/goggles_main_rails81_turbo_hard_switch_plan-day2.md`

Day 2 remains the historical baseline of what was already stabilized, while this file tracks closure using failure buckets instead of phase/day sequencing.

## Baseline Snapshot

- Phase 0-3 were mostly stabilized.
- Phase 4 was partially validated.
- Phase 5-8 still had open regressions at the time of supersession.

## Failure Buckets

- [x] Turbo navigation contract (`method: :get` link spoofing, UJS-only link/form attributes)
- [x] Jobs stack closure (DelayedJob leftovers, Solid Queue parity, Mission Control wiring)
- [x] UJS/js.erb hard cut (`@rails/ujs` boot removed, dead js.erb responders removed)
- [ ] Laps/relay modal lifecycle stabilization (Cucumber)
- [ ] Issues auth redirection stabilization (Cucumber)
- [ ] User workshops date-filter stabilization (Cucumber)
- [ ] Full regression gate closure (focused + full suite checkpoints)
- [ ] Chrono redesign follow-up plan (separate post-stabilization phase)

## Notes

- Keep Bootstrap 4 runtime compatibility for now (temporary jQuery runtime allowed), while removing app-level jQuery/UJS contracts.
- Chrono redesign stays out of the core closure stream and starts only once all non-Chrono migration blockers are green.
