# Controls and Layout Reference

## Table of Contents

1. [Layout Controls](#layout-controls)
2. [Container Styling](#container-styling)
3. [Stack and Absolute Positioning](#stack-and-absolute-positioning)
4. [Alignment and Spacing](#alignment-and-spacing)
5. [Expanding Controls](#expanding-controls)
6. [Common Input Controls](#common-input-controls)
7. [Display Controls](#display-controls)
8. [Dialog and Overlay Controls](#dialog-and-overlay-controls)
9. [Navigation Controls](#navigation-controls)
10. [Images and Media](#images-and-media)

---

## Layout Controls

### Column

Arranges children vertically. Default layout for `Page`.

```python
ft.Column(
    controls=[ft.Text("A"), ft.Text("B")],
    alignment=ft.MainAxisAlignment.START,       # START, CENTER, END, SPACE_BETWEEN, SPACE_AROUND, SPACE_EVENLY
    horizontal_alignment=ft.CrossAxisAlignment.CENTER,
    spacing=10,       # gap between children in pixels
    scroll=ft.ScrollMode.AUTO,  # enable scrolling
    expand=True,
)
```

### Row

Arranges children horizontally.

```python
ft.Row(
    controls=[ft.Text("Left"), ft.Text("Right")],
    alignment=ft.MainAxisAlignment.SPACE_BETWEEN,
    vertical_alignment=ft.CrossAxisAlignment.CENTER,
    spacing=8,
    wrap=True,   # wraps children to next line if overflow
    scroll=ft.ScrollMode.AUTO,
)
```

### Stack

Overlays children. Children can be positioned absolutely.

```python
ft.Stack(
    controls=[
        ft.Image(src="background.jpg", fit=ft.ImageFit.COVER),
        ft.Text("Overlay text", top=20, left=20),
    ],
    width=400,
    height=300,
)
```

### ListView

Efficiently renders large lists (on-demand). Requires explicit height or `expand=True`.

```python
lv = ft.ListView(
    expand=True,
    spacing=10,
    padding=20,
    item_extent=50,          # fixed item height (boosts performance)
    first_item_prototype=True,  # all items same height as first
    horizontal=False,        # True for horizontal list
)
lv.controls.append(ft.Text("Item"))
```

### GridView

Efficiently renders large grids. Requires explicit height or `expand=True`.

```python
gv = ft.GridView(
    expand=True,
    max_extent=150,          # max tile size (auto-calculates columns)
    runs_count=3,            # fixed number of columns (alternative to max_extent)
    child_aspect_ratio=1.0,  # width:height ratio of each tile
    spacing=10,
    run_spacing=10,
)
```

---

## Container Styling

`ft.Container` is the primary styling wrapper — padding, margin, background, border, shadows, clips, and animations.

```python
ft.Container(
    content=ft.Text("Styled"),
    width=200,
    height=100,
    padding=ft.padding.all(16),
    margin=ft.margin.symmetric(vertical=8),
    bgcolor=ft.Colors.BLUE_100,
    border=ft.border.all(2, ft.Colors.BLUE_400),
    border_radius=ft.border_radius.all(12),
    shadow=ft.BoxShadow(
        spread_radius=1,
        blur_radius=8,
        color=ft.Colors.with_opacity(0.3, ft.Colors.BLACK),
        offset=ft.Offset(0, 4),
    ),
    gradient=ft.LinearGradient(
        begin=ft.alignment.top_left,
        end=ft.alignment.bottom_right,
        colors=[ft.Colors.BLUE, ft.Colors.PURPLE],
    ),
    clip_behavior=ft.ClipBehavior.HARD_EDGE,  # clip content to border radius
    on_click=lambda e: print("clicked"),
)
```

### Padding Shortcuts

```python
ft.padding.all(16)
ft.padding.symmetric(horizontal=8, vertical=4)
ft.padding.only(left=12, right=12, top=8, bottom=8)
```

### Margin Shortcuts

```python
ft.margin.all(8)
ft.margin.symmetric(horizontal=16)
ft.margin.only(top=4, bottom=4)
```

### Border Radius Shortcuts

```python
ft.border_radius.all(8)
ft.border_radius.only(top_left=8, top_right=8)
ft.border_radius.horizontal(left=8, right=8)
ft.border_radius.vertical(top=8, bottom=8)
```

---

## Stack and Absolute Positioning

Position controls absolutely inside a `Stack` or `page.overlay`:

```python
ft.Stack(
    controls=[
        ft.Container(bgcolor=ft.Colors.GREY_200, expand=True),
        ft.Container(
            width=80, height=80,
            bgcolor=ft.Colors.RED,
            border_radius=40,
            top=10,    # distance from top edge
            right=10,  # distance from right edge
        ),
        ft.Text(
            "Label",
            left=20,
            bottom=20,
        ),
    ],
    height=300,
)
```

Position animation only works inside `Stack` or `page.overlay`.

---

## Alignment and Spacing

### MainAxisAlignment (primary axis)

| Value | Description |
|-------|-------------|
| `START` | Pack at start (default) |
| `CENTER` | Center items |
| `END` | Pack at end |
| `SPACE_BETWEEN` | Equal space between items |
| `SPACE_AROUND` | Equal space around items |
| `SPACE_EVENLY` | Equal space including edges |

### CrossAxisAlignment (secondary axis)

| Value | Description |
|-------|-------------|
| `START` | Align to start edge |
| `CENTER` | Center (default) |
| `END` | Align to end edge |
| `STRETCH` | Stretch to fill cross axis |
| `BASELINE` | Align text baselines |

### Page-level alignment

```python
page.vertical_alignment = ft.MainAxisAlignment.CENTER
page.horizontal_alignment = ft.CrossAxisAlignment.CENTER
```

---

## Expanding Controls

Use `expand` to fill available space in parent layout:

```python
# Fills all remaining space
ft.TextField(expand=True)

# Proportional: 2/3 of space vs 1/3
ft.Row(controls=[
    ft.Container(expand=2, bgcolor=ft.Colors.BLUE),
    ft.Container(expand=1, bgcolor=ft.Colors.RED),
])

# Column that expands, with bottom-pinned element
ft.Column(
    expand=True,
    controls=[
        ft.Text("Top content", expand=True),  # pushes footer down
        ft.Text("Footer"),
    ],
)
```

---

## Common Input Controls

### TextField

```python
ft.TextField(
    label="Username",
    hint_text="Enter username",
    value="",
    password=False,
    multiline=False,
    min_lines=1,
    max_lines=5,
    max_length=100,
    keyboard_type=ft.KeyboardType.EMAIL,
    prefix_icon=ft.Icons.PERSON,
    suffix_icon=ft.Icons.CLEAR,
    border=ft.InputBorder.OUTLINE,
    border_color=ft.Colors.BLUE,
    focused_border_color=ft.Colors.BLUE_700,
    on_change=lambda e: print(e.control.value),
    on_submit=lambda e: print("submitted"),
)
```

### Checkbox

```python
ft.Checkbox(
    label="Accept terms",
    value=False,
    on_change=lambda e: print(e.control.value),
)
```

### Dropdown

```python
ft.Dropdown(
    label="Select option",
    value="a",
    options=[
        ft.dropdown.Option("a", "Option A"),
        ft.dropdown.Option("b", "Option B"),
    ],
    on_change=lambda e: print(e.control.value),
)
```

### Slider

```python
ft.Slider(
    min=0,
    max=100,
    value=50,
    divisions=10,
    label="{value}",
    on_change=lambda e: print(e.control.value),
)
```

### Switch

```python
ft.Switch(
    label="Dark mode",
    value=False,
    on_change=lambda e: print(e.control.value),
)
```

---

## Display Controls

### Text Styling

```python
ft.Text(
    "Hello World",
    size=24,
    weight=ft.FontWeight.BOLD,
    color=ft.Colors.BLUE_700,
    italic=True,
    text_align=ft.TextAlign.CENTER,
    theme_style=ft.TextThemeStyle.HEADLINE_MEDIUM,
    overflow=ft.TextOverflow.ELLIPSIS,
    max_lines=2,
    selectable=True,
)
```

`theme_style` values: `DISPLAY_LARGE`, `DISPLAY_MEDIUM`, `DISPLAY_SMALL`, `HEADLINE_LARGE`, `HEADLINE_MEDIUM`, `HEADLINE_SMALL`, `TITLE_LARGE`, `TITLE_MEDIUM`, `TITLE_SMALL`, `BODY_LARGE`, `BODY_MEDIUM`, `BODY_SMALL`, `LABEL_LARGE`, `LABEL_MEDIUM`, `LABEL_SMALL`

### Icon

```python
ft.Icon(ft.Icons.HOME, size=24, color=ft.Colors.BLUE)
```

Access icon catalog: `ft.Icons.<NAME>` — browse at [Material Symbols](https://fonts.google.com/icons).

### ProgressBar / ProgressRing

```python
ft.ProgressBar(value=0.7, width=300)     # 0.0 to 1.0; None = indeterminate
ft.ProgressRing(value=None)               # indeterminate spinner
```

### Divider

```python
ft.Divider(height=1, thickness=1, color=ft.Colors.GREY_300)
ft.VerticalDivider(width=1)
```

---

## Dialog and Overlay Controls

### AlertDialog

```python
def open_dialog(e):
    def close(e):
        page.close(dlg)

    dlg = ft.AlertDialog(
        title=ft.Text("Confirm"),
        content=ft.Text("Are you sure?"),
        actions=[
            ft.TextButton("Yes", on_click=close),
            ft.TextButton("No", on_click=close),
        ],
        actions_alignment=ft.MainAxisAlignment.END,
    )
    page.open(dlg)
```

### SnackBar

```python
page.open(ft.SnackBar(ft.Text("Saved!"), duration=3000))
```

### BottomSheet

```python
page.open(
    ft.BottomSheet(
        content=ft.Column(controls=[ft.Text("Options")]),
        on_dismiss=lambda e: print("dismissed"),
    )
)
```

### page.overlay

Use `page.overlay` for floating controls (e.g., loading spinner):

```python
spinner = ft.ProgressRing()
page.overlay.append(
    ft.Container(spinner, alignment=ft.alignment.center, expand=True)
)
page.update()
# remove later:
page.overlay.clear()
page.update()
```

---

## Navigation Controls

### AppBar

```python
page.appbar = ft.AppBar(
    leading=ft.IconButton(ft.Icons.MENU),
    title=ft.Text("My App"),
    bgcolor=ft.Colors.SURFACE_CONTAINER_HIGHEST,
    actions=[
        ft.IconButton(ft.Icons.SEARCH),
        ft.IconButton(ft.Icons.MORE_VERT),
    ],
)
```

### NavigationBar (bottom tabs)

```python
page.navigation_bar = ft.NavigationBar(
    destinations=[
        ft.NavigationBarDestination(label="Home", icon=ft.Icons.HOME),
        ft.NavigationBarDestination(label="Settings", icon=ft.Icons.SETTINGS),
    ],
    on_change=lambda e: page.go(["/" , "/settings"][e.control.selected_index]),
)
```

### NavigationRail (side rail)

```python
ft.NavigationRail(
    selected_index=0,
    destinations=[
        ft.NavigationRailDestination(label="Home", icon=ft.Icons.HOME),
        ft.NavigationRailDestination(label="Explore", icon=ft.Icons.EXPLORE),
    ],
    on_change=lambda e: print(e.control.selected_index),
    extended=True,  # show labels next to icons
)
```

### NavigationDrawer

```python
page.drawer = ft.NavigationDrawer(
    controls=[
        ft.NavigationDrawerDestination(
            label="Home",
            icon=ft.Icons.HOME_OUTLINED,
            selected_icon=ft.Icons.HOME,
        ),
        ft.Divider(thickness=2),
        ft.NavigationDrawerDestination(label="Settings", icon=ft.Icons.SETTINGS),
    ],
    on_change=lambda e: print(e.control.selected_index),
)
```

---

## Images and Media

```python
# Local asset (place in src/assets/)
ft.Image(src="photo.jpg")

# Remote image
ft.Image(
    src="https://picsum.photos/200/200",
    width=200,
    height=200,
    fit=ft.ImageFit.COVER,     # NONE, CONTAIN, COVER, FILL, FIT_HEIGHT, FIT_WIDTH, SCALE_DOWN
    repeat=ft.ImageRepeat.NO_REPEAT,
    border_radius=ft.border_radius.all(10),
    tooltip="Description",
)

# Cache-busting
import time
ft.Image(src=f"https://picsum.photos/200?ts={time.time()}")

# Base64 encoded
ft.Image(src_base64="iVBORw0KGgo...")
```
