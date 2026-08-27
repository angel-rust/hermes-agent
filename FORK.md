# Fork contract — exuro/hermes-agent

Upstream: https://github.com/NousResearch/hermes-agent (MIT)

## The contract

1. **`upstream-main` is sacred.** Pristine mirror. Any commit on it is a bug.
2. **Every patch on `main` is listed below with an owner, a reason, and an upstream PR
   link or an explicit "cannot upstream" justification.** No exceptions, no orphans.
3. **A patch that could be a plugin, skill, skin, MCP server, or config key is rejected.**
   `fork-guard` fails CI on any diff outside `.forkallow`.
4. **Patches are file-isolated.** Prefer a new file over editing `run_agent.py`,
   `cli.py`, or `gateway/run.py` — those are the god-files upstream refactors constantly
   and every edit inside them is a future conflict.
5. **Upstreaming is the goal, not a courtesy.** A merged upstream PR deletes a patch from
   this table. That is the win condition.

## Active patches

| # | Files | Why | Owner | Upstream PR | Status |
|---|---|---|---|---|---|
| _(empty — keep it that way)_ | | | | | |

## Retired patches

| # | Retired | Reason |
|---|---|---|
| | | |

## Sync procedure

Nightly `upstream-sync.yml` fast-forwards `upstream-main` and opens a `sync/<date>` PR
merging the latest upstream **release tag** into `main`.

Reviewing a sync PR:

1. Read the conflict list. Conflicts land in exactly the files in `.forkallow` — if a
   conflict appears anywhere else, someone violated the contract; fix that first.
2. `scripts/run_tests.sh` (never bare `pytest` — the wrapper enforces CI parity).
3. Re-check every patch in the table above against the new upstream: upstream may have
   implemented it, which means delete the patch, don't re-merge it.
4. Merge. Tag `v<upstream>+exuro.N`. `hermes-dist` picks it up.

Conflicted PRs are labeled `sync-conflict` and are the highest-priority work in the repo.
A sync PR older than a week is how forks die.

## Manual sync

```bash
scripts/exuro-sync.sh              # latest upstream release tag
scripts/exuro-sync.sh v4.2.1       # a specific tag
```
