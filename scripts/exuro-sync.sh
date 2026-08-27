#!/usr/bin/env bash
# Manual upstream sync. Same semantics as .github/workflows/upstream-sync.yml,
# for when you want to drive it locally.
#
#   scripts/exuro-sync.sh            # latest upstream release tag
#   scripts/exuro-sync.sh v4.2.1     # a specific tag
set -euo pipefail

UPSTREAM_URL="https://github.com/NousResearch/hermes-agent.git"

git remote get-url upstream >/dev/null 2>&1 || git remote add upstream "$UPSTREAM_URL"
git fetch upstream --tags --prune --force

TARGET="${1:-$(git tag -l 'v*' --sort=-creatordate --merged upstream/main | head -1)}"
[ -n "$TARGET" ] || { echo "could not resolve an upstream tag" >&2; exit 1; }

echo "==> syncing pristine mirror"
git push origin "refs/remotes/upstream/main:refs/heads/upstream-main" --force

git checkout main
git pull --ff-only origin main

if git merge-base --is-ancestor "$TARGET" HEAD; then
  echo "main already contains $TARGET — nothing to do."
  exit 0
fi

BRANCH="sync/${TARGET}-$(date +%Y%m%d)"
echo "==> $BRANCH : merging $TARGET"
git checkout -b "$BRANCH"

if ! git merge --no-ff --no-edit "$TARGET"; then
  echo
  echo "CONFLICTS:"
  git diff --name-only --diff-filter=U
  echo
  echo "Every path above must be listed in .forkallow. If one isn't, the fork"
  echo "contract was violated — move that code to the hermes-exuro plugin repo"
  echo "rather than resolving the conflict."
  echo
  echo "Resolve, then: git add -A && git commit && git push origin $BRANCH"
  exit 1
fi

echo "==> clean merge. Running the test suite (CI-parity wrapper)."
scripts/run_tests.sh

cat <<EOF

Clean. Next:
  1. Re-check every patch row in FORK.md against $TARGET.
     Anything upstream now implements: DELETE the patch.
  2. git push origin $BRANCH  &&  open the PR
  3. After merge, tag:  v<upstream>+exuro.N
  4. Bump VERSIONS in hermes-dist
EOF
