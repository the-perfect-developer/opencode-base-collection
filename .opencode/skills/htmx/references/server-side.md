# HTMX Server-Side Implementation Patterns

Guide to implementing htmx-compatible server endpoints across different frameworks and languages.

## Core Principles

1. **Return HTML, not JSON** - Server responses should be HTML fragments
2. **Check HX-Request header** - Detect htmx requests to return partials vs full pages
3. **Use HX-* response headers** - Control client behavior from server
4. **Validate on server** - Don't rely only on client validation
5. **Keep endpoints simple** - Each endpoint does one thing well

## Detecting HTMX Requests

### Python (Flask)

```python
from flask import request, render_template

@app.route('/data')
def get_data():
    if request.headers.get('HX-Request'):
        # htmx request - return partial
        return render_template('partials/data.html')
    else:
        # Direct browser request - return full page
        return render_template('page.html')
```

### Python (Django)

```python
from django.shortcuts import render

def data_view(request):
    if request.headers.get('HX-Request'):
        template = 'partials/data.html'
    else:
        template = 'full_page.html'
    
    return render(request, template, context)
```

### Node.js (Express)

```javascript
app.get('/data', (req, res) => {
    if (req.headers['hx-request']) {
        // htmx request - return partial
        res.render('partials/data');
    } else {
        // Direct request - return full page
        res.render('page');
    }
});
```

### PHP (Laravel)

```php
Route::get('/data', function (Request $request) {
    if ($request->header('HX-Request')) {
        return view('partials.data');
    }
    return view('page');
});
```

### Ruby (Rails)

```ruby
def data
  if request.headers['HX-Request']
    render partial: 'data'
  else
    render 'page'
  end
end
```

### Go (net/http)

```go
func dataHandler(w http.ResponseWriter, r *http.Request) {
    if r.Header.Get("HX-Request") == "true" {
        // Return partial
        tmpl.ExecuteTemplate(w, "partial.html", data)
    } else {
        // Return full page
        tmpl.ExecuteTemplate(w, "page.html", data)
    }
}
```

### C# (ASP.NET Core)

```csharp
public IActionResult Data()
{
    if (Request.Headers["HX-Request"].Count > 0)
    {
        return PartialView("_DataPartial");
    }
    return View("Page");
}
```

## Response Patterns

### Simple Fragment Response

```python
@app.route('/users/<int:user_id>')
def get_user(user_id):
    user = User.query.get_or_404(user_id)
    return render_template('partials/user_card.html', user=user)
```

```html
<!-- Template: partials/user_card.html -->
<div class="user-card">
    <h3>{{ user.name }}</h3>
    <p>{{ user.email }}</p>
</div>
```

### List with Append (Infinite Scroll)

```python
@app.route('/items')
def get_items():
    page = request.args.get('page', 1, type=int)
    items = Item.query.paginate(page=page, per_page=10)
    
    return render_template('partials/items.html', 
                         items=items.items,
                         has_more=items.has_next,
                         next_page=page + 1)
```

```html
<!-- Template: partials/items.html -->
{% for item in items %}
<div class="item">{{ item.name }}</div>
{% endfor %}

{% if has_more %}
<div hx-get="/items?page={{ next_page }}"
     hx-trigger="revealed"
     hx-swap="outerHTML">
    Loading more...
</div>
{% endif %}
```

### Form Validation Response

```python
@app.route('/users', methods=['POST'])
def create_user():
    form = UserForm()
    
    if form.validate_on_submit():
        user = User(name=form.name.data, email=form.email.data)
        db.session.add(user)
        db.session.commit()
        
        # Return success partial
        return render_template('partials/user_row.html', user=user)
    else:
        # Return form with errors
        return render_template('partials/user_form.html', form=form), 422
```

```html
<!-- Template: partials/user_form.html -->
<form hx-post="/users" hx-target="#user-list" hx-swap="beforeend">
    <input name="name" value="{{ form.name.data }}">
    {% if form.name.errors %}
        <span class="error">{{ form.name.errors[0] }}</span>
    {% endif %}
    
    <input name="email" value="{{ form.email.data }}">
    {% if form.email.errors %}
        <span class="error">{{ form.email.errors[0] }}</span>
    {% endif %}
    
    <button type="submit">Create User</button>
</form>
```

### Delete with Row Removal

```python
@app.route('/users/<int:user_id>', methods=['DELETE'])
def delete_user(user_id):
    user = User.query.get_or_404(user_id)
    db.session.delete(user)
    db.session.commit()
    
    # Return empty response - element will be deleted via swap="delete"
    return '', 200
```

```html
<tr id="user-{{ user.id }}">
    <td>{{ user.name }}</td>
    <td>
        <button hx-delete="/users/{{ user.id }}"
                hx-target="closest tr"
                hx-swap="outerHTML swap:1s"
                hx-confirm="Delete {{ user.name }}?">
            Delete
        </button>
    </td>
</tr>
```

### Click to Edit Pattern

```python
@app.route('/users/<int:user_id>/edit')
def edit_user_form(user_id):
    user = User.query.get_or_404(user_id)
    return render_template('partials/user_edit_form.html', user=user)

@app.route('/users/<int:user_id>', methods=['PUT'])
def update_user(user_id):
    user = User.query.get_or_404(user_id)
    user.name = request.form['name']
    user.email = request.form['email']
    db.session.commit()
    
    # Return display view
    return render_template('partials/user_display.html', user=user)
```

```html
<!-- Display view -->
<div id="user-{{ user.id }}" class="user-display">
    <span>{{ user.name }} ({{ user.email }})</span>
    <button hx-get="/users/{{ user.id }}/edit"
            hx-target="#user-{{ user.id }}"
            hx-swap="outerHTML">
        Edit
    </button>
</div>

<!-- Edit form -->
<form id="user-{{ user.id }}" 
      hx-put="/users/{{ user.id }}"
      hx-target="this"
      hx-swap="outerHTML">
    <input name="name" value="{{ user.name }}">
    <input name="email" value="{{ user.email }}">
    <button type="submit">Save</button>
    <button type="button"
            hx-get="/users/{{ user.id }}"
            hx-target="#user-{{ user.id }}"
            hx-swap="outerHTML">
        Cancel
    </button>
</form>
```

## Using Response Headers

### Triggering Client Events

```python
from flask import make_response

@app.route('/items/<int:item_id>', methods=['DELETE'])
def delete_item(item_id):
    item = Item.query.get_or_404(item_id)
    db.session.delete(item)
    db.session.commit()
    
    response = make_response('', 200)
    response.headers['HX-Trigger'] = 'itemDeleted'
    return response
```

```javascript
// Client-side listener
htmx.on('itemDeleted', function() {
    showNotification('Item deleted successfully');
    updateItemCount();
});
```

### Triggering with JSON Data

```python
import json

@app.route('/items', methods=['POST'])
def create_item():
    item = Item(name=request.form['name'])
    db.session.add(item)
    db.session.commit()
    
    response = make_response(
        render_template('partials/item.html', item=item)
    )
    
    # Trigger event with data
    response.headers['HX-Trigger'] = json.dumps({
        'itemCreated': {
            'id': item.id,
            'name': item.name
        },
        'showMessage': 'Item created successfully'
    })
    
    return response
```

```javascript
htmx.on('itemCreated', function(evt) {
    console.log('Created item:', evt.detail.id, evt.detail.name);
});

htmx.on('showMessage', function(evt) {
    showNotification(evt.detail.value);
});
```

### Client-Side Redirect

```python
@app.route('/login', methods=['POST'])
def login():
    if authenticate(request.form['username'], request.form['password']):
        response = make_response('', 200)
        response.headers['HX-Redirect'] = '/dashboard'
        return response
    else:
        return render_template('partials/login_form.html', 
                             error='Invalid credentials'), 401
```

### Location with Context

```python
import json

@app.route('/items/<int:item_id>', methods=['PUT'])
def update_item(item_id):
    item = Item.query.get_or_404(item_id)
    item.name = request.form['name']
    db.session.commit()
    
    response = make_response('', 200)
    response.headers['HX-Location'] = json.dumps({
        'path': f'/items/{item.id}',
        'target': '#main-content',
        'swap': 'innerHTML'
    })
    
    return response
```

### Retargeting and Reswapping

```python
@app.route('/search')
def search():
    query = request.args.get('q', '')
    results = search_items(query)
    
    response = make_response(
        render_template('partials/search_results.html', results=results)
    )
    
    if not results:
        # Change target to notification area
        response.headers['HX-Retarget'] = '#notifications'
        response.headers['HX-Reswap'] = 'beforeend'
    
    return response
```

### Refresh Page

```python
@app.route('/items/<int:item_id>', methods=['PUT'])
def major_update(item_id):
    # Make significant changes
    perform_major_update(item_id)
    
    response = make_response('', 200)
    response.headers['HX-Refresh'] = 'true'
    return response
```

## Out-of-Band Swaps

### Updating Multiple Sections

```python
@app.route('/cart/add/<int:item_id>', methods=['POST'])
def add_to_cart(item_id):
    cart = get_current_cart()
    cart.add_item(item_id)
    
    return render_template('partials/cart_response.html',
                         item=Item.query.get(item_id),
                         cart=cart)
```

```html
<!-- Template: partials/cart_response.html -->
<!-- Main content swap -->
<div class="notification success">
    Item added to cart
</div>

<!-- Out-of-band swap for cart icon -->
<div id="cart-count" hx-swap-oob="true">
    <span class="badge">{{ cart.item_count }}</span>
</div>

<!-- Out-of-band swap for cart total -->
<div id="cart-total" hx-swap-oob="true">
    ${{ cart.total }}
</div>
```

### Notification Pattern

```python
def render_with_notification(template, message, level='info', **context):
    """Helper to include notification in any response"""
    context['notification'] = {
        'message': message,
        'level': level
    }
    return render_template(template, **context)

@app.route('/items', methods=['POST'])
def create_item():
    item = create_new_item(request.form)
    return render_with_notification(
        'partials/item_with_notification.html',
        'Item created successfully',
        'success',
        item=item
    )
```

```html
<!-- Template: partials/item_with_notification.html -->
<div class="item">{{ item.name }}</div>

{% if notification %}
<div id="notifications" hx-swap-oob="beforeend">
    <div class="alert alert-{{ notification.level }}">
        {{ notification.message }}
    </div>
</div>
{% endif %}
```

## Active Search Pattern

```python
@app.route('/search')
def search():
    query = request.args.get('q', '')
    
    if len(query) < 2:
        return ''
    
    results = Item.query.filter(
        Item.name.ilike(f'%{query}%')
    ).limit(10).all()
    
    return render_template('partials/search_results.html', 
                         results=results,
                         query=query)
```

```html
<input type="search" 
       name="q"
       hx-get="/search"
       hx-trigger="keyup changed delay:500ms"
       hx-target="#search-results"
       placeholder="Search...">

<div id="search-results"></div>
```

## Pagination Pattern

```python
@app.route('/items')
def list_items():
    page = request.args.get('page', 1, type=int)
    per_page = 20
    
    items = Item.query.paginate(page=page, per_page=per_page)
    
    return render_template('partials/items_page.html',
                         items=items.items,
                         page=page,
                         has_next=items.has_next,
                         has_prev=items.has_prev)
```

```html
<!-- Template: partials/items_page.html -->
<div id="items-container">
    {% for item in items %}
    <div class="item">{{ item.name }}</div>
    {% endfor %}
</div>

<div id="pagination">
    {% if has_prev %}
    <button hx-get="/items?page={{ page - 1 }}"
            hx-target="#items-container"
            hx-swap="outerHTML">
        Previous
    </button>
    {% endif %}
    
    {% if has_next %}
    <button hx-get="/items?page={{ page + 1 }}"
            hx-target="#items-container"
            hx-swap="outerHTML">
        Next
    </button>
    {% endif %}
</div>
```

## File Upload Pattern

```python
@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return 'No file provided', 400
    
    file = request.files['file']
    
    if file.filename == '':
        return 'No file selected', 400
    
    # Save file
    filename = secure_filename(file.filename)
    filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    file.save(filepath)
    
    # Process file...
    
    return render_template('partials/upload_success.html',
                         filename=filename)
```

```html
<form hx-post="/upload"
      hx-encoding="multipart/form-data"
      hx-target="#result">
    <input type="file" name="file" required>
    <button type="submit">Upload</button>
    
    <progress id="upload-progress" value="0" max="100"></progress>
    <span id="upload-percent"></span>
</form>

<div id="result"></div>

<script>
htmx.on('#upload-form', 'htmx:xhr:progress', function(evt) {
    if (evt.detail.lengthComputable) {
        const percent = (evt.detail.loaded / evt.detail.total) * 100;
        htmx.find('#upload-progress').value = percent;
        htmx.find('#upload-percent').textContent = Math.round(percent) + '%';
    }
});
</script>
```

## Error Handling

### Validation Errors

```python
@app.route('/users', methods=['POST'])
def create_user():
    errors = {}
    
    if not request.form.get('name'):
        errors['name'] = 'Name is required'
    
    if not request.form.get('email'):
        errors['email'] = 'Email is required'
    elif not is_valid_email(request.form['email']):
        errors['email'] = 'Invalid email format'
    
    if errors:
        return render_template('partials/user_form.html',
                             errors=errors,
                             form_data=request.form), 422
    
    # Create user...
    user = create_new_user(request.form)
    return render_template('partials/user_row.html', user=user)
```

```html
<!-- Template: partials/user_form.html -->
<form hx-post="/users" hx-target="this" hx-swap="outerHTML">
    <div>
        <input name="name" value="{{ form_data.get('name', '') }}">
        {% if errors.name %}
        <span class="error">{{ errors.name }}</span>
        {% endif %}
    </div>
    
    <div>
        <input name="email" value="{{ form_data.get('email', '') }}">
        {% if errors.email %}
        <span class="error">{{ errors.email }}</span>
        {% endif %}
    </div>
    
    <button type="submit">Create</button>
</form>
```

### Generic Error Response

```python
@app.errorhandler(404)
def not_found(e):
    if request.headers.get('HX-Request'):
        return render_template('partials/error.html',
                             message='Resource not found'), 404
    return render_template('404.html'), 404

@app.errorhandler(500)
def server_error(e):
    if request.headers.get('HX-Request'):
        return render_template('partials/error.html',
                             message='Server error occurred'), 500
    return render_template('500.html'), 500
```

## Authentication & Authorization

### Checking Authentication

```python
from functools import wraps

def htmx_login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not current_user.is_authenticated:
            if request.headers.get('HX-Request'):
                response = make_response('', 401)
                response.headers['HX-Redirect'] = '/login'
                return response
            return redirect('/login')
        return f(*args, **kwargs)
    return decorated_function

@app.route('/protected')
@htmx_login_required
def protected_route():
    return render_template('partials/protected_content.html')
```

### Permission Checks

```python
@app.route('/admin/users/<int:user_id>', methods=['DELETE'])
def delete_user(user_id):
    if not current_user.is_admin:
        if request.headers.get('HX-Request'):
            return render_template('partials/error.html',
                                 message='Insufficient permissions'), 403
        abort(403)
    
    # Delete user...
    return '', 200
```

## Performance Optimization

### Caching Headers

```python
@app.route('/static-content')
def static_content():
    response = make_response(
        render_template('partials/static.html')
    )
    response.headers['Cache-Control'] = 'public, max-age=3600'
    return response
```

### Debouncing on Server

```python
from datetime import datetime, timedelta

# Simple in-memory rate limiting
request_timestamps = {}

@app.route('/expensive-operation')
def expensive_operation():
    client_id = request.headers.get('HX-Trigger')
    now = datetime.now()
    
    if client_id in request_timestamps:
        last_request = request_timestamps[client_id]
        if now - last_request < timedelta(seconds=2):
            return 'Too many requests', 429
    
    request_timestamps[client_id] = now
    
    # Perform expensive operation...
    result = perform_expensive_operation()
    
    return render_template('partials/result.html', result=result)
```

### Partial Rendering

```python
@app.route('/dashboard')
def dashboard():
    if request.headers.get('HX-Request'):
        # Return only the section being updated
        section = request.args.get('section')
        if section == 'stats':
            return render_template('partials/stats.html')
        elif section == 'activity':
            return render_template('partials/activity.html')
    
    # Return full page
    return render_template('dashboard.html')
```
