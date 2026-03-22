#!/bin/bash
cd /Users/tarou/management/gym_website

echo "Initializing Git..." > deploy_status.txt
git init >> deploy_status.txt 2>&1
git branch -M main >> deploy_status.txt 2>&1
git add . >> deploy_status.txt 2>&1
git commit -m "Deploy for preview" >> deploy_status.txt 2>&1

echo "Checking gh auth..." >> deploy_status.txt
GH_USER=$(gh api user | grep '"login":' | head -n 1 | awk -F '"' '{print $4}')

if [ -z "$GH_USER" ]; then
    echo "ERROR: GitHub CLI is not authenticated or not installed." >> deploy_status.txt
    exit 1
fi

REPO_NAME="premium-gym-lp-$(date +%s)"
echo "Creating repository: $REPO_NAME for user $GH_USER..." >> deploy_status.txt
gh repo create $REPO_NAME --public --source=. --remote=origin --push >> deploy_status.txt 2>&1

echo "Enabling pages..." >> deploy_status.txt
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/$GH_USER/$REPO_NAME/pages \
  -f "source[branch]=main" -f "source[path]=/" >> deploy_status.txt 2>&1

echo "SUCCESS: https://$GH_USER.github.io/$REPO_NAME/" >> deploy_status.txt
