# Capacitor Plugins and Storage

## Table of Contents

- [Plugin Installation Pattern](#plugin-installation-pattern)
- [Official Plugin Overview](#official-plugin-overview)
- [Preferences API Reference](#preferences-api-reference)
- [SQLite Options](#sqlite-options)
- [Testing: Manual Mock Stubs](#testing-manual-mock-stubs)

---

## Plugin Installation Pattern

Every Capacitor plugin follows the same install flow:

```bash
npm install @capacitor/plugin-name
npx cap sync
```

`cap sync` is mandatory after any plugin install or update — it installs the native counterpart (Pod on iOS, Gradle dependency on Android) and copies web assets.

After sync, check the plugin README for any additional steps:

- **iOS** — entitlements in Xcode (e.g. Camera, Location, Push), `Info.plist` usage description strings
- **Android** — permissions in `AndroidManifest.xml`, Gradle properties

Skipping native configuration results in silent failures or crashes on device even when web previews work fine.

### Cordova Plugin Compatibility

Capacitor supports most Cordova plugins through a compatibility shim. Prefer Capacitor-native plugins when available. When using a Cordova plugin:

```bash
npm install cordova-plugin-name
npx cap sync
```

Some Cordova plugins require a `cordova.variables.gradle` or hook files — check the plugin README for exact steps.

---

## Official Plugin Overview

| Plugin | Package | Key Methods |
|---|---|---|
| App | `@capacitor/app` | `getInfo()`, `getState()`, `addListener('appUrlOpen')`, `addListener('backButton')` |
| Camera | `@capacitor/camera` | `getPhoto()`, `pickImages()` |
| Filesystem | `@capacitor/filesystem` | `readFile()`, `writeFile()`, `deleteFile()`, `mkdir()`, `readdir()` |
| Geolocation | `@capacitor/geolocation` | `getCurrentPosition()`, `watchPosition()` |
| Haptics | `@capacitor/haptics` | `impact()`, `notification()`, `vibrate()` |
| Keyboard | `@capacitor/keyboard` | `show()`, `hide()`, `addListener('keyboardWillShow')` |
| Network | `@capacitor/network` | `getStatus()`, `addListener('networkStatusChange')` |
| Preferences | `@capacitor/preferences` | `set()`, `get()`, `remove()`, `clear()`, `keys()` |
| Push Notifications | `@capacitor/push-notifications` | `register()`, `addListener('registration')`, `addListener('pushNotificationReceived')` |
| Share | `@capacitor/share` | `share()`, `canShare()` |
| Splash Screen | `@capacitor/splash-screen` | `hide()`, `show()` |
| Status Bar | `@capacitor/status-bar` | `setStyle()`, `setBackgroundColor()`, `show()`, `hide()` |

All official plugin APIs are fully typed with TypeScript definitions included in the package.

---

## Preferences API Reference

`@capacitor/preferences` is the recommended solution for small key/value persistence. Data is stored natively (iOS `UserDefaults` wrapped with a native layer; Android `SharedPreferences`) and survives low-storage eviction unlike `localStorage`.

### Installation

```bash
npm install @capacitor/preferences
npx cap sync
```

### Full API

```ts
import { Preferences } from '@capacitor/preferences';

// Set a value (value must be a string; serialize objects with JSON.stringify)
await Preferences.set({ key: 'user', value: JSON.stringify({ id: 42, name: 'Ada' }) });

// Get a value (returns { value: string | null })
const { value } = await Preferences.get({ key: 'user' });
const user = value ? JSON.parse(value) : null;

// Remove a single key
await Preferences.remove({ key: 'user' });

// Clear all keys for this app
await Preferences.clear();

// List all keys
const { keys } = await Preferences.keys();

// Use a named group (acts like a namespace / separate store)
await Preferences.configure({ group: 'MyApp' });
```

### Limitations

- Values must be strings. Serialize complex types with `JSON.stringify` / `JSON.parse`.
- Not designed for large datasets (> a few thousand records). Use SQLite for that.
- Not encrypted by default. For sensitive data, use a plugin backed by iOS Keychain or Android Keystore.

---

## SQLite Options

For relational data, full-text search, or high-volume reads/writes, use SQLite.

### Community SQLite plugin

```bash
npm install @capacitor-community/sqlite
npx cap sync
```

Basic usage:

```ts
import { CapacitorSQLite, SQLiteConnection } from '@capacitor-community/sqlite';

const sqlite = new SQLiteConnection(CapacitorSQLite);

const db = await sqlite.createConnection('mydb', false, 'no-encryption', 1, false);
await db.open();
await db.execute(`CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, name TEXT NOT NULL)`);
await db.run(`INSERT INTO users (name) VALUES (?)`, ['Ada']);
const result = await db.query(`SELECT * FROM users`);
console.log(result.values); // [{ id: 1, name: 'Ada' }]
await db.close();
```

Requires additional native configuration on iOS (add `SQLite.swift` via SPM) and Android (no extra steps). See the plugin README for full setup.

### Storage decision matrix

| Scenario | Solution |
|---|---|
| Feature flags, user prefs, small config | `@capacitor/preferences` |
| Cached API responses, offline data, relations | `@capacitor-community/sqlite` |
| Auth tokens (short-lived, in-memory only) | JS variable, never persisted |
| Encryption keys, long-lived tokens | iOS Keychain / Android Keystore plugin |
| Blobs, large files | `@capacitor/filesystem` |

---

## Testing: Manual Mock Stubs

Capacitor plugins are JavaScript `Proxy` objects. Standard mocking libraries that wrap objects in proxies fail silently or throw. Use manual mocks — plain objects that implement the same interface.

### Stub templates

**`__mocks__/@capacitor/preferences.ts`**

```ts
export const Preferences = {
  async configure(_options: { group: string }) {},
  async get(_data: { key: string }): Promise<{ value: string | null }> {
    return { value: null };
  },
  async set(_data: { key: string; value: string }): Promise<void> {},
  async remove(_data: { key: string }): Promise<void> {},
  async clear(): Promise<void> {},
  async keys(): Promise<{ keys: string[] }> {
    return { keys: [] };
  },
};
```

**`__mocks__/@capacitor/app.ts`**

```ts
export const App = {
  addListener: jest.fn(),
  removeAllListeners: jest.fn(),
  async getInfo() {
    return { id: 'com.example.test', name: 'Test', build: '1', version: '1.0.0' };
  },
  async getState() {
    return { isActive: true };
  },
};
```

**`__mocks__/@capacitor/network.ts`**

```ts
export const Network = {
  addListener: jest.fn(),
  removeAllListeners: jest.fn(),
  async getStatus() {
    return { connected: true, connectionType: 'wifi' };
  },
};
```

### Jest auto-discovery

Jest resolves imports from `__mocks__/` automatically when the path matches. No `jest.mock()` call required for the above structure.

### Jasmine / Angular path mapping

In `tsconfig.spec.json`, add (keeping all existing `paths` from `tsconfig.json`):

```json
{
  "compilerOptions": {
    "paths": {
      "@app/*": ["src/app/*"],
      "@capacitor/*": ["__mocks__/@capacitor/*"]
    }
  }
}
```

The `paths` key replaces the base config entirely — always carry forward existing entries.
