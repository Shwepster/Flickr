#!/usr/bin/env bash
# PreToolUse hook: blocks destructive bash commands regardless of flag syntax.
# Reads Claude Code hook JSON from stdin; on match, emits a deny decision.
set -euo pipefail

cmd=$(jq -r '.tool_input.command // ""')

# Collapse runs of whitespace; keep a leading space so boundary checks work.
norm=" $(printf '%s' "$cmd" | tr '\n\t' '  ' | tr -s ' ') "
# Lowercased copy for case-insensitive SQL/keyword matching.
lower=$(printf '%s' "$norm" | tr '[:upper:]' '[:lower:]')

deny() {
  jq -nc --arg r "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $r
    }
  }'
  exit 0
}

# --- sudo (any form) ---
[[ "$norm" =~ [[:space:]\|\;\&\`\(]sudo[[:space:]] ]] && \
  deny "sudo is blocked by project policy (.claude/hooks/block-destructive.sh)"

# --- rm (any flags, any form) ---
# Matches 'rm' as a command head: after start, whitespace, pipe, semicolon, &&, ||, backtick, or $(
if [[ "$norm" =~ [[:space:]\|\;\&\`\(]rm[[:space:]] ]]; then
  deny "rm is blocked by project policy — use the Edit/Write tools or ask the user"
fi

# --- find ... -delete / find ... -exec rm ---
if [[ "$norm" =~ [[:space:]\|\;\&\`\(]find[[:space:]] ]] && \
   [[ "$norm" =~ (-delete([[:space:]]|$)|-exec[[:space:]]+rm[[:space:]]) ]]; then
  deny "find -delete / find -exec rm is blocked"
fi

# --- xargs rm ---
if [[ "$norm" =~ xargs[[:space:]](-[^[:space:]]+[[:space:]])*rm([[:space:]]|$) ]]; then
  deny "xargs rm is blocked"
fi

# --- Destructive git ---
if [[ "$norm" =~ git[[:space:]]+reset([[:space:]]+[^[:space:]]+)*[[:space:]]+--hard ]]; then
  deny "git reset --hard is blocked"
fi
if [[ "$norm" =~ git[[:space:]]+push([[:space:]]+[^[:space:]]+)*[[:space:]]+(--force|--force-with-lease|-f)([[:space:]]|$) ]]; then
  deny "git force push is blocked"
fi
if [[ "$norm" =~ git[[:space:]]+clean([[:space:]]+[^[:space:]]+)*[[:space:]]+-[a-zA-Z]*f ]]; then
  deny "git clean -f* is blocked"
fi
if [[ "$norm" =~ git[[:space:]]+branch([[:space:]]+[^[:space:]]+)*[[:space:]]+(-D|--delete[[:space:]]+--force) ]]; then
  deny "git branch -D / --delete --force is blocked"
fi
if [[ "$norm" =~ git[[:space:]]+checkout[[:space:]]+-- ]]; then
  deny "git checkout -- <paths> is blocked (overwrites working tree)"
fi
if [[ "$norm" =~ git[[:space:]]+restore[[:space:]]+(\.|--source|--worktree|--staged[[:space:]]+\.) ]]; then
  deny "git restore . / --source is blocked"
fi
if [[ "$norm" =~ git[[:space:]]+(filter-branch|filter-repo) ]]; then
  deny "git filter-branch / filter-repo is blocked"
fi
if [[ "$norm" =~ git[[:space:]]+stash[[:space:]]+(drop|clear) ]]; then
  deny "git stash drop / clear is blocked"
fi
if [[ "$norm" =~ git[[:space:]]+worktree[[:space:]]+remove([[:space:]]+[^[:space:]]+)*[[:space:]]+(--force|-f) ]]; then
  deny "git worktree remove --force is blocked"
fi
if [[ "$norm" =~ git[[:space:]]+reflog[[:space:]]+(delete|expire) ]]; then
  deny "git reflog delete / expire is blocked"
fi
if [[ "$norm" =~ git[[:space:]]+gc([[:space:]]+[^[:space:]]+)*[[:space:]]+--prune=now ]]; then
  deny "git gc --prune=now is blocked"
fi
if [[ "$norm" =~ git[[:space:]]+update-ref[[:space:]]+-d ]]; then
  deny "git update-ref -d is blocked"
fi

# --- Process / system control ---
if [[ "$norm" =~ [[:space:]\|\;\&\`\(](kill|killall|pkill)[[:space:]] ]]; then
  deny "kill / killall / pkill is blocked"
fi
if [[ "$norm" =~ [[:space:]\|\;\&\`\(](shutdown|reboot|halt|poweroff)([[:space:]]|$) ]]; then
  deny "shutdown / reboot / halt is blocked"
fi

# --- Filesystem destruction ---
if [[ "$norm" =~ [[:space:]\|\;\&\`\(]mkfs(\.[a-z0-9]+)?[[:space:]] ]]; then
  deny "mkfs is blocked"
fi
if [[ "$norm" =~ [[:space:]\|\;\&\`\(]dd[[:space:]] ]] && [[ "$norm" =~ [[:space:]]of= ]]; then
  deny "dd with of= is blocked"
fi
if [[ "$norm" =~ [[:space:]\|\;\&\`\(]shred[[:space:]] ]]; then
  deny "shred is blocked"
fi
if [[ "$norm" =~ [[:space:]\|\;\&\`\(]truncate[[:space:]] ]]; then
  deny "truncate is blocked"
fi
if [[ "$norm" =~ chmod[[:space:]]+(-R[[:space:]]+)?0?777 ]]; then
  deny "chmod 777 is blocked"
fi
if [[ "$norm" =~ chown[[:space:]]+(-R|--recursive) ]]; then
  deny "chown -R is blocked"
fi

# --- Fork bomb ---
if [[ "$norm" == *":(){"* ]] || [[ "$norm" == *":|:&"* ]]; then
  deny "fork bomb pattern blocked"
fi

# --- Database destruction (case-insensitive) ---
if [[ "$lower" =~ drop[[:space:]]+(database|table|schema|index|view) ]]; then
  deny "DROP DATABASE/TABLE/SCHEMA/INDEX/VIEW is blocked"
fi
if [[ "$lower" =~ truncate[[:space:]]+table ]]; then
  deny "TRUNCATE TABLE is blocked"
fi
if [[ "$lower" =~ delete[[:space:]]+from ]] && ! [[ "$lower" =~ where ]]; then
  deny "DELETE FROM without WHERE is blocked"
fi
if [[ "$lower" =~ redis-cli([[:space:]]+[^[:space:]]+)*[[:space:]]+(flushall|flushdb) ]]; then
  deny "redis FLUSHALL / FLUSHDB is blocked"
fi
if [[ "$lower" =~ dropdatabase\( ]] || [[ "$lower" =~ \.drop\( ]]; then
  deny "dropDatabase() / .drop() is blocked"
fi

# Not destructive — allow.
exit 0
