"""
counter-app.py — Minimal Flet counter demonstrating:
  - Page setup (title, alignment, theme)
  - TextField for display
  - IconButton event handlers with on_click
  - Row layout with MainAxisAlignment.CENTER
  - ft.run(main) entry point

Run:
    pip install 'flet[all]'
    flet run counter-app.py
    flet run --web counter-app.py
"""

import flet as ft


def main(page: ft.Page):
    page.title = "Counter"
    page.vertical_alignment = ft.MainAxisAlignment.CENTER
    page.horizontal_alignment = ft.CrossAxisAlignment.CENTER
    page.theme = ft.Theme(color_scheme_seed=ft.Colors.DEEP_PURPLE)
    page.theme_mode = ft.ThemeMode.LIGHT

    # Display — TextField gives numeric keyboard on mobile
    counter_display = ft.TextField(
        value="0",
        text_align=ft.TextAlign.RIGHT,
        width=120,
        read_only=True,
        text_size=32,
        border=ft.InputBorder.NONE,
    )

    def minus_click(e):
        counter_display.value = str(int(counter_display.value) - 1)
        counter_display.update()  # prefer control.update() over page.update()

    def plus_click(e):
        counter_display.value = str(int(counter_display.value) + 1)
        counter_display.update()

    page.add(
        ft.Card(
            content=ft.Container(
                padding=ft.padding.all(24),
                content=ft.Row(
                    alignment=ft.MainAxisAlignment.CENTER,
                    vertical_alignment=ft.CrossAxisAlignment.CENTER,
                    controls=[
                        ft.IconButton(
                            ft.Icons.REMOVE_CIRCLE_OUTLINE,
                            icon_size=36,
                            on_click=minus_click,
                            tooltip="Decrement",
                        ),
                        counter_display,
                        ft.IconButton(
                            ft.Icons.ADD_CIRCLE_OUTLINE,
                            icon_size=36,
                            on_click=plus_click,
                            tooltip="Increment",
                        ),
                    ],
                ),
            )
        )
    )


ft.run(main)
