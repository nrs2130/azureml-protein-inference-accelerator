#!/bin/bash
# Usage: ./create_repo.sh [GitHub-username] [New-Repo-Name]
GH_USER="${1:-nrs2130}"
REPO_NAME="${2:-azureml-protein-inference-accelerator}"

# Create a new GitHub repo using GitHub CLI
gh repo create "${GH_USER}/${REPO_NAME}" --public -y

# Initialize git, add files, and push to the new GitHub repo
git init
git add -A
git commit -m "Initial commit"
git branch -M main
git remote add origin "https://github.com/${GH_USER}/${REPO_NAME}.git"
git push -u origin main
