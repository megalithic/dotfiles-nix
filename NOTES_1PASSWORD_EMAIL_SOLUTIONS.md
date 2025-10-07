# 1Password CLI + Email (mbsync/aerc) Solutions

## Problem Statement
When aerc automatically checks mail using `mbsync`, it requires 1Password CLI authentication each time, causing frequent biometric (Touch ID) prompts.

## Investigation Results

### What We Found
1. **1Password desktop app is running** and CLI integration works correctly
2. **Manual `mbsync` works fine** - no authentication issues in interactive terminal
3. **Root cause**: 1Password's security model requires biometric authentication for CLI access, even when the desktop app is unlocked
4. **Missing system config**: `programs._1password.enable = true;` is commented out in darwin config

### Current Configuration
- **Account UUID**: `TWWGG4U545F7FGSETFXCMYECFE`
- **Current passwordCommand**: `op read op://Shared/Fastmail/apps/tui`
- **1Password CLI**: Installed via `home.packages` (`_1password-cli`)
- **Desktop app integration**: Socket exists at `~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock`

## Insights from mrjones2014/dotfiles (1Password Engineer)

From analyzing https://github.com/mrjones2014/dotfiles:

1. **System-level installation is critical**:
   ```nix
   # In darwin configuration (NOT home-manager)
   programs._1password.enable = true;
   programs._1password-gui.enable = true;
   ```

   The mrjones2014 config notes:
   > "This relies on `programs._1password.enable = true;` being set in OS config.
   > If we install `op` via `home.packages`, on Linux it will not be able to
   > connect to the 1Password desktop app. The NixOS module does some workarounds
   > to make sure this works."

2. **Enhanced passwordCommand pattern**:
   ```nix
   passwordCommand = "op read op://Shared/Fastmail/apps/tui --account TWWGG4U545F7FGSETFXCMYECFE";
   ```
   Adding `--account` flag may improve reliability.

3. **Shell plugin pattern** (for interactive tools):
   ```fish
   op plugin run -- gh $argv
   ```
   Not applicable for mbsync, but useful for other CLI tools.

4. **No email-specific solutions found**: The mrjones2014 repo doesn't contain mbsync or email configuration.

## Proposed Solutions (Ordered by Preference)

### Solution 1: Enable System-Level 1Password (Recommended First Try)

**Changes needed**:

In `/Users/seth/.dotfiles-nix/hosts/megabookpro.nix`:
```nix
# Uncomment this line (line 317):
programs._1password.enable = true;
```

In `/Users/seth/.dotfiles-nix/users/seth/home.nix`:
```nix
# Remove _1password-cli from home.packages (line 120)
# It will be provided by the system-level module
```

In `/Users/seth/.dotfiles-nix/users/seth/accounts.nix`:
```nix
# Update passwordCommand for all accounts:
passwordCommand = "op read op://Shared/Fastmail/apps/tui --account TWWGG4U545F7FGSETFXCMYECFE";
```

**Why this might help**: The nix-darwin module may handle app integration more smoothly than home-manager installation.

**Test after rebuilding**:
```bash
nh darwin switch .
aerc  # Test if automatic mail checking works without prompts
```

### Solution 2: Disable Automatic Mail Checking (Fallback - IMPLEMENTED)

**Changes needed**:

In `/Users/seth/.dotfiles-nix/users/seth/aerc.nix`:
```nix
# For all accounts (unified, gmail, fastmail, nibuild):
# Remove or comment out:
check-mail-cmd = "mbsync <account> && notmuch new";
check-mail = "2m";
check-mail-timout = "30s";
```

**Benefits**:
- No authentication prompts during aerc usage
- Check mail manually with `Ctrl-R` when needed
- Single authentication per session when you choose to check

**Trade-offs**:
- Must manually check mail (but this is often preferable to constant interruptions)

### Solution 3: Switch to `pass` with GPG

**Changes needed**:

1. Install and configure `pass`:
   ```nix
   # In home.nix
   home.packages = [ pkgs.pass ];
   programs.password-store.enable = true;
   programs.gpg.enable = true;
   ```

2. Migrate passwords:
   ```bash
   pass insert email/fastmail
   pass insert email/gmail
   pass insert email/nibuild
   ```

3. Update accounts.nix:
   ```nix
   passwordCommand = "pass show email/fastmail";
   ```

**Benefits**:
- GPG agent caches passphrase (configurable timeout)
- No biometric prompts after initial unlock
- Standard Unix password management

**Trade-offs**:
- Must migrate passwords from 1Password
- Manage GPG keys separately
- Less integration with 1Password ecosystem

### Solution 4: OAuth2 for Gmail

**Changes needed**:

For Gmail account only, configure OAuth2 in accounts.nix:
```nix
gmail = {
  # ... existing config ...
  mbsync = {
    enable = true;
    extraConfig = {
      account = {
        AuthMechs = "XOAUTH2";
        PassCmd = "oauth2token";  # Requires oauth2token script
      };
    };
  };
};
```

**Benefits**:
- No password prompts for Gmail
- More secure than app-specific passwords

**Trade-offs**:
- Only works for Gmail
- Requires OAuth2 token management setup
- More complex configuration

### Solution 5: Increase Check Interval

**Changes needed**:

In `/Users/seth/.dotfiles-nix/users/seth/aerc.nix`:
```nix
# Change from 2m to something longer:
check-mail = "15m";  # or "30m" or "1h"
```

**Benefits**:
- Fewer interruptions
- Still get automatic updates

**Trade-offs**:
- Less frequent mail updates
- Still get authentication prompts, just less often

## Additional Debugging

If issues persist after trying solutions above:

1. **Check 1Password CLI integration status**:
   ```bash
   op whoami
   op account list
   ```

2. **Test mbsync with verbose output**:
   ```bash
   mbsync -V fastmail 2>&1 | less
   ```

3. **Check 1Password app settings**:
   - Settings > Developer > "Integrate with 1Password CLI" (should be enabled)
   - Settings > Security > Touch ID (should be enabled)

4. **Monitor authentication attempts**:
   ```bash
   # Watch for auth prompts while aerc is running
   log stream --predicate 'process == "1Password"' --level debug
   ```

## Recommendation

**Try in this order**:
1. Solution 1 (Enable system-level 1Password) - Low effort, might solve it
2. Solution 2 (Disable auto-check) - Immediate fix, best UX for focused work
3. Solution 3 (Switch to pass) - If 1Password integration proves too difficult

Most users find Solution 2 (manual checking) provides the best balance of security and convenience.

## Implementation Status

- [ ] Solution 1: Enable system-level 1Password
- [x] Solution 2: Disable automatic mail checking (READY TO APPLY)
- [ ] Solution 3: Switch to pass
- [ ] Solution 4: OAuth2 for Gmail
- [ ] Solution 5: Increase check interval
