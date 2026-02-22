# Patterns and Best Practices

## Table of Contents

1. [State Management Patterns](#state-management-patterns)
2. [Storage: Session and Client](#storage-session-and-client)
3. [PubSub for Multi-User Apps](#pubsub-for-multi-user-apps)
4. [Keyboard Shortcuts](#keyboard-shortcuts)
5. [Error Handling and Logging](#error-handling-and-logging)
6. [Adaptive Apps (Cross-Platform)](#adaptive-apps-cross-platform)
7. [Drag and Drop](#drag-and-drop)
8. [Fonts](#fonts)
9. [Platform Detection](#platform-detection)
10. [Performance Checklist](#performance-checklist)

---

## State Management Patterns

Flet uses an imperative update model. State mutations require explicit `update()` calls.

### Closure-Based State

For simple apps, closures over `page` and control variables work well:

```python
def main(page: ft.Page):
    count = 0
    counter_text = ft.Text("0", size=40)

    def increment(e):
        nonlocal count
        count += 1
        counter_text.value = str(count)
        counter_text.update()

    page.add(counter_text, ft.Button("+", on_click=increment))
```

### Class-Based State in Custom Controls

Encapsulate state inside composite custom controls. This is the recommended approach for complex components:

```python
@ft.control
class Counter(ft.Column):
    start: int = 0

    def init(self):
        self._count = self.start
        self.display = ft.Text(str(self._count), size=40)
        self.controls = [
            self.display,
            ft.Row([
                ft.IconButton(ft.Icons.REMOVE, on_click=self._dec),
                ft.IconButton(ft.Icons.ADD, on_click=self._inc),
            ]),
        ]

    def _inc(self, e):
        self._count += 1
        self.display.value = str(self._count)
        self.update()

    def _dec(self, e):
        self._count -= 1
        self.display.value = str(self._count)
        self.update()

    @property
    def is_isolated(self):
        return True
```

### before_update() for Derived State

Use `before_update()` to sync derived display state before every render:

```python
@ft.control
class StatusBadge(ft.Container):
    active: bool = True

    def before_update(self):
        self.bgcolor = ft.Colors.GREEN if self.active else ft.Colors.RED
        # Do NOT call self.update() here — it would cause infinite loop
```

---

## Storage: Session and Client

### Session Storage

Per-user, server-side, ephemeral. Available only while the session is alive.

```python
# Store
page.session.set("user_id", 42)
page.session.set("prefs", {"theme": "dark"})

# Read
user_id = page.session.get("user_id")  # None if not set

# Check and remove
if page.session.contains_key("user_id"):
    page.session.remove("user_id")
```

### Client Storage

Persisted on the client device (browser localStorage or app file). Survives sessions.

```python
# Async API (preferred in async apps)
async def main(page: ft.Page):
    await page.client_storage.set_async("theme", "dark")
    theme = await page.client_storage.get_async("theme")
    await page.client_storage.remove_async("theme")
    keys = await page.client_storage.get_keys_async("app.")  # prefix filter
    await page.client_storage.clear_async()

# Sync API (in sync apps)
page.client_storage.set("key", "value")
value = page.client_storage.get("key")
```

**Key naming**: Use namespaced keys (e.g., `"myapp.user.theme"`) to avoid collisions.

---

## PubSub for Multi-User Apps

`page.pubsub` enables broadcasting messages between concurrent user sessions (e.g., a chat app).

```python
def main(page: ft.Page):
    chat_log = ft.ListView(expand=True)
    msg_field = ft.TextField(expand=True, hint_text="Message...")

    # Subscribe: receive messages from other sessions
    def on_message(msg):
        chat_log.controls.append(ft.Text(msg))
        chat_log.update()

    page.pubsub.subscribe(on_message)

    def send(e):
        page.pubsub.send_all(f"{page.session.get('name')}: {msg_field.value}")
        msg_field.value = ""
        msg_field.update()

    page.add(chat_log, ft.Row([msg_field, ft.IconButton(ft.Icons.SEND, on_click=send)]))

ft.run(main)
```

**Rules**:
- `send_all(msg)` — broadcasts to all subscribers including sender
- `send_others(msg)` — broadcasts excluding sender
- Always unsubscribe in `will_unmount()` or `page.on_disconnect` to avoid leaks

---

## Keyboard Shortcuts

```python
import flet as ft

def main(page: ft.Page):
    def on_keyboard(e: ft.KeyboardEvent):
        if e.key == "S" and e.ctrl:
            print("Save triggered")
        elif e.key == "Escape":
            print("Escape pressed")
        elif e.key == "F" and e.ctrl and e.shift:
            print("Find all")

    page.on_keyboard_event = on_keyboard
    page.update()
```

**Event fields**: `e.key` (string), `e.shift` (bool), `e.ctrl` (bool), `e.alt` (bool), `e.meta` (bool)

**Common key names**: `"Enter"`, `"Escape"`, `"Tab"`, `"Backspace"`, `"Delete"`, `"Arrow Up"`, `"Arrow Down"`, `"Arrow Left"`, `"Arrow Right"`, `"F1"`–`"F12"`, `" "` (space), letter/digit keys as uppercase strings

---

## Error Handling and Logging

### Page-Level Error Handler

```python
def main(page: ft.Page):
    page.on_error = lambda e: print(f"Page error: {e.data}")
```

### Python Logging

```python
import logging

logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s %(levelname)s %(name)s: %(message)s",
)
logger = logging.getLogger(__name__)

def main(page: ft.Page):
    logger.info("App started")

    def risky_operation(e):
        try:
            result = do_something()
            logger.debug("Result: %s", result)
        except Exception as exc:
            logger.exception("Operation failed")
            page.open(ft.SnackBar(ft.Text(f"Error: {exc}")))

    page.add(ft.Button("Run", on_click=risky_operation))
```

### Validation Pattern

```python
def validate_and_submit(e):
    errors = []
    if not name_field.value:
        errors.append("Name is required")
    if len(password_field.value) < 8:
        errors.append("Password must be at least 8 characters")

    if errors:
        error_text.value = " | ".join(errors)
        error_text.visible = True
        error_text.update()
        return

    error_text.visible = False
    # proceed with submission
    submit()
```

---

## Adaptive Apps (Cross-Platform)

Flet apps run on Desktop, Web, iOS, and Android. Detect platform in `build()` for conditional UI:

```python
@ft.control
class AdaptiveButton(ft.Control):
    label: str = ""

    def build(self):
        if self.page.platform in (ft.PagePlatform.IOS, ft.PagePlatform.MACOS):
            return ft.CupertinoButton(content=ft.Text(self.label))
        return ft.Button(content=self.label)
```

### Platform Values

| `page.platform` | Description |
|-----------------|-------------|
| `ft.PagePlatform.IOS` | iPhone/iPad |
| `ft.PagePlatform.ANDROID` | Android |
| `ft.PagePlatform.MACOS` | macOS desktop |
| `ft.PagePlatform.WINDOWS` | Windows desktop |
| `ft.PagePlatform.LINUX` | Linux desktop |
| `ft.PagePlatform.FUCHSIA` | Fuchsia |

### Responsive Layout

```python
def main(page: ft.Page):
    def page_resize(e):
        # Adapt layout based on window width
        if page.window.width < 600:
            layout.direction = ft.Axis.VERTICAL
        else:
            layout.direction = ft.Axis.HORIZONTAL
        layout.update()

    page.on_resize = page_resize
```

---

## Drag and Drop

```python
def main(page: ft.Page):
    def drag_accept(e: ft.DragTargetAcceptEvent):
        src = page.get_control(e.src_id)
        src.top = e.y - 20
        src.left = e.x - 20
        src.update()

    page.add(
        ft.Stack(
            controls=[
                ft.DragTarget(
                    group="items",
                    content=ft.Container(
                        bgcolor=ft.Colors.GREY_200,
                        expand=True,
                    ),
                    on_accept=drag_accept,
                ),
                ft.Draggable(
                    group="items",
                    content=ft.Container(
                        width=40, height=40,
                        bgcolor=ft.Colors.BLUE,
                        border_radius=5,
                        top=100, left=100,
                    ),
                ),
            ],
            expand=True,
        )
    )
```

**Rules**:
- `Draggable` and `DragTarget` must share the same `group`
- Use `DragTarget.on_will_accept` to provide visual feedback before drop
- Use `DragTarget.on_leave` to reset visual feedback

---

## Fonts

### System Fonts

Reference built-in Flutter system fonts directly by name.

### Custom Fonts

Place font files in `src/assets/fonts/` and register before `ft.run`:

```python
def main(page: ft.Page):
    page.fonts = {
        "Roboto Mono": "fonts/RobotoMono-Regular.ttf",
        "Kanit Bold": "fonts/Kanit-Bold.ttf",
    }
    page.theme = ft.Theme(font_family="Roboto Mono")  # set as default
    page.add(ft.Text("Custom font", font_family="Kanit Bold", size=20))

ft.run(main, assets_dir="assets")
```

### Google Fonts

With `flet[all]` installed:

```python
page.fonts = {
    "Noto Sans": "https://fonts.gstatic.com/s/notosans/v28/o-0IIpQlx3QUlC5A4PNr5TRA.woff2"
}
```

---

## Platform Detection

```python
def main(page: ft.Page):
    print("Platform:", page.platform)
    print("Web:", page.web)           # True if running in browser
    print("PWA:", page.pwa)           # True if installed as PWA

    # Open URL in external browser
    page.launch_url("https://flet.dev")

    # Clipboard
    page.set_clipboard("Copied text!")
    text = page.get_clipboard()
```

---

## Performance Checklist

| Issue | Solution |
|-------|----------|
| Slow render of many controls | Use `ListView`/`GridView` instead of `Column`/`Row` |
| Large WebSocket messages | Use batch updates (update every N items) |
| Unnecessary full-page updates | Call `control.update()` not `page.update()` |
| Background tasks blocking UI | Use `async`/`await` and `page.run_task()` |
| Custom control re-rendering parent | Set `is_isolated = True` |
| Memory leaks in multi-user | Unsubscribe `page.pubsub` on disconnect |
| Slow image loading | Set fixed `width`/`height` on `Image` controls |
| Layout jank on resize | Use `expand=True` + proportional `expand` values |

### Update Batching Example

```python
async def load_data(page: ft.Page, lv: ft.ListView):
    for i, item in enumerate(large_dataset):
        lv.controls.append(ft.Text(item))
        if i % 100 == 0:
            page.update()
            await asyncio.sleep(0)  # yield to event loop
    page.update()
```

### Isolating Expensive Custom Controls

```python
@ft.control
class ExpensiveWidget(ft.Column):
    @property
    def is_isolated(self):
        return True   # parent update() won't re-render this subtree

    def refresh_data(self):
        # ... fetch and rebuild controls ...
        self.update()  # only this widget is sent in the diff
```
