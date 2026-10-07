# Bot swarm mitigation (2026-10-06)

Incident notes: what was hitting master-goggles.org, why the droplet kept
hanging, and the exact mitigations applied. Companion file:
[`goggles-botblock.conf`](./goggles-botblock.conf) (Apache deny rules,
installed on the server at `/etc/apache2/conf-available/`).

## Symptoms

- Droplet peaked in CPU/RAM roughly hourly; `docker stats` + DO graphs showed
  sustained saturation.
- Whole-box **hangs** (not OOM-kills): journald simply stopped logging; the box
  needed dashboard power-cycles. Dead windows on 2026-10-06: ~06:55–07:31 and
  ~11:54–13:11, then a hard reboot at 16:56. Earlier boots lasted ~22h each.

## Root cause

A distributed scraping campaign, not organic traffic:

- ~165K requests logged in ~17h; **~88%** of them were `GET
  /meetings/swimmer_results/:id?swimmer_id=N` + `/meetings/team_results/*`
  (Devise `401` via login gating) and the `/users/sign_in` fetches that follow.
- `api_daily_use_agents` showed a **fixed pool of ~14 rotating desktop Chrome
  UAs** (~13K hits each per day) spread over hundreds of IPs (~200 req/day/IP)
  — a scraping-as-a-service botnet. IPs: DigitalOcean, Azure, Alibaba ranges.
- Per-request cost amplifier: every hit (including 401s) runs the whole
  `ApplicationController` before-action chain — `update_stats` writes to
  `api_daily_uses` + `api_daily_use_agents` (~3 writes, the shared-UA rows are
  a lock hotspot), plus `app_settings_row`, `check_maintenance_mode`,
  `check_anonymous_request_limit` reads. ~7 SQL queries per bot hit.
- Hardware: 1 vCPU / 1.9GB RAM / **no swap**; container `mem_limit`s summed to
  ~3.3GB (main 1536m, api 1g, jobs 768m, db unlimited) → kernel livelock
  instead of targeted OOM-kill.
- Rack::Attack was deployed but never fired (zero `429`s): botnet uses real
  browser UAs (misses `BOT_UA_PATTERN`) and rotates IPs below the per-IP
  limits. `max_anonymous_req: 500/day` likewise never trips at ~200/IP.

## Mitigations applied

### 1. Swap (prevents the livelock hangs)

```bash
sudo fallocate -l 2G /swapfile || sudo dd if=/dev/zero of=/swapfile bs=1M count=2048
sudo chmod 600 /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/60-goggles-swap.conf
sudo sysctl --system
```

### 2. Container memory limits

Applied live (`docker update --memory`, no recreate) and persisted in
`docker-compose.override.yml`; defaults also updated in
`docker-compose.prod.yml` so the next image ships them:

| Service     | Old       | New    |
| ----------- | --------- | ------ |
| main        | 1536m     | 1024m  |
| api         | 1g        | 384m   |
| jobs        | 768m      | 640m   |
| goggles-db  | unlimited | 448m   |

`jobs` runs ~420MiB idle — bump back to 768m if it starts OOM-restarting
under heavy import batches.

### 3. Apache bot block

`docs/goggles-botblock.conf` installed as `/etc/apache2/conf-available/` +
`a2enconf` + reload. Denies major DC ranges (DO /16s, `20/8`, `52/8`,
`47/8`, `57.141/16`, `45.148.10/24`, `168.144/16`, `195.178.110/24`) and
`/wp-*|xmlrpc|.env|.git|phpmyadmin` probes. `<If "%{SERVER_PORT} != '447'">`
keeps the API vhost unaffected — legit API consumers may run on cloud IPs.

Blocked hits return `403` at Apache (~0 cost) instead of a ~28ms Rails
request + ~7 queries.

### 4. Apache MPM

`MaxRequestWorkers` 150 → **50** (2 servers × 25 threads) — bounds Apache
memory and stops deep proxy queues onto 5 Puma threads. Must be a multiple
of `ThreadsPerChild` or Apache rounds down with an `AH00513` warning.

## Caveats / maintenance

- **DO Uptime Probes** originate from random DO IPs and now get `403`. A 403
  still proves the host is alive; only a check configured to require `200`
  would alert falsely. do-agent resource alerts (CPU/mem/disk/load) are
  unaffected. To exempt probes by UA instead of IP, add a `<RequireAny>`
  with `Require expr %{HTTP_USER_AGENT} =~ /DigitalOcean Uptime Probe/`.
- The swarm **rotates ranges** when blocked (DO+Azure-20 → Alibaba-47 +
  Azure-52 within ~30 min). To find newly-rotating ranges:

  ```bash
  sudo awk '$9==200 {print $1}' /var/log/apache2/prod_access.log | sort | uniq -c | sort -rn | head -20
  ```

  …then append `Require not ip <cidr>` and `systemctl reload apache2`.
- If rotation outpaces manual patching, **Cloudflare free** in front of the
  site (ASN bot filtering + edge cache for assets) is the structural fix.
- Residential-proxy IPs (e.g. Telecom Italia) can't be CIDR-blocked without
  hurting real users — residual scraping is expected at a lower rate.

## Code-level follow-ups (applied 2026-10-07, engine v0.10.57)

- `update_stats` moved to an `after_action` in `ApplicationController` —
  requests halted in before_actions (Devise 401 throws, throttle/maintenance
  redirects) never reach `api_daily_uses`/`api_daily_use_agents`, so the
  401-scrape traffic no longer writes to the DB at all.
- `GogglesDb::AppParameter.maintenance?` and the `:app` settings group
  (`max_anonymous_req`, `max_bot_req`, `max_req_per_minute`) are now served
  from `Rails.cache` with a 1-minute TTL (`AppParameter.cached_app_settings`,
  `MAINTENANCE_CACHE_KEY`); `maintenance=` busts its key. Cuts ~3-4 SELECTs
  per request on top of the removed writes.
- `earlyoom` installed on the host as a last-resort safeguard (SIGTERM the
  largest process before livelock; with swap it should rarely fire).
- Droplet resize still unnecessary: legit traffic is ~12% of load. If the
  botnet out-adapts CIDR patching, put Cloudflare (free) in front — see
  notes on ASN filtering/edge caching above; remember the API vhost on :447
  can't be proxied by CF free (non-standard port → would need an `api.`
  subdomain on :443).
