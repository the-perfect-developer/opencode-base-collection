"""
custom-control.py — Demonstrates composite custom controls with:
  - Styled controls (@ft.control inheriting a Flet control)
  - Composite controls (combining multiple controls in init())
  - Lifecycle methods: init(), did_mount(), will_unmount()
  - is_isolated=True for controls that call self.update()
  - Async background task via page.run_task()

Run:
    pip install 'flet[all]'
    flet run custom-control.py
"""

import asyncio
import flet as ft


# ── Styled control ─────────────────────────────────────────────────────────────
# Inherits ft.Button and overrides default styling.
# No need for is_isolated because it doesn't call self.update() internally.

@ft.control
class DangerButton(ft.Button):
    """A button pre-styled for destructive actions."""
    bgcolor: ft.Colors = ft.Colors.RED_700
    color: ft.Colors = ft.Colors.WHITE
    style: ft.ButtonStyle = None

    def init(self):
        self.style = ft.ButtonStyle(
            shape=ft.RoundedRectangleBorder(radius=8),
            overlay_color=ft.Colors.with_opacity(0.2, ft.Colors.WHITE),
        )


# ── Composite control ──────────────────────────────────────────────────────────
# Inherits ft.Row and assembles child controls in init().
# Calls self.update() internally → must set is_isolated = True.

@ft.control
class TaskItem(ft.Row):
    """A to-do task row with inline edit/save functionality."""
    text: str = ""
    done: bool = False

    def init(self):
        self._checkbox = ft.Checkbox(
            value=self.done,
            on_change=self._toggle_done,
        )
        self._label = ft.Text(
            value=self.text,
            expand=True,
            color=ft.Colors.GREY_500 if self.done else None,
        )
        self._edit_field = ft.TextField(
            value=self.text,
            expand=True,
            visible=False,
            dense=True,
        )
        self._edit_btn = ft.IconButton(ft.Icons.EDIT, on_click=self._start_edit)
        self._save_btn = ft.IconButton(ft.Icons.SAVE, visible=False, on_click=self._save_edit)
        self._delete_btn = ft.IconButton(ft.Icons.DELETE_OUTLINE, on_click=self._delete)

        self.controls = [
            self._checkbox,
            self._label,
            self._edit_field,
            self._edit_btn,
            self._save_btn,
            self._delete_btn,
        ]
        self.vertical_alignment = ft.CrossAxisAlignment.CENTER

    @property
    def is_isolated(self):
        return True  # required because we call self.update() in handlers

    def _toggle_done(self, e):
        self.done = self._checkbox.value
        self._label.color = ft.Colors.GREY_500 if self.done else None
        self.update()

    def _start_edit(self, e):
        self._label.visible = False
        self._edit_field.visible = True
        self._edit_btn.visible = False
        self._save_btn.visible = True
        self.update()

    def _save_edit(self, e):
        self.text = self._edit_field.value
        self._label.value = self.text
        self._label.visible = True
        self._edit_field.visible = False
        self._edit_btn.visible = True
        self._save_btn.visible = False
        self.update()

    def _delete(self, e):
        # Remove self from parent's controls list
        self.parent.controls.remove(self)
        self.parent.update()


# ── Async lifecycle control ───────────────────────────────────────────────────
# Demonstrates did_mount() starting a background task and
# will_unmount() stopping it cleanly.

@ft.control
class LiveClock(ft.Text):
    """Displays a live clock, updating every second via did_mount()."""

    def init(self):
        self._running = False
        self.size = 20
        self.weight = ft.FontWeight.W_300

    def did_mount(self):
        self._running = True
        self.page.run_task(self._tick)

    def will_unmount(self):
        self._running = False  # signals _tick coroutine to stop

    async def _tick(self):
        import datetime
        while self._running:
            self.value = datetime.datetime.now().strftime("%H:%M:%S")
            self.update()
            await asyncio.sleep(1)


# ── App ────────────────────────────────────────────────────────────────────────

def main(page: ft.Page):
    page.title = "Custom Controls Demo"
    page.theme = ft.Theme(color_scheme_seed=ft.Colors.TEAL)
    page.padding = 20

    task_list = ft.Column(spacing=4)
    new_task_field = ft.TextField(
        hint_text="New task...",
        expand=True,
        on_submit=lambda e: add_task(e),
    )

    def add_task(e):
        if new_task_field.value.strip():
            task_list.controls.append(TaskItem(text=new_task_field.value.strip()))
            new_task_field.value = ""
            page.update()

    def danger_action(e):
        task_list.controls.clear()
        page.update()

    page.add(
        ft.Text("Custom Controls Demo", theme_style=ft.TextThemeStyle.HEADLINE_MEDIUM),
        ft.Divider(),
        ft.Text("Live Clock:", weight=ft.FontWeight.BOLD),
        LiveClock(),
        ft.Divider(),
        ft.Text("Task List:", weight=ft.FontWeight.BOLD),
        ft.Row([new_task_field, ft.IconButton(ft.Icons.ADD, on_click=add_task)]),
        task_list,
        ft.Divider(),
        DangerButton(content="Clear All Tasks", on_click=danger_action),
    )

    # Pre-populate with sample tasks
    for t in ["Buy groceries", "Write unit tests", "Review PR"]:
        task_list.controls.append(TaskItem(text=t))
    page.update()


ft.run(main)
