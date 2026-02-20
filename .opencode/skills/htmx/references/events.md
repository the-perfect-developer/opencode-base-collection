# HTMX Events Reference

Complete guide to htmx events and the request/response lifecycle.

## Event Lifecycle

htmx fires events at every stage of the request lifecycle:

1. **Trigger** → `htmx:trigger`
2. **Before Request** → `htmx:beforeRequest`
3. **Config Request** → `htmx:configRequest`
4. **Before Send** → `htmx:beforeSend`
5. **Request Sent** → `htmx:xhr:loadstart`
6. **Response Received** → `htmx:beforeSwap`
7. **Content Swapped** → `htmx:afterSwap`
8. **DOM Settled** → `htmx:afterSettle`

## Core Events

### htmx:trigger

Fired when an element is triggered, before any request is issued.

```javascript
htmx.on('htmx:trigger', function(evt) {
    console.log('Element triggered:', evt.detail.elt);
});
```

**Detail properties**:
- `elt` - The triggered element

### htmx:beforeRequest

Fired before a request is issued. Can be cancelled.

```javascript
htmx.on('htmx:beforeRequest', function(evt) {
    if (!confirm('Continue?')) {
        evt.preventDefault(); // Cancel request
    }
});
```

**Detail properties**:
- `xhr` - The XMLHttpRequest object
- `target` - The target element
- `requestConfig` - Configuration object

### htmx:configRequest

Fired before a request is sent, allowing you to modify headers, parameters, etc.

```javascript
htmx.on('htmx:configRequest', function(evt) {
    // Add custom header
    evt.detail.headers['X-Custom'] = 'value';
    
    // Add parameter
    evt.detail.parameters['extra'] = 'data';
    
    // Change URL
    evt.detail.path = '/new/url';
    
    // Change verb
    evt.detail.verb = 'put';
});
```

**Detail properties**:
- `parameters` - Request parameters object
- `headers` - Request headers object
- `path` - Request URL
- `verb` - HTTP method
- `errors` - Validation errors array
- `triggeringEvent` - Event that triggered request

### htmx:beforeSend

Fired just before the request is sent. Last chance to cancel.

```javascript
htmx.on('htmx:beforeSend', function(evt) {
    console.log('Sending request to:', evt.detail.xhr.url);
});
```

**Detail properties**:
- `xhr` - The XMLHttpRequest object
- `elt` - The element that made the request

### htmx:xhr:loadstart

Fired when the XMLHttpRequest starts.

```javascript
htmx.on('htmx:xhr:loadstart', function(evt) {
    console.log('Request started');
});
```

### htmx:xhr:progress

Fired periodically during request (useful for upload progress).

```javascript
htmx.on('htmx:xhr:progress', function(evt) {
    const percent = (evt.detail.loaded / evt.detail.total) * 100;
    document.getElementById('progress').value = percent;
});
```

**Detail properties**:
- `loaded` - Bytes loaded
- `total` - Total bytes
- `lengthComputable` - Whether total is known

### htmx:beforeSwap

Fired before content swap occurs. Can modify swap behavior.

```javascript
htmx.on('htmx:beforeSwap', function(evt) {
    // Don't swap on error
    if (evt.detail.xhr.status === 404) {
        evt.detail.shouldSwap = false;
        alert('Not found');
    }
    
    // Change swap target
    evt.detail.target = document.getElementById('other');
    
    // Change swap method
    evt.detail.swapStyle = 'beforeend';
});
```

**Detail properties**:
- `xhr` - The XMLHttpRequest
- `target` - Current target element (can be modified)
- `shouldSwap` - Boolean, set to false to prevent swap
- `serverResponse` - The response HTML
- `swapStyle` - Current swap style (can be modified)

### htmx:afterSwap

Fired after content is swapped into the DOM.

```javascript
htmx.on('htmx:afterSwap', function(evt) {
    console.log('Content swapped into:', evt.detail.target);
    
    // Initialize new content
    initializeWidgets(evt.detail.target);
});
```

**Detail properties**:
- `elt` - Element that made request
- `target` - Target element that was swapped
- `xhr` - The XMLHttpRequest

### htmx:afterSettle

Fired after the settling phase (when new content is fully integrated).

```javascript
htmx.on('htmx:afterSettle', function(evt) {
    console.log('Content settled');
    
    // Run animations, focus elements, etc.
    evt.detail.target.querySelector('input').focus();
});
```

**Detail properties**:
- `elt` - Element that made request
- `target` - Target element
- `xhr` - The XMLHttpRequest

### htmx:afterRequest

Fired after the request completes (success or failure).

```javascript
htmx.on('htmx:afterRequest', function(evt) {
    console.log('Request complete');
    console.log('Success:', evt.detail.successful);
});
```

**Detail properties**:
- `elt` - Element that made request
- `xhr` - The XMLHttpRequest
- `successful` - Boolean indicating success

### htmx:afterOnLoad

Fired after the response has been processed.

```javascript
htmx.on('htmx:afterOnLoad', function(evt) {
    console.log('Response processed');
});
```

## Error Events

### htmx:sendError

Fired when a network error prevents request from being sent.

```javascript
htmx.on('htmx:sendError', function(evt) {
    console.error('Network error:', evt.detail.error);
    alert('Connection failed. Please check your internet connection.');
});
```

**Detail properties**:
- `elt` - Element that made request
- `error` - The error object
- `xhr` - The XMLHttpRequest

### htmx:responseError

Fired when response has error status code (4xx, 5xx).

```javascript
htmx.on('htmx:responseError', function(evt) {
    const status = evt.detail.xhr.status;
    console.error('Response error:', status);
    
    if (status === 401) {
        window.location = '/login';
    } else if (status === 500) {
        alert('Server error. Please try again later.');
    }
});
```

**Detail properties**:
- `elt` - Element that made request
- `xhr` - The XMLHttpRequest
- `target` - The target element
- `error` - Error message

### htmx:swapError

Fired when error occurs during content swap.

```javascript
htmx.on('htmx:swapError', function(evt) {
    console.error('Swap error:', evt.detail.error);
});
```

**Detail properties**:
- `elt` - Element that made request
- `error` - The error object

### htmx:onLoadError

Fired when error occurs during onLoad processing.

```javascript
htmx.on('htmx:onLoadError', function(evt) {
    console.error('OnLoad error:', evt.detail.error);
});
```

**Detail properties**:
- `elt` - Element where error occurred
- `error` - The error object

### htmx:targetError

Fired when target element cannot be found.

```javascript
htmx.on('htmx:targetError', function(evt) {
    console.error('Target not found:', evt.detail.target);
    alert('Could not find target element');
});
```

**Detail properties**:
- `elt` - Element that made request
- `target` - The missing target selector

### htmx:timeout

Fired when request times out.

```javascript
htmx.on('htmx:timeout', function(evt) {
    alert('Request timed out. Please try again.');
});
```

**Detail properties**:
- `elt` - Element that made request
- `xhr` - The XMLHttpRequest

## Validation Events

### htmx:validation:validate

Fired before element validation. Add custom validation here.

```javascript
htmx.on('htmx:validation:validate', function(evt) {
    const value = evt.detail.elt.value;
    
    if (value === 'admin') {
        evt.detail.elt.setCustomValidity('Username "admin" is reserved');
        evt.detail.valid = false;
    } else {
        evt.detail.elt.setCustomValidity('');
    }
});
```

**Detail properties**:
- `elt` - Element being validated
- `valid` - Boolean, current validation state

### htmx:validation:failed

Fired when element validation fails.

```javascript
htmx.on('htmx:validation:failed', function(evt) {
    console.log('Validation failed:', evt.detail.elt);
    evt.detail.elt.classList.add('validation-error');
});
```

**Detail properties**:
- `elt` - Element that failed validation
- `message` - Validation error message

### htmx:validation:halted

Fired when request is cancelled due to validation errors.

```javascript
htmx.on('htmx:validation:halted', function(evt) {
    const errors = evt.detail.errors;
    console.log('Validation errors:', errors);
    
    // Show all errors
    errors.forEach(error => {
        console.log(error.elt, error.message);
    });
});
```

**Detail properties**:
- `elt` - Element that triggered request
- `errors` - Array of validation errors

## Confirmation Events

### htmx:confirm

Fired when confirmation is needed. Implement custom confirmation dialogs.

```javascript
htmx.on('htmx:confirm', function(evt) {
    evt.preventDefault(); // Prevent default confirm dialog
    
    // Show custom confirmation (e.g., SweetAlert)
    Swal.fire({
        title: 'Are you sure?',
        text: evt.detail.question,
        icon: 'warning',
        showCancelButton: true
    }).then((result) => {
        if (result.isConfirmed) {
            evt.detail.issueRequest(); // Proceed with request
        }
    });
});
```

**Detail properties**:
- `elt` - Element needing confirmation
- `question` - Confirmation message
- `issueRequest()` - Function to call to proceed
- `triggeringEvent` - Event that triggered

### htmx:prompt

Fired after a prompt is shown.

```javascript
htmx.on('htmx:prompt', function(evt) {
    console.log('User entered:', evt.detail.prompt);
});
```

**Detail properties**:
- `elt` - Element that prompted
- `prompt` - User's response

## History Events

### htmx:pushedIntoHistory

Fired after URL is pushed to history.

```javascript
htmx.on('htmx:pushedIntoHistory', function(evt) {
    console.log('URL pushed:', evt.detail.path);
    updateBreadcrumbs(evt.detail.path);
});
```

**Detail properties**:
- `path` - The URL that was pushed

### htmx:replacedInHistory

Fired after URL is replaced in history.

```javascript
htmx.on('htmx:replacedInHistory', function(evt) {
    console.log('URL replaced:', evt.detail.path);
});
```

**Detail properties**:
- `path` - The replacement URL

### htmx:historyRestore

Fired when htmx restores history.

```javascript
htmx.on('htmx:historyRestore', function(evt) {
    console.log('Restoring history:', evt.detail.path);
    // Reinitialize page state
});
```

**Detail properties**:
- `path` - The restored URL

### htmx:beforeHistorySave

Fired before content is saved to history cache.

```javascript
htmx.on('htmx:beforeHistorySave', function(evt) {
    // Clean up before snapshot
    document.querySelectorAll('.no-cache').forEach(el => {
        el.remove();
    });
});
```

**Detail properties**:
- `path` - URL being cached
- `historyElt` - Element being cached

### htmx:historyCacheHit

Fired when history is restored from cache.

```javascript
htmx.on('htmx:historyCacheHit', function(evt) {
    console.log('Cache hit for:', evt.detail.path);
});
```

### htmx:historyCacheMiss

Fired when history restore needs to fetch from server.

```javascript
htmx.on('htmx:historyCacheMiss', function(evt) {
    console.log('Cache miss for:', evt.detail.path);
});
```

### htmx:historyCacheMissLoad

Fired after successful server fetch for history.

```javascript
htmx.on('htmx:historyCacheMissLoad', function(evt) {
    console.log('History content loaded');
});
```

### htmx:historyCacheMissLoadError

Fired when server fetch for history fails.

```javascript
htmx.on('htmx:historyCacheMissLoadError', function(evt) {
    alert('Could not restore page. Please refresh.');
});
```

### htmx:historyCacheError

Fired when error occurs writing to history cache.

```javascript
htmx.on('htmx:historyCacheError', function(evt) {
    console.error('Cache error:', evt.detail.error);
});
```

## Content Processing Events

### htmx:load

Fired when new content is added to DOM (same as afterSwap but bubbles).

```javascript
htmx.on('htmx:load', function(evt) {
    // Initialize any widgets in new content
    const newContent = evt.detail.elt;
    $(newContent).find('.datepicker').datepicker();
});
```

**Detail properties**:
- `elt` - The new element added

### htmx:beforeProcessNode

Fired before htmx processes a node.

```javascript
htmx.on('htmx:beforeProcessNode', function(evt) {
    console.log('Processing node:', evt.detail.elt);
});
```

**Detail properties**:
- `elt` - Element being processed

### htmx:afterProcessNode

Fired after htmx processes a node.

```javascript
htmx.on('htmx:afterProcessNode', function(evt) {
    console.log('Node processed:', evt.detail.elt);
});
```

**Detail properties**:
- `elt` - Element that was processed

### htmx:beforeCleanupElement

Fired before htmx cleans up an element.

```javascript
htmx.on('htmx:beforeCleanupElement', function(evt) {
    // Clean up third-party integrations
    const widget = evt.detail.elt.widget;
    if (widget) {
        widget.destroy();
    }
});
```

**Detail properties**:
- `elt` - Element being cleaned up

## Out-of-Band Events

### htmx:oobBeforeSwap

Fired before an out-of-band swap.

```javascript
htmx.on('htmx:oobBeforeSwap', function(evt) {
    console.log('OOB swap for:', evt.detail.target);
});
```

**Detail properties**:
- `elt` - Element containing hx-swap-oob
- `target` - Target for the swap
- `fragment` - Content to swap in

### htmx:oobAfterSwap

Fired after an out-of-band swap.

```javascript
htmx.on('htmx:oobAfterSwap', function(evt) {
    console.log('OOB swap complete');
});
```

**Detail properties**:
- `elt` - Element that was swapped
- `target` - Target that received swap

### htmx:oobErrorNoTarget

Fired when OOB element has no matching target.

```javascript
htmx.on('htmx:oobErrorNoTarget', function(evt) {
    console.error('No target for OOB element:', evt.detail.elt.id);
});
```

**Detail properties**:
- `elt` - OOB element with no target

## Special Events

### htmx:abort

Send this event to an element to abort its request.

```javascript
// Abort all requests from an element
htmx.trigger('#search-form', 'htmx:abort');
```

### htmx:beforeTransition

Fired before View Transition API swap. Can cancel transition.

```javascript
htmx.on('htmx:beforeTransition', function(evt) {
    // Cancel transition for specific cases
    if (shouldSkipTransition()) {
        evt.preventDefault();
    }
});
```

## Event Listener Helpers

### Listen to Events

```javascript
// Listen to event on specific element
htmx.on('#myElement', 'htmx:afterSwap', function(evt) {
    console.log('Swapped');
});

// Listen to all elements
htmx.on('htmx:afterSwap', function(evt) {
    console.log('Any swap');
});

// Using document.addEventListener
document.addEventListener('htmx:afterSwap', function(evt) {
    console.log('Swapped:', evt.detail.target);
});
```

### Remove Event Listener

```javascript
function handler(evt) {
    console.log('Event fired');
}

htmx.on('#element', 'htmx:afterSwap', handler);
htmx.off('#element', 'htmx:afterSwap', handler);
```

### Trigger Events

```javascript
// Trigger custom event
htmx.trigger('#element', 'myEvent', {detail: {foo: 'bar'}});

// Trigger htmx event
htmx.trigger('#element', 'htmx:abort');
```

## Common Event Patterns

### Global Request Tracking

```javascript
let activeRequests = 0;

htmx.on('htmx:beforeSend', function() {
    activeRequests++;
    document.body.classList.add('loading');
});

htmx.on('htmx:afterRequest', function() {
    activeRequests--;
    if (activeRequests === 0) {
        document.body.classList.remove('loading');
    }
});
```

### Authentication Redirect

```javascript
htmx.on('htmx:responseError', function(evt) {
    if (evt.detail.xhr.status === 401) {
        window.location = '/login?redirect=' + window.location.pathname;
    }
});
```

### Error Notification

```javascript
htmx.on('htmx:responseError', function(evt) {
    showNotification('Error: ' + evt.detail.xhr.status, 'error');
});

htmx.on('htmx:sendError', function(evt) {
    showNotification('Network error', 'error');
});
```

### Initialize Third-Party Libraries

```javascript
htmx.on('htmx:afterSwap', function(evt) {
    // Initialize tooltips
    $(evt.detail.target).find('[data-toggle="tooltip"]').tooltip();
    
    // Initialize datepickers
    $(evt.detail.target).find('.datepicker').datepicker();
});
```

### Cleanup Before History Save

```javascript
htmx.on('htmx:beforeHistorySave', function() {
    // Close all modals
    $('.modal').modal('hide');
    
    // Destroy certain widgets
    document.querySelectorAll('.rich-editor').forEach(el => {
        if (el.editor) {
            el.editor.destroy();
        }
    });
});
```

### Custom Confirmation with async operations

```javascript
htmx.on('htmx:confirm', function(evt) {
    evt.preventDefault();
    
    const element = evt.target;
    const confirmMessage = element.getAttribute('hx-confirm');
    
    // Custom async confirmation
    showConfirmDialog(confirmMessage).then(confirmed => {
        if (confirmed) {
            evt.detail.issueRequest();
        }
    });
});
```

### Progress Bar for File Upload

```javascript
htmx.on('htmx:xhr:progress', function(evt) {
    if (evt.detail.lengthComputable) {
        const percentComplete = (evt.detail.loaded / evt.detail.total) * 100;
        document.querySelector('#upload-progress').value = percentComplete;
        document.querySelector('#upload-percent').textContent = 
            Math.round(percentComplete) + '%';
    }
});

htmx.on('htmx:afterRequest', function(evt) {
    document.querySelector('#upload-progress').value = 0;
    document.querySelector('#upload-percent').textContent = '';
});
```
