# Framework-Specific Setup Guide

Detailed installation instructions for integrating Tailwind CSS with popular web frameworks.

## Table of Contents

- [Next.js](#nextjs)
- [Laravel](#laravel)
- [SvelteKit](#sveltekit)
- [Nuxt](#nuxt)
- [React (Vite)](#react-vite)
- [Vue (Vite)](#vue-vite)
- [Angular](#angular)
- [Astro](#astro)
- [Remix](#remix)
- [SolidJS](#solidjs)

## Next.js

Next.js 15+ with App Router supports Tailwind CSS v4 through Vite integration.

### Installation Steps

1. **Install dependencies**:
   ```bash
   npm install tailwindcss @tailwindcss/vite
   ```

2. **Configure Next.js** to use Vite in `next.config.ts`:
   ```typescript
   import type { NextConfig } from 'next'
   import tailwindcss from '@tailwindcss/vite'

   const nextConfig: NextConfig = {
     experimental: {
       turbo: {
         unstable_vite: true,
       },
     },
     vite: {
       plugins: [tailwindcss()],
     },
   }

   export default nextConfig
   ```

3. **Import Tailwind** in global CSS (`app/globals.css`):
   ```css
   @import "tailwindcss";
   ```

4. **Import CSS** in root layout (`app/layout.tsx`):
   ```typescript
   import './globals.css'

   export default function RootLayout({
     children,
   }: {
     children: React.ReactNode
   }) {
     return (
       <html lang="en">
         <body>{children}</body>
       </html>
     )
   }
   ```

5. **Start development**:
   ```bash
   npm run dev
   ```

### Using with Pages Router

For Next.js Pages Router, import CSS in `_app.tsx`:

```typescript
import '@/styles/globals.css'
import type { AppProps } from 'next/app'

export default function App({ Component, pageProps }: AppProps) {
  return <Component {...pageProps} />
}
```

## Laravel

Laravel uses Vite as the default build tool, making Tailwind integration straightforward.

### Installation Steps

1. **Install dependencies**:
   ```bash
   npm install tailwindcss @tailwindcss/vite
   ```

2. **Configure Vite** in `vite.config.js`:
   ```javascript
   import { defineConfig } from 'vite'
   import laravel from 'laravel-vite-plugin'
   import tailwindcss from '@tailwindcss/vite'

   export default defineConfig({
     plugins: [
       laravel({
         input: ['resources/css/app.css', 'resources/js/app.js'],
         refresh: true,
       }),
       tailwindcss(),
     ],
   })
   ```

3. **Import Tailwind** in `resources/css/app.css`:
   ```css
   @import "tailwindcss";
   ```

4. **Include Vite directives** in Blade template:
   ```blade
   <!DOCTYPE html>
   <html>
     <head>
       <meta charset="utf-8">
       <meta name="viewport" content="width=device-width, initial-scale=1">
       @vite(['resources/css/app.css', 'resources/js/app.js'])
     </head>
     <body>
       @yield('content')
     </body>
   </html>
   ```

5. **Start development**:
   ```bash
   npm run dev
   ```

## SvelteKit

SvelteKit uses Vite natively, making Tailwind integration seamless.

### Installation Steps

1. **Install dependencies**:
   ```bash
   npm install tailwindcss @tailwindcss/vite
   ```

2. **Configure Vite** in `vite.config.ts`:
   ```typescript
   import { sveltekit } from '@sveltejs/kit/vite'
   import tailwindcss from '@tailwindcss/vite'
   import { defineConfig } from 'vite'

   export default defineConfig({
     plugins: [sveltekit(), tailwindcss()],
   })
   ```

3. **Import Tailwind** in `src/app.css`:
   ```css
   @import "tailwindcss";
   ```

4. **Import CSS** in root layout (`src/routes/+layout.svelte`):
   ```svelte
   <script>
     import '../app.css'
   </script>

   <slot />
   ```

5. **Start development**:
   ```bash
   npm run dev
   ```

## Nuxt

Nuxt 3 uses Vite and integrates easily with Tailwind CSS.

### Installation Steps

1. **Install dependencies**:
   ```bash
   npm install tailwindcss @tailwindcss/vite
   ```

2. **Configure Nuxt** in `nuxt.config.ts`:
   ```typescript
   import tailwindcss from '@tailwindcss/vite'

   export default defineNuxtConfig({
     vite: {
       plugins: [tailwindcss()],
     },
     css: ['~/assets/css/main.css'],
   })
   ```

3. **Create CSS file** at `assets/css/main.css`:
   ```css
   @import "tailwindcss";
   ```

4. **Start development**:
   ```bash
   npm run dev
   ```

## React (Vite)

Standard React application created with Vite.

### Installation Steps

1. **Create React app** (if starting fresh):
   ```bash
   npm create vite@latest my-app -- --template react-ts
   cd my-app
   ```

2. **Install Tailwind**:
   ```bash
   npm install tailwindcss @tailwindcss/vite
   ```

3. **Configure Vite** in `vite.config.ts`:
   ```typescript
   import { defineConfig } from 'vite'
   import react from '@vitejs/plugin-react'
   import tailwindcss from '@tailwindcss/vite'

   export default defineConfig({
     plugins: [react(), tailwindcss()],
   })
   ```

4. **Import Tailwind** in `src/index.css`:
   ```css
   @import "tailwindcss";
   ```

5. **Import CSS** in `src/main.tsx`:
   ```typescript
   import React from 'react'
   import ReactDOM from 'react-dom/client'
   import App from './App.tsx'
   import './index.css'

   ReactDOM.createRoot(document.getElementById('root')!).render(
     <React.StrictMode>
       <App />
     </React.StrictMode>,
   )
   ```

6. **Start development**:
   ```bash
   npm run dev
   ```

## Vue (Vite)

Vue 3 application with Vite.

### Installation Steps

1. **Create Vue app** (if starting fresh):
   ```bash
   npm create vite@latest my-app -- --template vue-ts
   cd my-app
   ```

2. **Install Tailwind**:
   ```bash
   npm install tailwindcss @tailwindcss/vite
   ```

3. **Configure Vite** in `vite.config.ts`:
   ```typescript
   import { defineConfig } from 'vite'
   import vue from '@vitejs/plugin-vue'
   import tailwindcss from '@tailwindcss/vite'

   export default defineConfig({
     plugins: [vue(), tailwindcss()],
   })
   ```

4. **Import Tailwind** in `src/style.css`:
   ```css
   @import "tailwindcss";
   ```

5. **Import CSS** in `src/main.ts`:
   ```typescript
   import { createApp } from 'vue'
   import './style.css'
   import App from './App.vue'

   createApp(App).mount('#app')
   ```

6. **Start development**:
   ```bash
   npm run dev
   ```

## Angular

Angular requires custom builder configuration for Tailwind CSS.

### Installation Steps

1. **Install dependencies**:
   ```bash
   npm install tailwindcss @tailwindcss/postcss postcss
   ```

2. **Configure PostCSS** in `postcss.config.js`:
   ```javascript
   module.exports = {
     plugins: {
       '@tailwindcss/postcss': {}
     }
   }
   ```

3. **Import Tailwind** in `src/styles.css`:
   ```css
   @import "tailwindcss";
   ```

4. **Update Angular config** in `angular.json` to include PostCSS:
   ```json
   {
     "projects": {
       "your-app": {
         "architect": {
           "build": {
             "options": {
               "styles": ["src/styles.css"],
               "stylePreprocessorOptions": {
                 "includePaths": ["node_modules"]
               }
             }
           }
         }
       }
     }
   }
   ```

5. **Start development**:
   ```bash
   ng serve
   ```

## Astro

Astro supports Tailwind through Vite integration.

### Installation Steps

1. **Install dependencies**:
   ```bash
   npm install tailwindcss @tailwindcss/vite
   ```

2. **Configure Astro** in `astro.config.mjs`:
   ```javascript
   import { defineConfig } from 'astro/config'
   import tailwindcss from '@tailwindcss/vite'

   export default defineConfig({
     vite: {
       plugins: [tailwindcss()],
     },
   })
   ```

3. **Create CSS file** at `src/styles/global.css`:
   ```css
   @import "tailwindcss";
   ```

4. **Import CSS** in layout component:
   ```astro
   ---
   import '../styles/global.css'
   ---
   <html>
     <head>
       <meta charset="utf-8" />
       <meta name="viewport" content="width=device-width" />
     </head>
     <body>
       <slot />
     </body>
   </html>
   ```

5. **Start development**:
   ```bash
   npm run dev
   ```

## Remix

Remix supports Tailwind through Vite (Remix v2+).

### Installation Steps

1. **Install dependencies**:
   ```bash
   npm install tailwindcss @tailwindcss/vite
   ```

2. **Configure Vite** in `vite.config.ts`:
   ```typescript
   import { vitePlugin as remix } from '@remix-run/dev'
   import tailwindcss from '@tailwindcss/vite'
   import { defineConfig } from 'vite'

   export default defineConfig({
     plugins: [remix(), tailwindcss()],
   })
   ```

3. **Import Tailwind** in `app/tailwind.css`:
   ```css
   @import "tailwindcss";
   ```

4. **Import CSS** in root (`app/root.tsx`):
   ```typescript
   import type { LinksFunction } from '@remix-run/node'
   import stylesheet from '~/tailwind.css?url'

   export const links: LinksFunction = () => [
     { rel: 'stylesheet', href: stylesheet },
   ]

   export default function App() {
     return (
       <html>
         <head>
           <Links />
         </head>
         <body>
           <Outlet />
           <Scripts />
         </body>
       </html>
     )
   }
   ```

5. **Start development**:
   ```bash
   npm run dev
   ```

## SolidJS

SolidJS with Vite supports Tailwind CSS seamlessly.

### Installation Steps

1. **Create SolidJS app** (if starting fresh):
   ```bash
   npm create vite@latest my-app -- --template solid-ts
   cd my-app
   ```

2. **Install Tailwind**:
   ```bash
   npm install tailwindcss @tailwindcss/vite
   ```

3. **Configure Vite** in `vite.config.ts`:
   ```typescript
   import { defineConfig } from 'vite'
   import solid from 'vite-plugin-solid'
   import tailwindcss from '@tailwindcss/vite'

   export default defineConfig({
     plugins: [solid(), tailwindcss()],
   })
   ```

4. **Import Tailwind** in `src/index.css`:
   ```css
   @import "tailwindcss";
   ```

5. **Import CSS** in `src/index.tsx`:
   ```typescript
   import { render } from 'solid-js/web'
   import './index.css'
   import App from './App'

   render(() => <App />, document.getElementById('root')!)
   ```

6. **Start development**:
   ```bash
   npm run dev
   ```

## Common Issues

### Build Errors

**Vite plugin not found**:
- Ensure `@tailwindcss/vite` is installed
- Check plugin is imported correctly in config

**CSS not loading**:
- Verify CSS import path is correct
- Ensure Vite is processing the CSS file
- Check browser console for import errors

### Framework-Specific Issues

**Next.js Turbopack conflicts**:
- Use Vite mode as shown in Next.js setup
- Disable Turbopack if necessary

**Laravel mix conflicts**:
- Remove old Laravel Mix configuration
- Use Vite exclusively for asset building

**Angular stylePreprocessorOptions**:
- Ensure PostCSS is configured correctly
- Check Angular build logs for errors

## Additional Framework Support

For frameworks not listed:

1. Check if framework uses Vite - use `@tailwindcss/vite` plugin
2. Check if framework uses PostCSS - use `@tailwindcss/postcss` plugin
3. Check if framework supports custom CSS - use Tailwind CLI
4. Consult Tailwind docs at https://tailwindcss.com/docs/installation/framework-guides
