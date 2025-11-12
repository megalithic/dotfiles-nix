## General Workflow

- When working in this repo (dotfiles-nix), always check the `justfile` to see available commands
- To rebuild darwin in this repo, use `just mac` (which handles the darwin-rebuild process)
- Alternative: You can also use `nh`, so for a darwin-rebuild it'd be `nh darwin switch .`, and for home-manager, it'd be `nh home switch .`

## Hammerspoon

- you don't need to call   Bash(hs -c "hs.reload()" 2>&1; sleep 2 && echo "✓ Reloaded - debug logging removed") to reload hammerspoon, rather, you don't have to sleep and echo anything; just call the reload, and then check that hammerspoon left a notification center entry in the notifications db for something like "hammerspork"
- check config.lua for locations of certain things, like the database
- when reloading hammerspoon, always just call to reload it, then check the notifications db for "reloaded" messages.
- when looking for paths to things for hammerspoon stuff, check config.lua first
- dont' sleep after an hs.reload; you only need to check to make sure the reloaded notification was stored; if it was, then it was reloaded or at the very least check for the ai agent notification was just in the console
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