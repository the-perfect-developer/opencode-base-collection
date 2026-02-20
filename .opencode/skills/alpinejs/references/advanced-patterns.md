# Alpine.js Advanced Patterns

Advanced component patterns, techniques, and best practices for building complex Alpine.js applications.

## Table of Contents

- [Component Architecture](#component-architecture)
- [State Management Patterns](#state-management-patterns)
- [Event Communication](#event-communication)
- [Performance Optimization](#performance-optimization)
- [Integration Patterns](#integration-patterns)
- [Testing Strategies](#testing-strategies)

## Component Architecture

### Reusable Components with Alpine.data()

Define reusable component logic that can be instantiated multiple times.

**Basic component**:
```javascript
Alpine.data('counter', () => ({
  count: 0,
  increment() {
    this.count++
  },
  decrement() {
    this.count--
  }
}))
```

**Usage**:
```html
<div x-data="counter">
  <button @click="decrement">-</button>
  <span x-text="count"></span>
  <button @click="increment">+</button>
</div>
```

**Component with parameters**:
```javascript
Alpine.data('counter', (initialCount = 0, step = 1) => ({
  count: initialCount,
  step: step,
  increment() {
    this.count += this.step
  }
}))
```

**Usage**:
```html
<div x-data="counter(10, 5)">
  <!-- Starts at 10, increments by 5 -->
</div>
```

**Component with initialization**:
```javascript
Alpine.data('dropdown', () => ({
  open: false,
  items: [],
  
  init() {
    // Run when component initializes
    this.items = this.fetchItems()
  },
  
  async fetchItems() {
    const response = await fetch('/api/items')
    return response.json()
  },
  
  toggle() {
    this.open = !this.open
  }
}))
```

### Component Composition

Combine multiple component behaviors.

**Mixin pattern**:
```javascript
// Define reusable behaviors
const toggleable = {
  open: false,
  toggle() {
    this.open = !this.open
  },
  close() {
    this.open = false
  }
}

const fetchable = {
  loading: false,
  error: null,
  
  async fetch(url) {
    this.loading = true
    this.error = null
    
    try {
      const response = await fetch(url)
      return await response.json()
    } catch (error) {
      this.error = error.message
    } finally {
      this.loading = false
    }
  }
}

// Compose into component
Alpine.data('dropdown', () => ({
  ...toggleable,
  ...fetchable,
  items: [],
  
  async init() {
    this.items = await this.fetch('/api/items')
  }
}))
```

### Scoped Component Instances

Create isolated component instances with private state.

**Factory pattern**:
```javascript
Alpine.data('modal', () => {
  // Private variables (closure)
  let zIndex = 1000
  
  return {
    open: false,
    
    show() {
      this.open = true
      this.$el.style.zIndex = ++zIndex
    },
    
    hide() {
      this.open = false
    }
  }
})
```

## State Management Patterns

### Global Store

Share state across multiple components.

**Define store**:
```javascript
Alpine.store('auth', {
  user: null,
  token: localStorage.getItem('token'),
  
  get isAuthenticated() {
    return !!this.token
  },
  
  async login(credentials) {
    const response = await fetch('/api/login', {
      method: 'POST',
      body: JSON.stringify(credentials)
    })
    
    const data = await response.json()
    this.token = data.token
    this.user = data.user
    
    localStorage.setItem('token', data.token)
  },
  
  logout() {
    this.token = null
    this.user = null
    localStorage.removeItem('token')
  }
})
```

**Access in components**:
```html
<div x-data>
  <template x-if="$store.auth.isAuthenticated">
    <div>
      <span x-text="$store.auth.user.name"></span>
      <button @click="$store.auth.logout()">Logout</button>
    </div>
  </template>
  
  <template x-if="!$store.auth.isAuthenticated">
    <button @click="showLogin = true">Login</button>
  </template>
</div>
```

### Reactive Store Methods

Create methods that trigger reactivity.

**Store with methods**:
```javascript
Alpine.store('cart', {
  items: [],
  
  get total() {
    return this.items.reduce((sum, item) => sum + item.price * item.qty, 0)
  },
  
  get count() {
    return this.items.reduce((sum, item) => sum + item.qty, 0)
  },
  
  add(product) {
    const existing = this.items.find(item => item.id === product.id)
    
    if (existing) {
      existing.qty++
    } else {
      this.items.push({ ...product, qty: 1 })
    }
  },
  
  remove(productId) {
    this.items = this.items.filter(item => item.id !== productId)
  },
  
  clear() {
    this.items = []
  }
})
```

**Usage**:
```html
<div x-data>
  <button @click="$store.cart.add(product)">Add to Cart</button>
  
  <div>
    Cart: <span x-text="$store.cart.count"></span> items
    Total: $<span x-text="$store.cart.total.toFixed(2)"></span>
  </div>
</div>
```

### Persistent State

Sync state with localStorage or sessionStorage.

**Manual persistence**:
```javascript
Alpine.store('preferences', {
  theme: localStorage.getItem('theme') || 'light',
  
  setTheme(theme) {
    this.theme = theme
    localStorage.setItem('theme', theme)
  }
})
```

**Auto-sync with effect**:
```javascript
Alpine.store('settings', {
  notifications: true,
  language: 'en',
  
  init() {
    // Load from localStorage on init
    const saved = localStorage.getItem('settings')
    if (saved) {
      Object.assign(this, JSON.parse(saved))
    }
    
    // Watch for changes and save
    this.$watch(() => this, 
      (value) => {
        localStorage.setItem('settings', JSON.stringify(value))
      },
      { deep: true }
    )
  }
})
```

**Using Alpine Persist plugin**:
```javascript
// Include plugin
import persist from '@alpinejs/persist'
Alpine.plugin(persist)

// Use in component
Alpine.data('form', () => ({
  email: Alpine.$persist('').as('formEmail'),
  name: Alpine.$persist('').as('formName')
}))
```

## Event Communication

### Parent-Child Communication

**Child to parent** (via custom events):
```html
<!-- Child component -->
<div x-data="{ 
  select(item) {
    $dispatch('item-selected', item)
  }
}">
  <button @click="select({ id: 1, name: 'Item' })">Select</button>
</div>

<!-- Parent component -->
<div x-data="{ selectedItem: null }" @item-selected="selectedItem = $event.detail">
  <child-component></child-component>
  <div x-show="selectedItem">
    Selected: <span x-text="selectedItem?.name"></span>
  </div>
</div>
```

**Parent to child** (via shared data):
```html
<div x-data="{ sharedValue: 'parent value' }">
  <!-- Child can access sharedValue -->
  <div x-data="{ 
    get parentValue() { 
      return sharedValue  // Access parent's data
    } 
  }">
    <span x-text="parentValue"></span>
  </div>
</div>
```

### Sibling Communication

**Via shared parent**:
```html
<div x-data="{ selectedTab: 'home' }">
  <!-- Tab buttons (sibling 1) -->
  <div>
    <button @click="selectedTab = 'home'">Home</button>
    <button @click="selectedTab = 'profile'">Profile</button>
  </div>
  
  <!-- Tab content (sibling 2) -->
  <div>
    <div x-show="selectedTab === 'home'">Home content</div>
    <div x-show="selectedTab === 'profile'">Profile content</div>
  </div>
</div>
```

**Via window events**:
```html
<!-- Component A -->
<div x-data>
  <button @click="$dispatch('global-event', { data: 'value' })">
    Trigger
  </button>
</div>

<!-- Component B -->
<div x-data="{ received: null }" @global-event.window="received = $event.detail">
  <span x-text="received?.data"></span>
</div>
```

### Event Bus Pattern

**Create event bus**:
```javascript
Alpine.store('eventBus', {
  listeners: {},
  
  on(event, callback) {
    if (!this.listeners[event]) {
      this.listeners[event] = []
    }
    this.listeners[event].push(callback)
  },
  
  emit(event, data) {
    if (this.listeners[event]) {
      this.listeners[event].forEach(callback => callback(data))
    }
  }
})
```

**Usage**:
```javascript
// Component A - emit
Alpine.data('publisher', () => ({
  publish() {
    Alpine.store('eventBus').emit('message', { text: 'Hello' })
  }
}))

// Component B - listen
Alpine.data('subscriber', () => ({
  messages: [],
  
  init() {
    Alpine.store('eventBus').on('message', (data) => {
      this.messages.push(data)
    })
  }
}))
```

## Performance Optimization

### Debouncing and Throttling

**Debounce input**:
```html
<input 
  x-data 
  x-model.debounce.500ms="search" 
  placeholder="Search..."
>
```

**Throttle scroll handler**:
```html
<div @scroll.throttle.100ms="handleScroll">
```

**Manual debounce**:
```javascript
Alpine.data('search', () => ({
  query: '',
  results: [],
  debounceTimeout: null,
  
  search() {
    clearTimeout(this.debounceTimeout)
    
    this.debounceTimeout = setTimeout(() => {
      this.performSearch()
    }, 300)
  },
  
  async performSearch() {
    this.results = await fetch(`/search?q=${this.query}`)
      .then(r => r.json())
  }
}))
```

### Lazy Loading

**Lazy load component data**:
```javascript
Alpine.data('lazyTable', () => ({
  data: [],
  loaded: false,
  
  load() {
    if (!this.loaded) {
      this.fetchData()
    }
  },
  
  async fetchData() {
    this.data = await fetch('/api/data').then(r => r.json())
    this.loaded = true
  }
}))
```

**Usage**:
```html
<div x-data="lazyTable" x-intersect="load">
  <!-- Data loads when scrolled into view -->
  <template x-for="row in data" :key="row.id">
    <div x-text="row.name"></div>
  </template>
</div>
```

### Virtualized Lists

**Simple virtualization**:
```javascript
Alpine.data('virtualList', () => ({
  items: Array.from({ length: 10000 }, (_, i) => ({ id: i, name: `Item ${i}` })),
  scrollTop: 0,
  itemHeight: 50,
  containerHeight: 400,
  
  get visibleItems() {
    const start = Math.floor(this.scrollTop / this.itemHeight)
    const count = Math.ceil(this.containerHeight / this.itemHeight)
    return this.items.slice(start, start + count + 1)
  },
  
  get offsetY() {
    return Math.floor(this.scrollTop / this.itemHeight) * this.itemHeight
  },
  
  handleScroll(event) {
    this.scrollTop = event.target.scrollTop
  }
}))
```

**Template**:
```html
<div 
  x-data="virtualList"
  @scroll.throttle="handleScroll"
  style="height: 400px; overflow-y: auto"
>
  <div :style="`height: ${items.length * itemHeight}px; position: relative`">
    <div :style="`transform: translateY(${offsetY}px)`">
      <template x-for="item in visibleItems" :key="item.id">
        <div :style="`height: ${itemHeight}px`" x-text="item.name"></div>
      </template>
    </div>
  </div>
</div>
```

### Computed Properties Caching

**Use getters for automatic caching**:
```javascript
Alpine.data('expensiveComputation', () => ({
  numbers: [1, 2, 3, 4, 5],
  
  // Automatically cached, only recomputes when numbers changes
  get sum() {
    console.log('Computing sum...')  // Only logs when numbers changes
    return this.numbers.reduce((a, b) => a + b, 0)
  }
}))
```

## Integration Patterns

### Integrating with Backend Frameworks

**Laravel Livewire + Alpine**:
```html
<div x-data="{ open: false }">
  <button @click="open = true">Open</button>
  
  <div x-show="open">
    <!-- Livewire component inside Alpine -->
    @livewire('user-form')
  </div>
</div>
```

**Rails with Turbo + Alpine**:
```html
<div 
  x-data="dropdown"
  data-turbo-permanent  <!-- Preserve across Turbo navigations -->
>
  <button @click="toggle">Toggle</button>
  <div x-show="open">Content</div>
</div>
```

### AJAX and Fetch

**Fetch with loading states**:
```javascript
Alpine.data('dataFetcher', () => ({
  data: null,
  loading: false,
  error: null,
  
  async fetch(url) {
    this.loading = true
    this.error = null
    
    try {
      const response = await fetch(url)
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      
      this.data = await response.json()
    } catch (error) {
      this.error = error.message
    } finally {
      this.loading = false
    }
  }
}))
```

**Template**:
```html
<div x-data="dataFetcher" x-init="fetch('/api/data')">
  <div x-show="loading">Loading...</div>
  <div x-show="error" x-text="error"></div>
  <div x-show="data && !loading">
    <!-- Display data -->
  </div>
</div>
```

### Form Submissions

**Enhanced form handling**:
```javascript
Alpine.data('enhancedForm', () => ({
  formData: {},
  errors: {},
  submitting: false,
  success: false,
  
  async submit() {
    this.submitting = true
    this.errors = {}
    this.success = false
    
    try {
      const response = await fetch('/api/submit', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name=csrf-token]').content
        },
        body: JSON.stringify(this.formData)
      })
      
      const result = await response.json()
      
      if (!response.ok) {
        this.errors = result.errors || {}
        return
      }
      
      this.success = true
      this.formData = {}  // Reset form
      
      // Redirect or show success message
      setTimeout(() => {
        window.location = result.redirectUrl
      }, 1000)
      
    } catch (error) {
      this.errors = { general: error.message }
    } finally {
      this.submitting = false
    }
  }
}))
```

**Template**:
```html
<form x-data="enhancedForm" @submit.prevent="submit">
  <div>
    <input 
      x-model="formData.email" 
      type="email"
      :class="{ 'error': errors.email }"
    >
    <span x-show="errors.email" x-text="errors.email"></span>
  </div>
  
  <button :disabled="submitting">
    <span x-show="!submitting">Submit</span>
    <span x-show="submitting">Submitting...</span>
  </button>
  
  <div x-show="success" class="success">Form submitted successfully!</div>
  <div x-show="errors.general" x-text="errors.general" class="error"></div>
</form>
```

### WebSocket Integration

**Real-time data with WebSockets**:
```javascript
Alpine.data('liveData', () => ({
  messages: [],
  connected: false,
  ws: null,
  
  init() {
    this.connect()
  },
  
  connect() {
    this.ws = new WebSocket('wss://example.com/socket')
    
    this.ws.addEventListener('open', () => {
      this.connected = true
    })
    
    this.ws.addEventListener('message', (event) => {
      const data = JSON.parse(event.data)
      this.messages.push(data)
    })
    
    this.ws.addEventListener('close', () => {
      this.connected = false
      // Reconnect after delay
      setTimeout(() => this.connect(), 3000)
    })
  },
  
  send(message) {
    if (this.connected) {
      this.ws.send(JSON.stringify(message))
    }
  }
}))
```

## Testing Strategies

### Unit Testing Components

**Testing with Jest**:
```javascript
import Alpine from 'alpinejs'

describe('Counter Component', () => {
  beforeEach(() => {
    document.body.innerHTML = `
      <div x-data="counter">
        <button x-ref="increment" @click="increment">+</button>
        <span x-ref="count" x-text="count"></span>
      </div>
    `
    
    Alpine.data('counter', () => ({
      count: 0,
      increment() { this.count++ }
    }))
    
    Alpine.start()
  })
  
  afterEach(() => {
    Alpine.destroyTree(document.body)
  })
  
  test('increments count on button click', () => {
    const button = document.querySelector('[x-ref="increment"]')
    const display = document.querySelector('[x-ref="count"]')
    
    expect(display.textContent).toBe('0')
    
    button.click()
    
    expect(display.textContent).toBe('1')
  })
})
```

### E2E Testing

**Cypress example**:
```javascript
describe('Dropdown Component', () => {
  beforeEach(() => {
    cy.visit('/dropdown-demo')
  })
  
  it('toggles dropdown on button click', () => {
    cy.get('[data-test="dropdown-content"]').should('not.be.visible')
    
    cy.get('[data-test="dropdown-button"]').click()
    cy.get('[data-test="dropdown-content"]').should('be.visible')
    
    cy.get('[data-test="dropdown-button"]').click()
    cy.get('[data-test="dropdown-content"]').should('not.be.visible')
  })
  
  it('closes dropdown when clicking outside', () => {
    cy.get('[data-test="dropdown-button"]').click()
    cy.get('[data-test="dropdown-content"]').should('be.visible')
    
    cy.get('body').click(0, 0)  // Click outside
    cy.get('[data-test="dropdown-content"]').should('not.be.visible')
  })
})
```

### Debugging Tips

**Enable Alpine DevTools**:
```javascript
window.Alpine = Alpine
Alpine.start()
```

**Log data changes**:
```html
<div 
  x-data="{ count: 0 }"
  x-effect="console.log('count changed to:', count)"
>
```

**Debug with $watch**:
```javascript
Alpine.data('debuggable', () => ({
  value: 0,
  
  init() {
    this.$watch('value', (newVal, oldVal) => {
      console.log(`Value changed from ${oldVal} to ${newVal}`)
    })
  }
}))
```

**Access component data in console**:
```javascript
// Get Alpine data from element
const el = document.querySelector('[x-data]')
const data = Alpine.$data(el)
console.log(data)
```

## Advanced Patterns Summary

**When to use**:
- **Alpine.data()**: Reusable components used multiple times
- **Alpine.store()**: Global state shared across components
- **Custom events**: Parent-child or sibling communication
- **Window events**: Cross-component communication
- **Getters**: Computed values that auto-update
- **x-effect**: Side effects when data changes
- **Debounce/throttle**: Performance optimization for frequent events
- **Virtualization**: Large lists (1000+ items)

**Best practices**:
- Keep components focused and single-purpose
- Use composition over deep nesting
- Leverage browser APIs (Intersection Observer, etc.)
- Test interactive behaviors
- Profile performance with DevTools
- Document complex state flows
