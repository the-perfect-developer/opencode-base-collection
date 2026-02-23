---
name: capacitor
description: This skill should be used when the user asks to "build a Capacitor app", "add Capacitor to a web project", "use Capacitor plugins", "configure Capacitor for iOS or Android", or needs guidance on Capacitor best practices, security, storage, deep links, or the development workflow.
---

# Capacitor: Cross-Platform Native Runtime

Capacitor is a cross-platform native runtime for building Web Native apps that run on iOS, Android, and the web from a single modern web codebase. It provides a consistent, web-focused API layer that bridges JavaScript to native device features via a plugin system.

## Core Workflow

The canonical development loop is:

1. **Build web assets**: `npm run build` (or `ng build`, `vite build`, etc.)
2. **Sync to native projects**: `npx cap sync`
   - Copies the web bundle into iOS and Android native projects
   - Installs/updates native plugin dependencies
   - Run this after every web build or plugin change
3. **Test on device**:
   ```bash
   npx cap run ios
   npx cap run android
   ```
4. **Open native IDE** when native changes are needed:
   ```bash
   npx cap open ios      # opens Xcode
   npx cap open android  # opens Android Studio
   ```
5. **Build a release binary**:
   ```bash
   npx cap build android  # outputs signed AAB/APK
   npx cap build ios      # outputs IPA
   ```

Keep `@capacitor/core`, `@capacitor/ios`, and `@capacitor/android` on identical versions at all times. Update all together:

```bash
npm i @capacitor/core @capacitor/ios @capacitor/android
npm i -D @capacitor/cli
```

## Configuration

Capacitor-level settings live in `capacitor.config.ts` (or `.json`). This file controls tooling only — not native runtime behavior. Key fields:

| Field | Purpose |
|---|---|
| `appId` | Bundle identifier (e.g. `com.example.app`) |
| `appName` | Display name |
| `webDir` | Output directory of the web build (e.g. `dist`, `build`, `www`) |
| `server.url` | Override for live reload (remove before committing) |

Platform-specific runtime configuration is done in native IDEs: `ios/App/App/Info.plist` and `AndroidManifest.xml` for Android. Do not attempt to manage those via the Capacitor config file.

## Plugins

Capacitor plugins expose native APIs to JavaScript. Three sources exist:

- **Official plugins** (`@capacitor/*`) — maintained by the Capacitor team, covering Camera, Filesystem, Geolocation, Push Notifications, Preferences, etc.
- **Community plugins** (`@capacitor-community/*`) — curated third-party ecosystem
- **Cordova plugins** — compatibility layer; prefer Capacitor-native equivalents

Install a plugin, then sync:

```bash
npm install @capacitor/camera
npx cap sync
```

Always check whether a plugin requires additional native configuration (entitlements on iOS, permissions in `AndroidManifest.xml`). The plugin's README will specify.

### Mocking Plugins in Tests

Capacitor plugins are JavaScript proxies; wrapping a proxy in another proxy fails. Use **manual mocks** instead.

**Jest** — place stubs under `__mocks__/@capacitor/`:

```ts
// __mocks__/@capacitor/preferences.ts
export const Preferences = {
  async get(data: { key: string }) { return { value: undefined }; },
  async set(_data: { key: string; value: string }) {},
  async remove(_data: { key: string }) {},
  async clear() {},
};
```

Jest auto-discovers files from `__mocks__/` before `node_modules`.

**Jasmine/Angular** — add a `paths` mapping in `tsconfig.spec.json`:

```json
"paths": {
  "@capacitor/*": ["__mocks__/@capacitor/*"]
}
```

Note: `paths` in `tsconfig.spec.json` replaces (does not merge with) the base `tsconfig.json` paths — include all existing entries.

## Storage

Do not rely on `localStorage` or `IndexedDB` as primary storage on mobile. The OS reclaims both when storage is low. IndexedDB on iOS is not persisted by default.

| Use case | Recommended solution |
|---|---|
| Small key/value data (settings, tokens) | `@capacitor/preferences` |
| Large datasets / SQL queries | SQLite plugin (`capacitor-sqlite`) |
| Sensitive values (encryption keys, auth tokens) | iOS Keychain / Android Keystore via a plugin |

```ts
import { Preferences } from '@capacitor/preferences';

// Write
await Preferences.set({ key: 'theme', value: 'dark' });

// Read
const { value } = await Preferences.get({ key: 'theme' });

// Remove
await Preferences.remove({ key: 'theme' });
```

`Preferences` values are stored natively and survive app updates and low-storage eviction.

## Security

### Secrets and API Keys

Never embed secrets in web app code. The JavaScript bundle ships inside the app binary and is trivially extractable. Move secret-dependent logic server-side (serverless function or backend API). If a token must exist on device (e.g. auth token), store it only in memory or in the native Keychain/Keystore — never in `localStorage` or `Preferences` unencrypted.

### Network

Only make requests to `https://` endpoints. Never use `http://` in production builds.

### Content Security Policy

Add a CSP `<meta>` tag in `index.html` to restrict resource loading:

```html
<meta
  http-equiv="Content-Security-Policy"
  content="default-src 'self'; connect-src 'self' https://api.example.com"
/>
```

### oAuth2 / Deep Link Authentication

Custom URL schemes (e.g. `myapp://`) are not domain-controlled and can be intercepted by a malicious app. Never pass sensitive tokens through a custom scheme. Use **Universal Links** (iOS) or **App Links** (Android) for auth callbacks, and always enable **PKCE** in oAuth2 flows.

## Deep Links (Universal Links / App Links)

Deep links allow HTTPS URLs to open specific screens inside the native app. Prefer Universal/App Links over custom URL schemes — they require verified web domain ownership.

### Listen for Incoming Links

Register the listener early (e.g. app bootstrap):

```ts
import { App } from '@capacitor/app';

App.addListener('appUrlOpen', (event) => {
  const path = new URL(event.url).pathname;
  // hand off to your router
  router.navigate(path);
});
```

### Required Setup (both platforms)

1. Host a site association file at `https://yourdomain.com/.well-known/`:
   - iOS: `apple-app-site-association` (no extension, JSON)
   - Android: `assetlinks.json`
2. Configure the native app:
   - iOS: enable Associated Domains in Xcode (`applinks:yourdomain.com`)
   - Android: add `intent-filter` with `android:autoVerify="true"` in `AndroidManifest.xml`

See `references/security-and-deeplinks.md` for complete file formats and intent filter XML.

## Live Reload (Development Only)

Live reload reloads the WebView when web source files change — no native rebuild required.

**With Ionic CLI (recommended):**

```bash
npm install -g @ionic/cli native-run
ionic cap run ios -l --external
ionic cap run android -l --external
```

**Without Ionic CLI** — add a `server` entry to `capacitor.config.json`:

```json
"server": {
  "url": "http://192.168.1.68:8100",
  "cleartext": true
}
```

Run `npx cap copy` to push the config update, then launch from the native IDE.

**Never commit the `server` config to source control.** Remove it before building for release.

## Quick Reference

| Task | Command |
|---|---|
| Sync web build to native | `npx cap sync` |
| Copy web assets only | `npx cap copy` |
| Open iOS project | `npx cap open ios` |
| Open Android project | `npx cap open android` |
| Run on device | `npx cap run ios` / `npx cap run android` |
| Build release binary | `npx cap build ios` / `npx cap build android` |
| Update Capacitor | `npm i @capacitor/core @capacitor/ios @capacitor/android` |

## Additional Resources

- **`references/plugins-and-storage.md`** — Plugin installation patterns, Preferences API reference, SQLite options, and testing stubs in detail
- **`references/security-and-deeplinks.md`** — CSP patterns, Keychain/Keystore guidance, full Universal Links / App Links file formats, PKCE requirements
