---
name: smart-notifier
description: Send intelligent notifications via ~/bin/notifier with context-aware channel selection. Use when completing tasks, asking questions, encountering errors, or reaching milestones.
tools: Bash
---

# Smart Notification System

## Overview

You have access to a sophisticated multi-channel notification system via `~/bin/notifier`. This skill helps you make smart decisions about when and how to notify the user.

## Quick Reference

```bash
# Basic notification (requires 'notify' subcommand!)
notifier notify -t "Title" -m "Message"

# With urgency levels: normal|high|critical
notifier notify -t "Title" -m "Message" -u high

# Send to phone via Pushover (for remote notifications)
notifier notify -t "Title" -m "Message" -P true

# Question that may need retry
notifier notify -t "Question" -m "Should I continue?" -q true
```

## Notification Channels

The notifier automatically routes based on user attention:

1. **Canvas Notification** - On-screen overlay (HAL 9000 icon)
   - Normal: Bottom-left, 5 seconds
   - High/Critical: Center screen with dimmed background

2. **macOS Notification Center** - Always sent for logging
   - Captured by Hammerspoon watcher
   - Logged to SQLite: `~/.local/share/hammerspoon/hammerspoon.db`

3. **Pushover** - Remote phone notification
   - Auto-sent on `critical` urgency
   - Or explicitly with `-P true`

4. **iMessage** - Direct to user's phone
   - Auto-sent on `critical` urgency
   - Or explicitly with `-p true`

## Urgency Guidelines

| Situation | Urgency | Why |
|-----------|---------|-----|
| Task completed successfully | `normal` | User will see canvas |
| Task completed with warnings | `high` | Draw more attention |
| Task failed/error | `critical` | Sends to phone too |
| Question needing answer | `high` | Centered, prominent |
| Security vulnerability found | `critical` | Always notify phone |
| Long task progress update | `normal` | Non-intrusive |

## When to Send Notifications

**DO send for:**
- Task completion (especially long-running)
- Errors requiring user attention
- Questions needing user input
- Significant milestones
- Security findings

**DON'T send for:**
- Minor steps completed
- Info user is actively watching
- Debugging output
- Redundant status updates

## Message Best Practices

1. **Titles:** Keep under 50 characters, be specific
2. **Messages:** Keep under 200 characters, include key details
3. **Include metrics:** "42 tests passed in 3.2s" not just "Tests passed"
4. **Be actionable:** "Check logs at /tmp/build.log" not just "Error occurred"

## Attention Detection

The notifier automatically detects if you're paying attention:
- Checks if terminal app is frontmost
- Checks current tmux session/window
- Checks display state (asleep/locked)

If user IS paying attention → subtle NC notification only
If user NOT paying attention → canvas overlay + NC + optional remote

## Examples

```bash
# Task completed
notifier notify -t "Build Complete" -m "42 tests passed, 0 failures in 3.2s"

# Error with high urgency
notifier notify -t "Build Failed" -m "3 type errors in src/auth.ts:45,78,123" -u high

# Critical security finding (auto-sends to phone)
notifier notify -t "Security Alert" -m "Found hardcoded API key in config.js" -u critical

# Question for user
notifier notify -t "Clarification Needed" -m "Should I refactor the auth module or just fix the bug?" -u high -q true
```

## Related Files

- `~/bin/notifier` - Main notification script
- `~/.dotfiles-nix/config/hammerspoon/lib/notifications/notifier.lua` - Canvas rendering
- `~/.dotfiles-nix/config/hammerspoon/watchers/notification.lua` - NC capture
- `~/.local/share/hammerspoon/hammerspoon.db` - Notification history

## Troubleshooting

If notifications aren't appearing:
1. Check Hammerspoon is running: `pgrep Hammerspoon`
2. Check hs CLI works: `hs -c "print('hello')"`
3. Verify permissions: System Settings → Notifications → Hammerspoon
