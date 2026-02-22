---
name: python-flet
description: This skill should be used when the user asks to "build a Flet app", "create a Python GUI", "use Flet framework", "write a Flet control", or needs guidance on cross-platform Python UI development with Flet.
---

# Python Flet Development

Flet is a Python framework for building cross-platform web, desktop, and mobile applications without prior frontend experience. It wraps Flutter widgets and exposes them as Python controls.

## App Entry Point

Every Flet app has a `main` function receiving a `ft.Page` and ends with `ft.run(main)`:

```python
import flet as ft

def main(page: ft.Page):
    page.title = "My App"
    page.add(ft.Text("Hello, Flet!"))

ft.run(main)
```

**Installation**: `pip install 'flet[all]'`

**Run desktop**: `flet run main.py`

**Run web**: `flet run --web main.py`

**Hot reload** (watch directory recursively): `flet run --recursive main.py`

## Project Structure

```
my-app/
├── pyproject.toml
└── src/
    ├── assets/
    │   └── icon.png
    └── main.py
```

Create via: `flet create` (or `uv run flet create`)

## Core Concepts

### Page

`ft.Page` is the root container. Configure it before adding controls:

```python
def main(page: ft.Page):
    page.title = "App Title"
    page.theme_mode = ft.ThemeMode.LIGHT
    page.theme = ft.Theme(color_scheme_seed=ft.Colors.BLUE)
    page.vertical_alignment = ft.MainAxisAlignment.CENTER
    page.horizontal_alignment = ft.CrossAxisAlignment.CENTER
    page.scroll = ft.ScrollMode.AUTO
```

### Controls and `update()`

Controls are Python objects. Mutations require `page.update()` or `control.update()`:

```python
text = ft.Text("Initial")
page.add(text)

def change(e):
    text.value = "Changed"
    text.update()          # prefer: update only this control
    # page.update()        # fallback: updates entire page
```

**Rule**: Prefer `control.update()` over `page.update()` — sends a smaller diff.

### Layout Controls

| Control | Purpose |
|---------|---------|
| `ft.Column` | Vertical stack |
| `ft.Row` | Horizontal stack |
| `ft.Stack` | Absolute positioning |
| `ft.Container` | Box with padding, color, border, animation |
| `ft.ListView` | Efficient vertical/horizontal scrollable list |
| `ft.GridView` | Efficient scrollable grid |

```python
page.add(
    ft.Row(
        controls=[ft.Text("Left"), ft.Text("Right")],
        alignment=ft.MainAxisAlignment.SPACE_BETWEEN,
    )
)
```

**Expand**: Use `expand=True` to fill available space:

```python
ft.ListView(expand=True, spacing=10)
```

## Custom Controls

### Styled Controls (inherit a single Flet control)

```python
@ft.control
class PrimaryButton(ft.Button):
    bgcolor: ft.Colors = ft.Colors.BLUE_700
    color: ft.Colors = ft.Colors.WHITE
```

Use `@ft.control` or `@dataclass` decorator. Field types must be annotated.

### Composite Controls (combine multiple controls)

```python
@ft.control
class TaskItem(ft.Row):
    text: str = ""

    def init(self):
        self.checkbox = ft.Checkbox()
        self.label = ft.Text(value=self.text)
        self.controls = [self.checkbox, self.label]

    def toggle(self, e):
        self.label.color = ft.Colors.GREY if self.checkbox.value else None
        self.update()
```

### Lifecycle Methods

| Method | When called | Use for |
|--------|-------------|---------|
| `init()` | After `__init__` | Setup sub-controls |
| `build()` | When assigned `self.page` | Platform-dependent logic |
| `did_mount()` | After added to page | Start timers, fetch data |
| `will_unmount()` | Before removed | Clean up, cancel tasks |
| `before_update()` | Every `update()` | Sync derived state |

**Isolation rule**: Any custom control that calls `self.update()` inside its own methods must set `is_isolated = True` (or override `is_isolated` property to return `True`).

## Navigation and Routing

Use `page.on_route_change` + `page.views` as the single source of truth:

```python
def main(page: ft.Page):
    def route_change():
        page.views.clear()
        page.views.append(ft.View("/", controls=[...]))
        if page.route == "/settings":
            page.views.append(ft.View("/settings", controls=[...]))
        page.update()

    async def view_pop(e):
        page.views.remove(e.view)
        await page.push_route(page.views[-1].route)

    page.on_route_change = route_change
    page.on_view_pop = view_pop
    route_change()

ft.run(main)
```

**Navigate**: `await page.push_route("/settings")`

**Parameterized routes**:
```python
troute = ft.TemplateRoute(page.route)
if troute.match("/items/:id"):
    print(troute.id)
```

**Routing rules**:
- Always keep a root `/` view in `page.views`
- Centralize all route logic in `page.on_route_change`
- Always handle `page.on_view_pop` to stay in sync

## Theming

```python
# App-wide theme
page.theme = ft.Theme(color_scheme_seed=ft.Colors.GREEN)
page.dark_theme = ft.Theme(color_scheme_seed=ft.Colors.BLUE)
page.theme_mode = ft.ThemeMode.SYSTEM  # LIGHT | DARK | SYSTEM

# Nested theme (scoped to a container)
ft.Container(
    theme=ft.Theme(color_scheme=ft.ColorScheme(primary=ft.Colors.PINK)),
    content=ft.Button("Pink button"),
)
```

## Async Apps

Mark `main` async for `asyncio` support. Use `asyncio.sleep()` (not `time.sleep()`).

```python
import asyncio
import flet as ft

async def main(page: ft.Page):
    async def on_click(e):
        await asyncio.sleep(1)
        page.add(ft.Text("Done!"))

    page.add(ft.Button("Click me", on_click=on_click))

ft.run(main)
```

Use `page.run_task(coro)` to run background coroutines from `did_mount()`.

## Performance: Large Lists

Use `ListView` or `GridView` instead of `Column`/`Row` for hundreds of items:

```python
# Efficient: renders only visible items
lv = ft.ListView(expand=True, spacing=10, item_extent=50)
for i in range(5000):
    lv.controls.append(ft.Text(f"Line {i}"))
page.add(lv)

# Batch updates to avoid large WebSocket messages
for i in range(5000):
    lv.controls.append(ft.Text(f"Line {i}"))
    if i % 500 == 0:
        page.update()
page.update()
```

## Implicit Animations

Enable by setting `animate_*` properties on controls:

```python
# Opacity fade
container = ft.Container(
    width=150, height=150,
    bgcolor=ft.Colors.BLUE,
    animate_opacity=300,  # ms
)

# Scale with bounce curve
ft.Container(
    animate_scale=ft.Animation(
        duration=600,
        curve=ft.AnimationCurve.BOUNCE_OUT,
    )
)

# Position animation (inside Stack or page.overlay)
ft.Container(animate_position=1000)

# Animated content switcher
ft.AnimatedSwitcher(
    content,
    transition=ft.AnimatedSwitcherTransition.SCALE,
    duration=500,
)
```

## Window Control (Desktop)

```python
page.title = "My App"
page.window.width = 800
page.window.height = 600
page.window.resizable = True
page.window.always_on_top = False
page.window.center()
```

## Quick Reference: Common Controls

```python
ft.Text("Hello", size=20, weight=ft.FontWeight.BOLD)
ft.Button("Click", on_click=handler)
ft.IconButton(ft.Icons.ADD, on_click=handler)
ft.TextField(label="Name", on_change=handler)
ft.Checkbox(label="Check me", on_change=handler)
ft.Dropdown(options=[ft.dropdown.Option("A"), ft.dropdown.Option("B")])
ft.Image(src="photo.jpg")                   # from assets/
ft.Image(src="https://example.com/img.png") # remote
ft.AppBar(title=ft.Text("Title"))
ft.NavigationDrawer(controls=[...])
ft.AlertDialog(title=ft.Text("Alert"), content=ft.Text("Body"))
```

## Additional Resources

### Reference Files

- **`references/controls-and-layout.md`** - Complete layout patterns, Container styling, Stack positioning, and control properties
- **`references/patterns-and-best-practices.md`** - State management, session/client storage, PubSub, keyboard shortcuts, error handling

### Example Files

- **`examples/counter-app.py`** - Minimal working counter demonstrating page setup and event handlers
- **`examples/custom-control.py`** - Composite custom control with lifecycle methods and isolation
