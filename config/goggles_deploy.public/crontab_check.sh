#!/bin/bash
#
# crontab_check.sh — periodic Slack check-in for the production droplet.
#
# Posts to the Goggles Slack channel: Monit status, production site probe,
# API probe and a condensed container/host health line (restarts since the
# last run, earlyoom/kernel-OOM kills, autoheal restarts, host reboots,
# memory/swap usage).
#
# Runs from root's crontab (HOME=/root, so absolute /home/deploy paths only):
#
#   00 6 * * * /bin/bash -l /home/deploy/crontab_check.sh >/dev/null 2>&1
#   00 12 * * * /bin/bash -l /home/deploy/crontab_check.sh >/dev/null 2>&1
#   00 20 * * * /bin/bash -l /home/deploy/crontab_check.sh >/dev/null 2>&1
#
# Requires ~/Projects/goggles_deploy/slack.env (WEBHOOK_URL=..., chmod 600).
# DRY_RUN=1 prints the messages instead of posting (and skips the state file).
# Source this file to test the summarize_* functions standalone.

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

DEPLOY_DIR=${DEPLOY_DIR:-/home/deploy/Projects/goggles_deploy}
SLACK_ENV=${SLACK_ENV:-$DEPLOY_DIR/slack.env}
STATE_FILE=${STATE_FILE:-/home/deploy/.crontab_check.last}
CONTAINERS=${CONTAINERS:-goggles-db goggles-main goggles-api goggles-jobs autoheal}
SWAP_WARN_PCT=${SWAP_WARN_PCT:-75}

[[ -r $SLACK_ENV ]] && source "$SLACK_ENV"

if [[ -z ${SINCE:-} ]]; then
  if [[ -r $STATE_FILE ]]; then
    SINCE=$(cat "$STATE_FILE")
  else
    SINCE=$(( $(date +%s) - 36000 )) # longest gap between runs: 20:00 -> 06:00
  fi
fi

post() {
  if [[ -n ${DRY_RUN:-} || -z ${WEBHOOK_URL:-} ]]; then
    echo "$1"
  else
    curl -s --max-time 20 -X POST -H 'Content-type: application/json' \
      --data "$(jq -nc --arg t "$1" '{text:$t}')" "$WEBHOOK_URL" >/dev/null
  fi
}

# Reads earlyoom journal lines on stdin; prints e.g. "earlyoom killed: ruby×2, node×1"
summarize_earlyoom() {
  grep -oE 'sending SIG(TERM|KILL) to process [0-9]+ uid [0-9]+ "[^"]+"' \
    | sed -E 's/^.*"([^"]+)"$/\1/' \
    | sort | uniq -c \
    | sed -E 's/^ *([0-9]+) +(.*)$/\2×\1/' \
    | awk '{out = out (NR > 1 ? ", " : "") $0} END {if (out != "") print "earlyoom killed: " out}'
}

# Reads kernel journal lines on stdin; prints e.g. "kernel OOM: ruby×1"
summarize_kernel_oom() {
  grep -oE 'Killed process [0-9]+ \([^)]+\)' \
    | sed -E 's/^.*\(([^)]+)\)$/\1/' \
    | sort | uniq -c \
    | sed -E 's/^ *([0-9]+) +(.*)$/\2×\1/' \
    | awk '{out = out (NR > 1 ? ", " : "") $0} END {if (out != "") print "kernel OOM: " out}'
}

# Reads `docker logs autoheal` lines on stdin; prints e.g. "autoheal restarted: goggles-main×1"
summarize_autoheal() {
  grep -oE 'Container /[^ ]+ \([0-9a-f]+\) found to be unhealthy' \
    | sed -E 's|^Container /([^ ]+) .*$|\1|' \
    | sort | uniq -c \
    | sed -E 's/^ *([0-9]+) +(.*)$/\2×\1/' \
    | awk '{out = out (NR > 1 ? ", " : "") $0} END {if (out != "") print "autoheal restarted: " out}'
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  # Check Monit 'up' status (synthetic):
  monit_status=$(sudo -n /usr/bin/monit report 2>/dev/null | head -n 1)
  if [[ $monit_status == *100.0%* ]]; then
    post "Monit: 👌 -- status: $monit_status"
  else
    post "Monit: 🤔 -- status: $monit_status 😱"
  fi

  # Check Production Server status:
  prod_status=$(curl --write-out '%{http_code}' --silent --head --output /dev/null --max-time 20 https://master-goggles.org)
  if [[ $prod_status == 30* || $prod_status == 20* ]]; then
    post "Production: 👍"
  else
    post "Production: 💀 -- status: $prod_status 😱😱"
  fi

  # Check API status:
  api_status=$(curl -s --max-time 20 -o /dev/null -w '%{http_code}' https://master-goggles.org:447/api/v3/status)
  if [[ $api_status == 200 ]]; then
    post "API: 👍"
  else
    post "API: 💀 -- status: $api_status 😱😱"
  fi

  # Container & host health digest since SINCE:
  issues=()
  running=0
  total=0
  boot=$(date -d "$(uptime -s)" +%s 2>/dev/null || echo 0)
  if (( boot > SINCE )); then
    issues+=("host rebooted $(date -u -d "@$boot" '+%d/%m %H:%M') UTC")
  fi
  for name in $CONTAINERS; do
    ((total++)) || true
    info=$(docker inspect -f '{{.State.Status}} {{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}} {{.RestartCount}} {{.State.StartedAt}} {{.Created}}' "$name" 2>/dev/null)
    if [[ -z $info ]]; then
      issues+=("$name missing")
      continue
    fi
    read -r status health rc started_at created <<<"$info"
    if [[ $status != running ]]; then
      issues+=("$name $status (rc=$rc)")
      continue
    fi
    ((running++)) || true
    if [[ $health == unhealthy ]]; then
      issues+=("$name unhealthy")
      continue
    fi
    # Recreated after SINCE => a deploy replaced it, not an incident:
    created_epoch=$(date -d "$created" +%s 2>/dev/null || echo 0)
    (( created_epoch > SINCE )) && continue
    # Started after SINCE (and not at boot) => an actual restart:
    started_epoch=$(date -d "$started_at" +%s 2>/dev/null || echo 0)
    if (( started_epoch > SINCE && started_epoch > boot + 300 )); then
      issues+=("$name restarted $(date -u -d "@$started_epoch" '+%H:%M') UTC (rc=$rc)")
    fi
  done
  # Cause hints (root's journald + autoheal logs):
  hint=$(journalctl -q -u earlyoom --since "@$SINCE" --no-pager 2>/dev/null | summarize_earlyoom)
  [[ -n $hint ]] && issues+=("$hint")
  hint=$(journalctl -q _TRANSPORT=kernel --since "@$SINCE" --no-pager 2>/dev/null | summarize_kernel_oom)
  [[ -n $hint ]] && issues+=("$hint")
  hint=$(docker logs --since "$SINCE" autoheal 2>&1 | summarize_autoheal)
  [[ -n $hint ]] && issues+=("$hint")
  # Memory & swap:
  mem=$(free -m | awk '/^Mem:/{mt=$2;ma=$7} /^Swap:/{st=$2;su=$3} END{printf "mem %.1f/%.1fG · swap %.1f/%.1fG", (mt-ma)/1024, mt/1024, su/1024, st/1024}')
  swap_pct=$(free -m | awk '/^Swap:/{if ($2 > 0) printf "%d", $3 * 100 / $2; else printf "0"}')
  (( swap_pct >= SWAP_WARN_PCT )) && issues+=("swap high (${swap_pct}%)")
  # Version tag of the running main image:
  img=$(docker inspect -f '{{.Config.Image}}' goggles-main 2>/dev/null)
  tag=${img##*:}
  if (( ${#issues[@]} > 0 )); then
    joined=$(printf '%s; ' "${issues[@]}")
    post "Containers: 🤔 -- ${joined%; } · $mem 😱"
  else
    post "Containers: 👌 -- $running/$total up (v$tag) · $mem"
  fi

  [[ -z ${DRY_RUN:-} ]] && date +%s > "$STATE_FILE"
fi
