# Notifier Script - Comprehensive Knowledge Document

> **Last Updated:** 2025-12-11
> **Location:** `~/bin/notifier` (symlinked from `~/.dotfiles-nix/bin/notifier`)
> **Status:** Fully functional with dual notification path (canvas + NC logging)

## Executive Summary

The notifier script is a smart multi-channel notification system designed for AI agents (Claude Code, etc.) to communicate with the user. It intelligently routes notifications based on:

1. **User attention state** - Is the user looking at this terminal session?
2. **Display state** - Is the screen on/off/locked?
3. **Urgency level** - normal, high, or critical
4. **Explicit channel requests** - Phone, Pushover, etc.

---

## Architecture Overview

```
                              ┌─────────────────────────┐
                              │   notifier notify ...   │
                              │    (CLI Entry Point)    │
                              └───────────┬─────────────┘
                                          │
                              ┌───────────▼─────────────┐
                              │   Attention Detection   │
                              │  should_send_notification()
                              └───────────┬─────────────┘
                                          │
                    ┌─────────────────────┼─────────────────────┐
                    │                     │                     │
           User NOT Paying         Display Asleep        User IS Paying
              Attention                                    Attention
                    │                     │                     │
                    ▼                     ▼                     ▼
    ┌───────────────────────┐  ┌─────────────────┐  ┌───────────────────┐
    │  send_canvas_notification│  Remote Only:   │  │send_macos_notification│
    │  send_macos_notification │  - Pushover     │  │   (subtle NC only)  │
    │  (+ optional remote)     │  - iMessage     │  └───────────────────┘
    └───────────────────────┘  └─────────────────┘
                    │
                    ▼
    ┌─────────────────────────────────────────────────────────┐
    │                   Hammerspoon Integration                │
    │  lib/notifications/notifier.lua                         │
    │  - sendCanvasNotification() → Custom overlay            │
    │  - sendMacOSNotification()  → hs.notify → NC → Watcher  │
    │  - sendPhoneNotification()  → hs.messages.iMessage      │
    └─────────────────────────────────────────────────────────┘
                    │
                    ▼
    ┌─────────────────────────────────────────────────────────┐
    │              Notification Watcher (AX Observer)          │
    │  watchers/notification.lua                               │
    │  - Captures NC notifications                             │
    │  - Logs to SQLite database                               │
    │  - Path: ~/.local/share/hammerspoon/hammerspoon.db      │
    └─────────────────────────────────────────────────────────┘
```

---

## CLI Interface

### Basic Usage

```bash
# IMPORTANT: The 'notify' subcommand is REQUIRED
notifier notify -t "Title" -m "Message"

# Common mistake - this does NOT work:
notifier --title "Title"  # WRONG - missing 'notify' subcommand
```

### Options

| Short | Long | Description | Default |
|-------|------|-------------|---------|
| `-t` | `--title` | Notification title (required) | - |
| `-m` | `--message` | Notification message (required) | - |
| `-u` | `--urgency` | Urgency level: `normal`, `high`, `critical` | `normal` |
| `-p` | `--phone` | Send to phone via iMessage: `true`/`false` | `false` |
| `-P` | `--pushover` | Send via Pushover: `true`/`false` | `false` |
| `-q` | `--question` | Mark as question for retry logic: `true`/`false` | `false` |

### Input Formats

```bash
# Short options
notifier notify -t "Title" -m "Message" -u high

# Long options
notifier notify --title "Title" --message "Message" --urgency high

# Long options with = syntax
notifier notify --title="Title" --message="Message" --urgency=high

# JSON input
notifier notify '{"title":"Title","message":"Message","urgency":"high"}'

# Positional arguments (legacy, backward compatible)
notifier notify "Title" "Message" false normal
```

---

## Notification Channels

### 1. Canvas Notification (Primary Visual)

**When:** User not paying attention OR urgency is critical
**What:** Custom Hammerspoon canvas overlay with HAL 9000 icon
**Where:**
- High/Critical: Center of screen with dimmed background
- Normal: Bottom-left corner

**Implementation:** `send_canvas_notification()` → `notify.sendCanvasNotification()`

### 2. macOS Notification Center (Logging)

**When:** Always (both attention states)
**What:** Native macOS notification via `hs.notify`
**Purpose:**
- Gets captured by AX watcher
- Logged to SQLite database for history
- Provides native NC integration

**Implementation:** `send_macos_notification()` → `notify.sendMacOSNotification()` → `hs.notify.show()`

### 3. Pushover (Remote/Phone)

**When:** Explicitly requested (`-P true`) OR urgency is critical
**What:** Push notification to Pushover app on phone
**Requirements:**
- 1Password CLI (`op`) for token retrieval
- Pushover tokens in 1Password vault

**Priority Mapping:**
| Urgency | Pushover Priority |
|---------|-------------------|
| critical | 1 (high) |
| high | 1 (high) |
| normal | 0 (normal) |
| low | -1 (low) |

**Implementation:** `send_pushover_notification()` → Pushover API via curl

### 4. iMessage (Phone)

**When:** Explicitly requested (`-p true`) OR urgency is critical
**What:** iMessage to user's phone number
**Requirements:**
- macOS Contacts with user's phone number
- Messages.app configured

**Implementation:** `send_phone_notification()` → `notify.sendPhoneNotification()` → `hs.messages.iMessage()`

---

## Attention Detection

### How It Works

The script determines if the user is "paying attention" to the specific terminal session:

```bash
should_send_notification()
  │
  ├─ Is terminal app frontmost?
  │    └─ NO → User not paying attention (send notification)
  │
  ├─ Is display idle/asleep?
  │    └─ YES → User not paying attention (send notification)
  │
  └─ Is user viewing THIS specific tmux session/window?
       ├─ YES → User IS paying attention (suppress notification)
       └─ NO → User not paying attention (send notification)
```

### Session Context

The script identifies the calling context:
- **In tmux:** `session:window` format (e.g., `main:claude`)
- **Outside tmux:** TTY name (e.g., `ttys001`)

This allows per-session notification suppression - if you're in a different tmux window, you'll still get notified.

### Display State Detection

Uses Hammerspoon to check:
- `display_asleep` - Screen is off
- `screen_locked` - Lock screen active
- `logged_out` - User logged out

When display is asleep, ONLY remote notifications are sent (no visual).

---

## Urgency Levels

### Normal (default)
- Duration: 5 seconds
- Position: Bottom-left corner
- Dimming: None
- Remote: Only if explicitly requested

### High
- Duration: 10 seconds
- Position: Center of screen
- Dimming: Background dimmed (60% alpha)
- Remote: Only if explicitly requested

### Critical
- Duration: 15 seconds
- Position: Center of screen
- Dimming: Background dimmed (60% alpha)
- Remote: **Always** sends to phone AND Pushover

---

## Question Retry System

For important questions that need answers:

```bash
notifier notify -t "Question" -m "Should I continue?" -q true
```

**Behavior:**
1. Creates tracking file in `$TMPDIR/notifier_state/question_<md5>`
2. If unanswered after 5 minutes, retries with escalation:
   - Adds "REMINDER:" prefix
   - Sends to phone
   - 15-second alert duration
3. Call `answer_question "Title" "Message"` to clear

**Retry Daemon:**
```bash
# Start background retry checker
notifier start-retry-daemon

# Stop it
notifier stop-retry-daemon
```

---

## Hammerspoon Integration

### Required Modules

The notifier relies on these Hammerspoon modules:

| Module | Purpose |
|--------|---------|
| `lib/notifications/notifier.lua` | Core notification functions |
| `lib/notifications/init.lua` | System initialization |
| `watchers/notification.lua` | AX observer for NC capture |

### Global Dependencies

The notifier expects these Hammerspoon globals:
- `TERMINAL` - Terminal bundle ID (default: `com.mitchellh.ghostty`)

### Lua Functions Called

```lua
-- Canvas notification with custom styling
notify.sendCanvasNotification(title, msg, duration, config)

-- Native macOS notification (for logging)
notify.sendMacOSNotification(title, subtitle, body)

-- iMessage to phone
notify.sendPhoneNotification(phoneNumber, message)

-- Display state check
notify.checkDisplayState()

-- Window title for attention detection
notify.getFocusedWindowTitle(bundleId)
```

---

## Database Logging

All notifications sent through macOS NC are captured by the watcher and logged to SQLite.

**Location:** `~/.local/share/hammerspoon/hammerspoon.db`

**Schema:**
```sql
CREATE TABLE notifications (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  timestamp INTEGER,
  rule_name TEXT,
  app_id TEXT,      -- Full stackingID
  sender TEXT,      -- Notification title
  subtitle TEXT,
  message TEXT,
  action_taken TEXT, -- shown_center_dimmed, shown_bottom_left, blocked_by_focus, etc.
  focus_mode TEXT,
  shown INTEGER     -- 0 or 1
);
```

**Query Recent:**
```bash
sqlite3 ~/.local/share/hammerspoon/hammerspoon.db \
  "SELECT datetime(timestamp, 'unixepoch', 'localtime'), sender, message
   FROM notifications ORDER BY timestamp DESC LIMIT 10"
```

---

## Caching System

Phone number and contact info are cached to avoid repeated Contacts lookups:

**Cache Location:** `~/.cache/notifier/contact_info.cache`
**Default TTL:** 7 days (604800 seconds)
**Override:** `AI_NOTIFY_CACHE_TTL` environment variable

**Cache Format:**
```
KEY=timestamp|value
PHONE_NUMBER=1733900000|+1234567890
FULL_NAME=1733900000|Seth Messer
```

---

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `TERMINAL_BUNDLE_ID` | Bundle ID of terminal app | `com.mitchellh.ghostty` |
| `AI_NOTIFY_CACHE_TTL` | Cache TTL in seconds | `604800` (7 days) |
| `TMPDIR` | Temp directory for state files | System default |
| `XDG_CACHE_HOME` | Cache directory base | `~/.cache` |

---

## Best Practices for AI Agents

### When to Send Notifications

**DO send notifications for:**
- Task completion (especially long-running tasks)
- Errors requiring user attention
- Questions that need user input
- Significant milestones in multi-step tasks
- Security-related findings

**DON'T send notifications for:**
- Every minor step completed
- Information the user is actively watching
- Debugging output
- Redundant status updates

### Urgency Guidelines

| Situation | Urgency | Pushover |
|-----------|---------|----------|
| Task completed successfully | `normal` | `false` |
| Task completed with warnings | `high` | `false` |
| Task failed | `critical` | `true` (auto) |
| Question needing answer | `high` | `false` |
| Security vulnerability found | `critical` | `true` (auto) |
| Long task progress update | `normal` | `false` |

### Message Guidelines

1. **Titles:** Keep under 50 characters, be specific
2. **Messages:** Keep under 200 characters, include key details
3. **Include metrics:** "42 tests passed in 3.2s" not just "Tests passed"
4. **Be actionable:** "Check logs at /tmp/build.log" not just "Error occurred"

---

## Troubleshooting

### Notification Not Appearing

1. **Check Hammerspoon is running:**
   ```bash
   pgrep Hammerspoon
   ```

2. **Check hs CLI works:**
   ```bash
   hs -c "print('hello')"
   ```

3. **Check notification permissions:**
   System Settings → Notifications → Hammerspoon → Allow Notifications

### Pushover Not Working

1. **Check 1Password CLI:**
   ```bash
   op whoami
   ```

2. **Verify tokens exist:**
   ```bash
   op read "op://Shared/bjdr5wcxdv6eeq3yylc25vvofy/PUSHOVER_USER_TOKEN"
   ```

### Database Not Logging

1. **Check watcher is running:**
   ```bash
   echo "require('watchers.notification').observer ~= nil" | hs -A
   ```

2. **Check database path:**
   ```bash
   ls -la ~/.local/share/hammerspoon/hammerspoon.db
   ```

---

## Related Files

| File | Purpose |
|------|---------|
| `~/bin/notifier` | Main script (this document) |
| `~/.dotfiles-nix/config/hammerspoon/lib/notifications/notifier.lua` | Hammerspoon notification module |
| `~/.dotfiles-nix/config/hammerspoon/watchers/notification.lua` | AX observer for NC capture |
| `~/.dotfiles-nix/config/hammerspoon/config.lua` | Notification rules in `C.notifier.rules` |
| `~/.local/share/hammerspoon/hammerspoon.db` | SQLite notification history |
| `~/.cache/notifier/contact_info.cache` | Phone number cache |

---

## Version History

| Date | Change |
|------|--------|
| 2025-12-11 | Added dual notification path (canvas + NC logging) |
| 2025-12-11 | Fixed macOS Sequoia AX structure in watcher |
| 2025-11-10 | Added Pushover integration |
| 2025-10-XX | Initial implementation with attention detection |
