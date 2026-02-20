# HTMX Advanced Patterns and Examples

Real-world patterns and complete examples for common use cases.

## Table of Contents

- [Active Search](#active-search)
- [Infinite Scroll](#infinite-scroll)
- [Click to Edit](#click-to-edit)
- [Bulk Update](#bulk-update)
- [Modal Dialogs](#modal-dialogs)
- [Tabs](#tabs)
- [Lazy Loading](#lazy-loading)
- [Cascading Selects](#cascading-selects)
- [Optimistic UI](#optimistic-ui)
- [Inline Validation](#inline-validation)
- [Polling and Progress](#polling-and-progress)
- [Keyboard Shortcuts](#keyboard-shortcuts)
- [Sortable Lists](#sortable-lists)
- [Confirm Dialog](#confirm-dialog)

## Active Search

Real-time search with debouncing.

```html
<div>
    <input type="search" 
           name="q"
           hx-get="/search"
           hx-trigger="keyup changed delay:500ms, search"
           hx-target="#search-results"
           hx-indicator="#search-spinner"
           placeholder="Search...">
    
    <img id="search-spinner" class="htmx-indicator" src="/spinner.gif">
    
    <div id="search-results"></div>
</div>
```

**Server endpoint:**
```python
@app.route('/search')
def search():
    query = request.args.get('q', '').strip()
    
    if len(query) < 2:
        return '<div class="hint">Type at least 2 characters</div>'
    
    results = db.search(query, limit=10)
    
    if not results:
        return '<div class="no-results">No results found</div>'
    
    return render_template('partials/search_results.html', results=results)
```

## Infinite Scroll

Load more content as user scrolls.

```html
<div id="content">
    {% for item in items %}
    <div class="item">{{ item.name }}</div>
    {% endfor %}
    
    {% if has_more %}
    <div hx-get="/items?page={{ next_page }}"
         hx-trigger="revealed"
         hx-swap="afterend"
         hx-indicator="#load-more-spinner">
        <div id="load-more-spinner" class="htmx-indicator">
            Loading more...
        </div>
    </div>
    {% endif %}
</div>
```

**Alternative: Load More Button**
```html
<div id="items">
    {% for item in items %}
    <div class="item">{{ item.name }}</div>
    {% endfor %}
</div>

{% if has_more %}
<button hx-get="/items?page={{ next_page }}"
        hx-target="#items"
        hx-swap="beforeend"
        hx-select=".item">
    Load More
</button>
{% endif %}
```

## Click to Edit

Inline editing pattern.

```html
<!-- Display State -->
<div id="contact-{{ contact.id }}" class="contact-display">
    <div>
        <strong>Name:</strong> {{ contact.name }}<br>
        <strong>Email:</strong> {{ contact.email }}
    </div>
    <button hx-get="/contacts/{{ contact.id }}/edit"
            hx-target="#contact-{{ contact.id }}"
            hx-swap="outerHTML">
        Edit
    </button>
</div>

<!-- Edit State Template -->
<form id="contact-{{ contact.id }}"
      hx-put="/contacts/{{ contact.id }}"
      hx-target="this"
      hx-swap="outerHTML"
      class="contact-form">
    <div>
        <label>Name:</label>
        <input name="name" value="{{ contact.name }}" required>
    </div>
    <div>
        <label>Email:</label>
        <input name="email" type="email" value="{{ contact.email }}" required>
    </div>
    <button type="submit">Save</button>
    <button type="button"
            hx-get="/contacts/{{ contact.id }}"
            hx-target="#contact-{{ contact.id }}"
            hx-swap="outerHTML">
        Cancel
    </button>
</form>
```

## Bulk Update

Select and update multiple items.

```html
<form id="bulk-form">
    <table>
        <thead>
            <tr>
                <th>
                    <input type="checkbox" id="select-all">
                </th>
                <th>Name</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody>
            {% for item in items %}
            <tr>
                <td>
                    <input type="checkbox" name="selected" value="{{ item.id }}">
                </td>
                <td>{{ item.name }}</td>
                <td>{{ item.status }}</td>
            </tr>
            {% endfor %}
        </tbody>
    </table>
    
    <div class="bulk-actions">
        <button hx-post="/items/bulk-delete"
                hx-include="[name='selected']:checked"
                hx-confirm="Delete selected items?"
                hx-target="tbody"
                hx-swap="innerHTML">
            Delete Selected
        </button>
        
        <button hx-put="/items/bulk-activate"
                hx-include="[name='selected']:checked"
                hx-target="tbody"
                hx-swap="innerHTML">
            Activate Selected
        </button>
    </div>
</form>

<script>
// Select all checkbox
document.getElementById('select-all').addEventListener('change', function(e) {
    document.querySelectorAll('[name="selected"]').forEach(cb => {
        cb.checked = e.target.checked;
    });
});
</script>
```

## Modal Dialogs

Dynamic modal loading.

```html
<!-- Modal Container -->
<div id="modal" class="modal" style="display: none;">
    <div class="modal-content">
        <span class="close" onclick="closeModal()">&times;</span>
        <div id="modal-body"></div>
    </div>
</div>

<!-- Trigger -->
<button hx-get="/items/new"
        hx-target="#modal-body"
        hx-on::after-swap="openModal()">
    New Item
</button>

<script>
function openModal() {
    document.getElementById('modal').style.display = 'block';
}

function closeModal() {
    document.getElementById('modal').style.display = 'none';
}

// Close on background click
document.getElementById('modal').addEventListener('click', function(e) {
    if (e.target === this) {
        closeModal();
    }
});

// Close modal on successful form submission
htmx.on('htmx:afterSwap', function(evt) {
    if (evt.detail.successful && evt.detail.target.id === 'modal-body') {
        setTimeout(closeModal, 500);
    }
});
</script>
```

**Modal Form Template:**
```html
<form hx-post="/items"
      hx-target="#items-list"
      hx-swap="afterbegin">
    <h2>Create Item</h2>
    
    <div>
        <label>Name:</label>
        <input name="name" required>
    </div>
    
    <div>
        <label>Description:</label>
        <textarea name="description"></textarea>
    </div>
    
    <button type="submit">Create</button>
    <button type="button" onclick="closeModal()">Cancel</button>
</form>
```

## Tabs

Dynamic tab loading.

```html
<div class="tabs">
    <div class="tab-buttons">
        <button hx-get="/tabs/overview"
                hx-target="#tab-content"
                hx-swap="innerHTML"
                class="active">
            Overview
        </button>
        <button hx-get="/tabs/details"
                hx-target="#tab-content"
                hx-swap="innerHTML">
            Details
        </button>
        <button hx-get="/tabs/history"
                hx-target="#tab-content"
                hx-swap="innerHTML">
            History
        </button>
    </div>
    
    <div id="tab-content" class="tab-content">
        <!-- Initial content loaded here -->
        {% include 'partials/overview.html' %}
    </div>
</div>

<script>
// Manage active tab styling
htmx.on('htmx:afterSwap', function(evt) {
    if (evt.detail.target.id === 'tab-content') {
        document.querySelectorAll('.tab-buttons button').forEach(btn => {
            btn.classList.remove('active');
        });
        evt.detail.elt.classList.add('active');
    }
});
</script>
```

## Lazy Loading

Load content only when needed.

```html
<!-- Load on viewport reveal -->
<div hx-get="/expensive-content"
     hx-trigger="revealed"
     hx-swap="outerHTML">
    <div class="placeholder">
        <div class="spinner"></div>
        Loading content...
    </div>
</div>

<!-- Load on tab activation -->
<div id="lazy-tab"
     hx-get="/tab-content"
     hx-trigger="load once"
     hx-swap="innerHTML">
    Loading...
</div>

<!-- Load on first interaction -->
<div hx-get="/widget"
     hx-trigger="click once, mouseenter once"
     hx-swap="outerHTML">
    Click or hover to load widget
</div>
```

## Cascading Selects

Dependent dropdowns.

```html
<form>
    <div>
        <label>Country:</label>
        <select name="country"
                hx-get="/states"
                hx-target="#state-select"
                hx-swap="innerHTML">
            <option value="">Select Country</option>
            <option value="us">United States</option>
            <option value="ca">Canada</option>
        </select>
    </div>
    
    <div>
        <label>State:</label>
        <select id="state-select" 
                name="state"
                hx-get="/cities"
                hx-target="#city-select"
                hx-swap="innerHTML">
            <option value="">Select State</option>
        </select>
    </div>
    
    <div>
        <label>City:</label>
        <select id="city-select" name="city">
            <option value="">Select City</option>
        </select>
    </div>
</form>
```

**Server endpoints:**
```python
@app.route('/states')
def get_states():
    country = request.args.get('country')
    states = get_states_for_country(country)
    
    html = '<option value="">Select State</option>'
    for state in states:
        html += f'<option value="{state.code}">{state.name}</option>'
    
    return html

@app.route('/cities')
def get_cities():
    state = request.args.get('state')
    cities = get_cities_for_state(state)
    
    html = '<option value="">Select City</option>'
    for city in cities:
        html += f'<option value="{city.id}">{city.name}</option>'
    
    return html
```

## Optimistic UI

Show changes immediately, rollback on error.

```html
<div id="like-{{ post.id }}">
    <button hx-post="/posts/{{ post.id }}/like"
            hx-target="#like-{{ post.id }}"
            hx-swap="outerHTML"
            hx-on::before-request="optimisticLike(this)"
            hx-on::response-error="rollbackLike(this)">
        <span class="icon">♡</span>
        <span class="count">{{ post.likes }}</span>
    </button>
</div>

<script>
const originalStates = new Map();

function optimisticLike(button) {
    // Save original state
    const parent = button.closest('[id^="like-"]');
    originalStates.set(parent.id, parent.innerHTML);
    
    // Optimistically update UI
    const icon = button.querySelector('.icon');
    const count = button.querySelector('.count');
    icon.textContent = '♥';
    count.textContent = parseInt(count.textContent) + 1;
    button.classList.add('liked');
}

function rollbackLike(button) {
    // Restore original state on error
    const parent = button.closest('[id^="like-"]');
    const original = originalStates.get(parent.id);
    if (original) {
        parent.innerHTML = original;
        originalStates.delete(parent.id);
    }
}
</script>
```

## Inline Validation

Validate fields as user types.

```html
<form hx-post="/users">
    <div>
        <label>Username:</label>
        <input name="username"
               hx-post="/validate/username"
               hx-trigger="keyup changed delay:500ms"
               hx-target="#username-error"
               hx-swap="innerHTML"
               required>
        <span id="username-error" class="error"></span>
    </div>
    
    <div>
        <label>Email:</label>
        <input name="email"
               type="email"
               hx-post="/validate/email"
               hx-trigger="blur"
               hx-target="#email-error"
               hx-swap="innerHTML"
               required>
        <span id="email-error" class="error"></span>
    </div>
    
    <button type="submit">Register</button>
</form>
```

**Server validation:**
```python
@app.route('/validate/username', methods=['POST'])
def validate_username():
    username = request.form.get('username', '')
    
    if len(username) < 3:
        return '<span class="error">Username must be at least 3 characters</span>', 422
    
    if User.query.filter_by(username=username).first():
        return '<span class="error">Username already taken</span>', 422
    
    return '<span class="success">✓ Available</span>'

@app.route('/validate/email', methods=['POST'])
def validate_email():
    email = request.form.get('email', '')
    
    if not is_valid_email(email):
        return '<span class="error">Invalid email format</span>', 422
    
    if User.query.filter_by(email=email).first():
        return '<span class="error">Email already registered</span>', 422
    
    return '<span class="success">✓ Valid</span>'
```

## Polling and Progress

Track long-running operations.

```html
<!-- Start long operation -->
<button hx-post="/start-job"
        hx-target="#job-status"
        hx-swap="innerHTML">
    Start Processing
</button>

<div id="job-status"></div>

<!-- Job status template (returned from /start-job) -->
<div hx-get="/job-status/{{ job.id }}"
     hx-trigger="load delay:1s"
     hx-swap="outerHTML"
     hx-target="this">
    <div class="progress">
        <div class="progress-bar" style="width: {{ job.progress }}%">
            {{ job.progress }}%
        </div>
    </div>
    <div>Status: {{ job.status }}</div>
</div>

<!-- Completed state (returned when job done) -->
<div class="job-complete">
    <div class="success">✓ Job completed successfully!</div>
    <a href="/download/{{ job.id }}">Download Results</a>
</div>
```

**Server implementation:**
```python
@app.route('/start-job', methods=['POST'])
def start_job():
    job = Job.create()
    job.start_async()  # Start background task
    
    return render_template('partials/job_status.html', job=job)

@app.route('/job-status/<job_id>')
def job_status(job_id):
    job = Job.query.get(job_id)
    
    if job.is_complete:
        return render_template('partials/job_complete.html', job=job)
    
    # Continue polling
    return render_template('partials/job_status.html', job=job)
```

## Keyboard Shortcuts

Global keyboard shortcuts.

```html
<div hx-get="/search"
     hx-trigger="keyup[ctrlKey && key === '/'] from:body"
     hx-target="#search-modal"
     style="display: none;">
</div>

<div hx-post="/save"
     hx-trigger="keyup[ctrlKey && key === 's'] from:body"
     hx-include="form"
     style="display: none;">
</div>

<!-- Prevent default browser behavior -->
<script>
document.body.addEventListener('keydown', function(e) {
    if (e.ctrlKey && e.key === '/') {
        e.preventDefault();
    }
    if (e.ctrlKey && e.key === 's') {
        e.preventDefault();
    }
});
</script>
```

## Sortable Lists

Drag and drop reordering (requires SortableJS library).

```html
<ul id="sortable-list" class="sortable">
    {% for item in items %}
    <li data-id="{{ item.id }}">
        <span class="handle">⋮⋮</span>
        {{ item.name }}
    </li>
    {% endfor %}
</ul>

<script src="https://cdn.jsdelivr.net/npm/sortablejs@latest/Sortable.min.js"></script>
<script>
const sortable = Sortable.create(document.getElementById('sortable-list'), {
    handle: '.handle',
    animation: 150,
    onEnd: function(evt) {
        // Get new order
        const ids = [...evt.to.children].map(li => li.dataset.id);
        
        // Send to server
        htmx.ajax('POST', '/items/reorder', {
            values: {order: ids.join(',')},
            target: '#sortable-list',
            swap: 'none'
        });
    }
});
</script>
```

## Confirm Dialog

Custom confirmation with SweetAlert2.

```html
<button hx-delete="/items/{{ item.id }}"
        hx-target="closest tr"
        hx-swap="outerHTML swap:1s"
        data-confirm="true"
        data-confirm-title="Delete Item?"
        data-confirm-text="This action cannot be undone.">
    Delete
</button>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>
document.body.addEventListener('htmx:confirm', function(evt) {
    if (evt.target.dataset.confirm) {
        evt.preventDefault();
        
        Swal.fire({
            title: evt.target.dataset.confirmTitle || 'Are you sure?',
            text: evt.target.dataset.confirmText || '',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#3085d6',
            confirmButtonText: 'Yes, proceed'
        }).then((result) => {
            if (result.isConfirmed) {
                evt.detail.issueRequest();
            }
        });
    }
});
</script>
```

## File Upload with Preview

```html
<form hx-post="/upload"
      hx-encoding="multipart/form-data"
      hx-target="#result">
    <input type="file" 
           name="file"
           accept="image/*"
           onchange="previewImage(this)"
           required>
    
    <div id="preview"></div>
    
    <progress id="progress" value="0" max="100" style="width: 100%;"></progress>
    <div id="progress-text"></div>
    
    <button type="submit">Upload</button>
</form>

<div id="result"></div>

<script>
function previewImage(input) {
    const preview = document.getElementById('preview');
    const file = input.files[0];
    
    if (file) {
        const reader = new FileReader();
        reader.onload = function(e) {
            preview.innerHTML = `<img src="${e.target.result}" style="max-width: 300px;">`;
        };
        reader.readAsDataURL(file);
    }
}

htmx.on('htmx:xhr:progress', function(evt) {
    if (evt.detail.lengthComputable) {
        const percent = Math.round((evt.detail.loaded / evt.detail.total) * 100);
        document.getElementById('progress').value = percent;
        document.getElementById('progress-text').textContent = `${percent}% uploaded`;
    }
});

htmx.on('htmx:afterRequest', function(evt) {
    document.getElementById('progress').value = 0;
    document.getElementById('progress-text').textContent = '';
});
</script>
```

## Multi-Step Form

Wizard-style form.

```html
<div id="wizard">
    <div class="steps">
        <div class="step active">1. Basic Info</div>
        <div class="step">2. Details</div>
        <div class="step">3. Review</div>
    </div>
    
    <div id="wizard-content">
        <!-- Step 1 -->
        <form hx-post="/wizard/step1"
              hx-target="#wizard-content"
              hx-swap="innerHTML">
            <h2>Step 1: Basic Information</h2>
            
            <input name="name" placeholder="Name" required>
            <input name="email" type="email" placeholder="Email" required>
            
            <button type="submit">Next →</button>
        </form>
    </div>
</div>

<!-- Step 2 template -->
<form hx-post="/wizard/step2"
      hx-target="#wizard-content"
      hx-swap="innerHTML"
      hx-include="previous">
    <h2>Step 2: Details</h2>
    
    <textarea name="bio" placeholder="Bio"></textarea>
    <input name="phone" placeholder="Phone">
    
    <!-- Hidden fields from previous steps -->
    <input type="hidden" name="name" value="{{ data.name }}">
    <input type="hidden" name="email" value="{{ data.email }}">
    
    <button type="button"
            hx-get="/wizard/step1"
            hx-target="#wizard-content">
        ← Back
    </button>
    <button type="submit">Next →</button>
</form>

<!-- Step 3 template (review) -->
<form hx-post="/wizard/submit"
      hx-target="#wizard"
      hx-swap="outerHTML">
    <h2>Step 3: Review & Submit</h2>
    
    <dl>
        <dt>Name:</dt><dd>{{ data.name }}</dd>
        <dt>Email:</dt><dd>{{ data.email }}</dd>
        <dt>Bio:</dt><dd>{{ data.bio }}</dd>
        <dt>Phone:</dt><dd>{{ data.phone }}</dd>
    </dl>
    
    <!-- All data as hidden fields -->
    <input type="hidden" name="name" value="{{ data.name }}">
    <input type="hidden" name="email" value="{{ data.email }}">
    <input type="hidden" name="bio" value="{{ data.bio }}">
    <input type="hidden" name="phone" value="{{ data.phone }}">
    
    <button type="button"
            hx-get="/wizard/step2"
            hx-target="#wizard-content">
        ← Back
    </button>
    <button type="submit">Submit</button>
</form>

<script>
// Update step indicators
htmx.on('htmx:afterSwap', function(evt) {
    if (evt.detail.target.id === 'wizard-content') {
        const stepNumber = evt.detail.xhr.getResponseHeader('X-Current-Step');
        if (stepNumber) {
            document.querySelectorAll('.step').forEach((step, idx) => {
                step.classList.toggle('active', idx < parseInt(stepNumber));
            });
        }
    }
});
</script>
```

These patterns demonstrate how htmx enables complex, interactive UIs with minimal JavaScript, keeping server-side rendering as the primary paradigm.
