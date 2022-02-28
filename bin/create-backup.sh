#!/usr/bin/env bash

set -o errexit
set -o pipefail

# Include common.sh script
source "$(dirname "${0}")/common.sh"

clone_or_pull() {
  for repository in ${1}; do
    project_name=$(basename "${repository}")
    project_name="${project_name%.*}"

    backup_folder="${2}/${project_name}"
    if [[ -d "${backup_folder}" ]]; then
      info "Pull repository ${project_name}"
      # Use `-c core.fileMode=false` to ignore permission changes. Some NAS devices can change the permissions after download.
      (cd "${backup_folder}" && git -c core.fileMode=false pull --all || true)
    else
      info "Clone repository ${project_name}"
      (cd "${2}" && git clone "${repository}" || true)
    fi

    success "Backup of repository ${project_name} is successfully created"
  done
}

bitbucket() {
  : ${BITBUCKET_USERNAME?"You need to set the BITBUCKET_USERNAME environment variable."}
  : ${BITBUCKET_PASSWORD?"You need to set the BITBUCKET_PASSWORD environment variable."}
  : ${BITBUCKET_WORKSPACE?"You need to set the BITBUCKET_WORKSPACE environment variable."}

  backup_base="/backup/bitbucket"

  mkdir -p "${backup_base}"

  info "Gathering information from Bitbucket"

  for i in {1..2}; do
    curl -s -u ${BITBUCKET_USERNAME}:${BITBUCKET_PASSWORD} "https://api.bitbucket.org/2.0/repositories/${BITBUCKET_WORKSPACE}?pagelen=100&page=${i}" > /tmp/bitbucket-${i}.json
  done

  info "List all repositories"
  repositories=$(cat /tmp/bitbucket-*.json | jq -r '.values[] | .links.clone[0].href')

  # Replace https://username@bitbucket.org to https://username:password@bitbucket.org
  repositories=$(echo "${repositories}" | sed -e "s/${BITBUCKET_USERNAME}@/${BITBUCKET_USERNAME}:${BITBUCKET_PASSWORD}@/g")

  rm /tmp/*

  clone_or_pull "${repositories}" "${backup_base}"
}

github() {
  : ${GITHUB_ORGANISATION?"You need to set the GITHUB_ORGANISATION environment variable."}
  : ${GITHUB_TOKEN?"You need to set the GITHUB_TOKEN environment variable."}

  backup_base="/backup/github"

  mkdir -p "${backup_base}"

  info "Gathering information from GitHub"

  for i in {1..2}; do
    curl -s -u token:${GITHUB_TOKEN} "https://api.github.com/orgs/${GITHUB_ORGANISATION}/repos?per_page=100&page=${i}" > /tmp/github-${i}.json
  done

  info "List all repositories"
  repositories=$(cat /tmp/github-*.json | jq -r '.[] | .clone_url')

  # Replace https://github.com to https://token:token@github.com
  repositories=$(echo "${repositories}" | sed -e "s/https:\/\//https:\/\/token:${GITHUB_TOKEN}@/g")

  rm /tmp/*

  clone_or_pull "${repositories}" "${backup_base}"
}

if [[ -n "${BITBUCKET_PASSWORD}" ]]; then
  bitbucket
fi

if [[ -n "${GITHUB_TOKEN}" ]]; then
  github
fi