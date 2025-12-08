#!/usr/bin/env bash
# Non-interactive script to import server submodule into server/ (uses git subtree by default).
# This script is pre-filled with SUBMODULE_URL for the server repo you provided.
#
# Usage:
#   1) Save as convert-submodule-to-folder.sh in the repo root (isinghabhishek/smrtiya-mern-app).
#   2) Make executable: chmod +x convert-submodule-to-folder.sh
#   3) Run: ./convert-submodule-to-folder.sh
#
# Defaults (edit these environment variables before running to change behavior):
# - SUBMODULE_URL: repository to import (pre-filled)
# - SUBMODULE_BRANCH: branch in submodule to import (default: main)
# - MAIN_BRANCH: branch in main repo to base changes on (default: main)
# - PRESERVE_HISTORY: yes -> git subtree add (preserve commit history), no -> copy files only
# - SQUASH: yes -> use --squash with git subtree add to produce one commit, no -> keep history
#
set -euo pipefail

# --- Configurable defaults (change before running if needed) ---
: "${SUBMODULE_URL:=git@github.com:isinghabhishek/smritiyaan-app-server.git}"
: "${SUBMODULE_BRANCH:=main}"
: "${MAIN_BRANCH:=main}"
: "${PRESERVE_HISTORY:=yes}"   # yes or no
: "${SQUASH:=no}"             # yes or no (only used when PRESERVE_HISTORY=yes)
TIMESTAMP="$(date +%Y%m%d%H%M%S)"
BACKUP_BRANCH="backup-server-submodule-${TIMESTAMP}"
WORK_BRANCH="import-server-${TIMESTAMP}"
TMP_REMOTE="tmp-server-import-${TIMESTAMP}"

echo "Starting non-interactive import using:"
echo "  SUBMODULE_URL=${SUBMODULE_URL}"
echo "  SUBMODULE_BRANCH=${SUBMODULE_BRANCH}"
echo "  MAIN_BRANCH=${MAIN_BRANCH}"
echo "  PRESERVE_HISTORY=${PRESERVE_HISTORY}"
echo "  SQUASH=${SQUASH}"
echo

# Safety checks
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: Not inside a git working tree. Run this from the repository root." >&2
  exit 1
fi

if ! git show-ref --verify --quiet "refs/heads/${MAIN_BRANCH}"; then
  echo "ERROR: Local branch ${MAIN_BRANCH} not found. Please create or checkout it first." >&2
  exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
  echo "ERROR: Working tree is not clean. Stash or commit changes and re-run." >&2
  git status --porcelain
  exit 1
fi

echo "Creating backup branch ${BACKUP_BRANCH} from ${MAIN_BRANCH}..."
git checkout "${MAIN_BRANCH}"
git pull --ff-only || true
git checkout -b "${BACKUP_BRANCH}"

echo "Creating work branch ${WORK_BRANCH} from ${MAIN_BRANCH}..."
git checkout "${MAIN_BRANCH}"
git checkout -b "${WORK_BRANCH}"

if [ "${PRESERVE_HISTORY}" = "yes" ]; then
  echo "Using git subtree to preserve history..."

  # Add temporary remote
  if git remote | grep -qx "${TMP_REMOTE}"; then
    git remote remove "${TMP_REMOTE}"
  fi
  git remote add "${TMP_REMOTE}" "${SUBMODULE_URL}"
  git fetch "${TMP_REMOTE}"

  # Check remote branch exists (best-effort)
  if ! git ls-remote --exit-code --heads "${SUBMODULE_URL}" "${SUBMODULE_BRANCH}" >/dev/null 2>&1; then
    echo "WARNING: Remote branch ${SUBMODULE_BRANCH} not found on ${SUBMODULE_URL}."
    echo "Available remote branches (first 20):"
    git ls-remote --heads "${SUBMODULE_URL}" | head -n 20
    echo "Continuing anyway..."
  fi

  # Build subtree add command
  SUBTREE_CMD=(git subtree add --prefix=server "${TMP_REMOTE}" "${SUBMODULE_BRANCH}")
  if [ "${SQUASH}" = "yes" ]; then
    SUBTREE_CMD+=(--squash)
  fi

  echo "Running: ${SUBTREE_CMD[*]}"
  if ! "${SUBTREE_CMD[@]}"; then
    echo "git subtree add failed, attempting fallback (fetch branch + read-tree)..." >&2
    git fetch "${TMP_REMOTE}" "${SUBMODULE_BRANCH}":"${TMP_REMOTE}-${SUBMODULE_BRANCH}"
    git read-tree --prefix=server/ -u "${TMP_REMOTE}-${SUBMODULE_BRANCH}"
    git commit -m "Import server repository (preserve history) into server/ (fallback path)"
    git branch -D "${TMP_REMOTE}-${SUBMODULE_BRANCH}" || true
  fi

  echo "Removing temporary remote ${TMP_REMOTE}..."
  git remote remove "${TMP_REMOTE}" || true

else
  echo "Non-history path: cloning submodule and copying files..."

  TMP_CLONE_DIR="$(mktemp -d -t server-import-XXXXXXXX)"
  git clone --depth 1 --branch "${SUBMODULE_BRANCH}" "${SUBMODULE_URL}" "${TMP_CLONE_DIR}"

  echo "Writing server files from temporary clone..."
  rm -rf server
  mkdir -p server
  # copy including dotfiles
  cp -a "${TMP_CLONE_DIR}/." server/ || true
  rm -rf server/.git || true
  rm -rf "${TMP_CLONE_DIR}" || true

  # attempt to tidy .gitmodules if present
  if [ -f .gitmodules ]; then
    awk '
      BEGIN {RS=""; FS="\n"; ORS="\n\n"}
      /submodule "server"/ {next}
      {print}
    ' .gitmodules > .gitmodules.tmp || true
    if [ -s .gitmodules.tmp ]; then
      mv .gitmodules.tmp .gitmodules
      git add .gitmodules
    else
      rm -f .gitmodules.tmp
    fi
  fi

  rm -rf .git/modules/server || true
fi

# Ensure server/ is a normal folder and commit
if git ls-files --stage server | grep -q '^160000'; then
  git rm -f server || true
fi

git add server || true

# Remove .gitmodules if now empty
if [ -f .gitmodules ]; then
  if ! grep -q '^\[submodule' .gitmodules; then
    git rm -f .gitmodules || true
  else
    git add .gitmodules || true
  fi
fi

git config -f .git/config --remove-section "submodule.server" 2>/dev/null || true

COMMIT_MSG=""
if [ "${PRESERVE_HISTORY}" = "yes" ]; then
  COMMIT_MSG="Import server repository into server/ (preserve history) - imported from ${SUBMODULE_URL}@${SUBMODULE_BRANCH}"
else
  COMMIT_MSG="Convert server submodule into normal folder (import server files from ${SUBMODULE_URL}@${SUBMODULE_BRANCH})"
fi

# If there are staged changes, commit
if git diff --staged --quiet; then
  echo "No staged changes to commit (maybe subtree added with its own commit)."
else
  git commit -m "${COMMIT_MSG}"
fi

echo
echo "Done. Work branch: ${WORK_BRANCH}"
echo "Backup branch: ${BACKUP_BRANCH}"
echo
echo "To review locally:"
echo "  git checkout ${WORK_BRANCH}"
echo "  # run server checks, tests etc:"
echo "  cd server && npm install && npm run dev"
echo
echo "When ready to push and open a PR, run:"
echo "  git push -u origin ${WORK_BRANCH}"
echo
echo "To create a PR with GitHub CLI (gh):"
echo "  gh pr create --base ${MAIN_BRANCH} --head ${WORK_BRANCH} --title \"Convert server submodule into repository folder\" --body-file PR_BODY.md"
echo
echo "Or open a PR in the web UI and paste the contents of PR_BODY.md."
echo
exit 0