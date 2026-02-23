# Capacitor Security and Deep Links

## Table of Contents

- [Security Overview](#security-overview)
- [Data Security](#data-security)
- [Network Security](#network-security)
- [Content Security Policy](#content-security-policy)
- [WebView JavaScript Security](#webview-javascript-security)
- [Deep Links: Universal Links and App Links](#deep-links-universal-links-and-app-links)
- [iOS Universal Links Setup](#ios-universal-links-setup)
- [Android App Links Setup](#android-app-links-setup)
- [Framework-Specific Routing](#framework-specific-routing)
- [Hosting Site Association Files](#hosting-site-association-files)

---

## Security Overview

Capacitor apps run a web layer inside a native WebView. Security threats span both web and native surfaces. Audit four areas:

1. **Data** — what is persisted on device and how
2. **Auth / Deep Links** — how tokens flow during oAuth2 and URL-based navigation
3. **Network** — what endpoints are reachable and under what conditions
4. **WebView** — what resources the web layer can load and execute

---

## Data Security

### Never Embed Secrets in Code

The JavaScript bundle is part of the app binary and is extractable without a jailbreak/root. Secrets embedded in JS (API keys, encryption keys, signing tokens) are fully exposed. This includes values injected by build-time environment variable plugins — if the value ends up in the bundle, it is not secret.

Move secret-dependent operations to a server-side function or API. The app authenticates to the backend; the backend holds the secrets.

### Storing Sensitive Values on Device

When a secret must persist on device (auth token, encryption key), use native secure storage APIs:

| Platform | API | What it provides |
|---|---|---|
| iOS | Keychain Services | Hardware-backed encrypted storage, biometric unlock |
| Android | Keystore System | Hardware-backed key generation and storage |

Use a plugin that wraps these APIs directly. Do not store sensitive values in `@capacitor/preferences`, `localStorage`, or unencrypted SQLite.

For apps that do not require persistence across launches, keep tokens exclusively in memory (JS variables). Never write them to disk.

---

## Network Security

### Enforce HTTPS

All network requests must use `https://`. Never use `http://` in production. Sending credentials or tokens over `http://` transmits them in plain text.

On Android, HTTP cleartext traffic is blocked by default since Android 9. Do not enable `android:usesCleartextTraffic="true"` in production manifests — this was intended only for local development (live reload).

On iOS, App Transport Security (ATS) enforces HTTPS by default. Do not add global `NSAllowsArbitraryLoads` exceptions in production `Info.plist`.

### Certificate Pinning

For high-security apps, consider a plugin that supports certificate pinning to prevent MITM attacks even against compromised CA-issued certificates.

---

## Content Security Policy

Add a CSP `<meta>` tag to the `<head>` of `index.html`. The CSP restricts what resources the WebView can load, blocking XSS and data exfiltration.

### Restrictive starting template

```html
<meta
  http-equiv="Content-Security-Policy"
  content="
    default-src 'self';
    script-src 'self';
    style-src 'self' 'unsafe-inline';
    img-src 'self' data: blob:;
    connect-src 'self' https://api.example.com;
    font-src 'self';
    object-src 'none';
    frame-src 'none';
  "
/>
```

### Common directives

| Directive | Controls |
|---|---|
| `default-src` | Fallback for all unspecified resource types |
| `script-src` | JavaScript sources; avoid `'unsafe-eval'` and `'unsafe-inline'` |
| `connect-src` | XHR, fetch, WebSocket endpoints |
| `img-src` | Image sources; `data:` needed for base64, `blob:` for camera/canvas |
| `style-src` | CSS sources; `'unsafe-inline'` often required for CSS-in-JS frameworks |
| `object-src 'none'` | Disables Flash/plugins — always set this |

Start restrictive and widen only as needed. Use `report-uri` or `report-to` during development to catch violations without blocking.

---

## WebView JavaScript Security

Standard web security practices apply inside a Capacitor WebView:

- **Avoid `eval()`** — disabled by a strict `script-src` CSP
- **Sanitize user-generated content** before rendering as HTML to prevent stored/reflected XSS
- **Validate all input** on the server — the client-side validation is UX only
- **Do not trust `postMessage` data** without origin validation when using iframes or third-party scripts
- **Disable web inspector** access in production builds where possible (Android `setWebContentsDebuggingEnabled(false)` — this is the default for release builds)

---

## Deep Links: Universal Links and App Links

Universal Links (iOS) and App Links (Android) open the native app from a standard HTTPS URL. They require verified domain ownership, unlike custom URL schemes which any app can register.

### oAuth2 Redirect Security

Custom URL schemes (`myapp://callback`) can be hijacked. A malicious app registers the same scheme and intercepts the auth callback containing the authorization code or token.

Mitigation requirements:

1. Use Universal Links / App Links for oAuth2 redirect URIs where possible
2. Always use **PKCE** (Proof Key for Code Exchange) — even with Universal Links. PKCE ensures an intercepted authorization code is useless without the original `code_verifier`

PKCE flow summary:
- Generate a random `code_verifier`
- Hash it to `code_challenge` (SHA-256)
- Send `code_challenge` with the authorization request
- Send `code_verifier` with the token exchange request
- The server verifies they match — an intercepted code alone cannot be exchanged

---

## iOS Universal Links Setup

### Step 1: Configure App Identifier

In the Apple Developer portal, open the app's identifier under Certificates, Identifiers & Profiles. Enable **Associated Domains**. Note the Team ID and Bundle ID.

### Step 2: Create `apple-app-site-association`

Create the file with no file extension:

```json
{
  "applinks": {
    "details": [
      {
        "appIDs": ["TEAMID.BUNDLEID"],
        "components": [
          {
            "/": "/app/*",
            "comment": "Matches any URL whose path starts with /app/"
          },
          {
            "/": "/*",
            "comment": "Matches all URLs"
          }
        ]
      }
    ]
  }
}
```

Host at `https://yourdomain.com/.well-known/apple-app-site-association`.

Serve with `Content-Type: application/json`. The file must be reachable without redirects.

### Step 3: Add Associated Domains in Xcode

In the target's Signing & Capabilities tab, add the **Associated Domains** capability. Add an entry:

```
applinks:yourdomain.com
```

For staging/production parity, add both:

```
applinks:yourdomain.com
applinks:staging.yourdomain.com
```

Validate using Apple's [App Search API Validation Tool](https://search.developer.apple.com/appsearch-validation-tool/).

---

## Android App Links Setup

### Step 1: Generate SHA-256 Certificate Fingerprint

For a debug keystore:

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

For a release keystore:

```bash
keytool -list -v -keystore my-release-key.keystore
```

Copy the `SHA256` fingerprint from the output.

### Step 2: Create `assetlinks.json`

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.example.myapp",
      "sha256_cert_fingerprints": [
        "AB:CD:EF:12:34:56:78:90:..."
      ]
    }
  }
]
```

Host at `https://yourdomain.com/.well-known/assetlinks.json`.

Multiple fingerprints in the array cover both debug and release certificates:

```json
"sha256_cert_fingerprints": [
  "DEBUG_FINGERPRINT_HERE",
  "RELEASE_FINGERPRINT_HERE"
]
```

Validate using Google's [Statement List Generator and Tester](https://developers.google.com/digital-asset-links/tools/generator).

### Step 3: Add Intent Filter in `AndroidManifest.xml`

Inside the `<activity>` element for `MainActivity`:

```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https" android:host="yourdomain.com" />
</intent-filter>
```

`android:autoVerify="true"` causes Android to verify the `assetlinks.json` file at install time. If verification succeeds, the app opens links directly without prompting the user to choose a browser.

Full `MainActivity` entry example:

```xml
<activity
    android:configChanges="orientation|keyboardHidden|keyboard|screenSize|locale"
    android:name=".MainActivity"
    android:label="@string/title_activity_main"
    android:theme="@style/AppTheme.NoActionBarLaunch"
    android:launchMode="singleTask">

    <intent-filter>
        <action android:name="android.intent.action.MAIN" />
        <category android:name="android.intent.category.LAUNCHER" />
    </intent-filter>

    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="https" android:host="yourdomain.com" />
    </intent-filter>
</activity>
```

---

## Framework-Specific Routing

### Angular

In `app.component.ts`:

```ts
import { Component, NgZone } from '@angular/core';
import { Router } from '@angular/router';
import { App, URLOpenListenerEvent } from '@capacitor/app';

@Component({ selector: 'app-root', templateUrl: 'app.component.html' })
export class AppComponent {
  constructor(private router: Router, private zone: NgZone) {
    App.addListener('appUrlOpen', (event: URLOpenListenerEvent) => {
      this.zone.run(() => {
        // Extract path after the domain
        const url = new URL(event.url);
        if (url.pathname) {
          this.router.navigateByUrl(url.pathname + url.search);
        }
      });
    });
  }
}
```

### React

```tsx
// AppUrlListener.tsx
import { useEffect } from 'react';
import { useHistory } from 'react-router-dom';
import { App, URLOpenListenerEvent } from '@capacitor/app';

export function AppUrlListener() {
  const history = useHistory();

  useEffect(() => {
    const handle = App.addListener('appUrlOpen', (event: URLOpenListenerEvent) => {
      const url = new URL(event.url);
      if (url.pathname) {
        history.push(url.pathname + url.search);
      }
    });
    return () => { handle.then(h => h.remove()); };
  }, [history]);

  return null;
}
```

Mount inside your router component so `useHistory` is available.

### Vue

```ts
// In your router setup file
import { App, URLOpenListenerEvent } from '@capacitor/app';

App.addListener('appUrlOpen', (event: URLOpenListenerEvent) => {
  const url = new URL(event.url);
  if (url.pathname) {
    router.push(url.pathname + url.search);
  }
});
```

---

## Hosting Site Association Files

Files must be served over HTTPS with no redirects. Content-type requirements:

| File | Required Content-Type |
|---|---|
| `apple-app-site-association` | `application/json` |
| `assetlinks.json` | `application/json` |

### Deploying with common frameworks

**Angular** — place files in `src/.well-known/`, then add to `angular.json` under `architect.build.options.assets`:

```json
{
  "glob": "**/*",
  "input": "src/.well-known",
  "output": ".well-known/"
}
```

**React (CRA/Vite)** — place files in `public/.well-known/`. No extra config needed.

**Next.js** — place files in `public/.well-known/`. No extra config needed.

**Nuxt** — place files in `public/.well-known/` (Nuxt 3) or `static/.well-known/` (Nuxt 2).
