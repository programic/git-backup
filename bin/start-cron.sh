#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

# Include common.sh script
source "$(dirname "${0}")/common.sh"

info "Setup crontab"
echo "${CRONTAB:-0 */6 * * *} /create-backup.sh > /dev/stdout 2>&1" | crontab -

info "Start cron"
crond -f