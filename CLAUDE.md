## General Workflow

- When working in this repo (dotfiles-nix), always check the `justfile` to see available commands
- To rebuild darwin in this repo, use `just mac` (which handles the darwin-rebuild process)
- Alternative: You can also use `nh`, so for a darwin-rebuild it'd be `nh darwin switch .`, and for home-manager, it'd be `nh home switch .`

## Hammerspoon

- **Reloading Hammerspoon**: Use `timeout` to prevent hanging, then verify via notification database:
  ```bash
  RELOAD_TIME=$(date +%s)
  timeout 2 hs -c "hs.reload()" 2>&1 || true
  sqlite3 ~/.local/share/hammerspoon/hammerspoon.db "SELECT timestamp FROM notifications WHERE sender = 'hammerspork' AND message = 'config is loaded.' AND timestamp >= $RELOAD_TIME LIMIT 1" && echo "✓ Reloaded"
  ```
  - `timeout` is required because hs.reload() destroys the Lua interpreter, causing the CLI command to hang
  - The timeout is expected and normal - reload succeeds even though the command times out
  - Notification database path: `~/.local/share/hammerspoon/hammerspoon.db`
  - Do NOT use sleep - check the database immediately after the timeout
- Check config.lua for paths to database, icons, and other resources
- When looking for paths to things for hammerspoon stuff, check config.lua first
- for any and all changes to hammerspoon, you must verify that there are NO workspace or document diagnostic errors before attempting to reload hammerspoon; that you always check online documentation and references (never assume); and that cpu and memory efficiency are of absolute importance (we can't have the operating system crash or become laggy because of hammerspoon scripts).

## Version Control with Jujutsu (jj)

**IMPORTANT**: All work must be tracked using jujutsu (jj) with clean, well-documented history.

### Core Workflow (Recommended)

1. **Start a unit of work**: Run `jj new -m "Brief description of task"` before starting work
2. **Work iteratively**: Make changes, test, iterate
3. **Document when complete**: Run `jj describe` and write a comprehensive description including:
   - What was changed and why
   - Key implementation details
   - Any breaking changes or important notes
   - Related context (e.g., "Fixes notification system regression on macOS Sequoia")
4. **Next task**: Run `jj new` to start fresh change on top of current work

### Key Commands

- `jj status` - Show working copy changes
- `jj log` - View change history
- `jj new -m "message"` - Create new change (starts fresh unit of work)
- `jj describe` - Document current change with detailed message
- `jj squash` - Merge current change into parent (for cleaning up)
- `jj split` - Split current change into multiple changes (for organizing)
- `jj abandon` - Discard current change if work is unwanted
- `jj op log` - View operation history (undo/recovery)
- `jj op restore <id>` - Restore to previous state

### Benefits for AI-Assisted Development

- **Automatic snapshots**: Jj automatically captures working copy state
- **Safe experimentation**: Easy to abandon or squash messy changes
- **Clean history**: Use describe/squash/split to curate clean commits afterward
- **Never lose work**: Operation log (`jj op log`) tracks everything
- **Mutable changes**: Can edit any change, automatic rebasing of descendants

### Parallel Work (Advanced)

For working on multiple features simultaneously:
```bash
# Create separate changes off main
jj new main -m "Feature A"  # Creates change abc123
jj new main -m "Feature B"  # Creates change def456

# Switch between them
jj edit abc123  # Work on Feature A
jj edit def456  # Work on Feature B
```

### Current State

This repo is already jj-initialized with git coexistence. Always check `jj status` before starting work to see current state.
- when creating shell scripts that take arguments, always assume we want long and short form arguments supported.