# Introduction
Make a periodic backup of all your Bitbucket and GitHub repositories using this Docker image.
This image uses `git clone` and `git push --all` to make the backup, so all your history and branches are preserved.

# Prerequisites
1. **Bitbucket**: This script does not work with an SSH key, but with an Bitbucket App Password. You can create this via: https://bitbucket.org/account/settings/app-passwords/
1. **GitHub**: You can create a GitHub token via: https://github.com/settings/tokens

# Usage example
```bash 
docker run -t \
    -e "CRONTAB=0 */6 * * *" \
    -e "BITBUCKET_WORKSPACE=<workspace-here>" \
    -e "BITBUCKET_USERNAME=<username-here>" \
    -e "BITBUCKET_PASSWORD=<password-here>" \
    -e "GITHUB_ORGANISATION=<organisation-here>" \
    -e "GITHUB_TOKEN=<token-here>" \
    -v $(pwd)/backup:/backup \
    programic/bitbucket-backup
```