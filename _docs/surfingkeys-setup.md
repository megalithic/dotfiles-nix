# SurfingKeys Declarative Setup

## Current Status

✅ Configuration file exists: `users/seth/surfingkeys/config.js`
❌ Cannot auto-configure "Load settings from" URL declaratively
❌ Cannot auto-enable "Allow access to file URLs" permission

## Manual Setup Steps (One-Time)

1. **Open Helium** and navigate to: `helium://extensions/`

2. **Find SurfingKeys** extension and click "Details"

3. **Enable "Allow access to file URLs"** toggle

4. **Open SurfingKeys Settings**:
   - Right-click SurfingKeys icon → "Options"
   - OR: Navigate to `helium://extensions/?options=gfbliohnnapiefjpjlpjnehglfpaknnc`

5. **Configure "Load settings from"**:
   ```
   file:///Users/seth/.config/surfingkeys/config.js
   ```
   (Or if using a symlink from dotfiles:)
   ```
   file:///Users/seth/.dotfiles-nix/users/seth/surfingkeys/config.js
   ```

6. **Enable "Advanced Mode"** checkbox (for custom JavaScript)

7. **Click "Save"** or let it auto-save

## Alternative: HTTP Server Method

If file:// URLs are problematic, serve via HTTP:

```bash
# In your dotfiles directory
cd users/seth/surfingkeys
python3 -m http.server 9919
```

Then set "Load settings from": `http://localhost:9919/config.js`

## Why This Can't Be Fully Automated

1. **Browser Security**: Chrome/Chromium intentionally requires manual user consent for:
   - File system access
   - Extension permissions
   - Extension settings

2. **Extension Storage**: SurfingKeys stores its settings in:
   - `chrome.storage.local` (LevelDB binary format)
   - No API to pre-populate without extension code running

3. **No Managed Storage**: SurfingKeys doesn't implement `storage.managed_schema`,
   so enterprise policy configuration isn't supported

## What IS Automated

✅ Developer mode enabled (via our activation script)
✅ Extension installed from CRX
✅ Configuration file symlinked/managed
✅ "Allow User Scripts" permission granted

## Future Improvement Ideas

1. **Browser Automation**: Could potentially use Playwright/Puppeteer to automate
   the one-time setup steps

2. **Extension Fork**: Fork SurfingKeys to add `storage.managed_schema` support

3. **Different Extension**: Consider alternatives that support managed configuration
   (Vimium-C has better enterprise support)
