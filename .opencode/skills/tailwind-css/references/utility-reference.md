# Utility Class Reference

Comprehensive reference of Tailwind CSS utility classes organized by category.

## Table of Contents

- [Layout](#layout)
- [Flexbox & Grid](#flexbox--grid)
- [Spacing](#spacing)
- [Sizing](#sizing)
- [Typography](#typography)
- [Colors](#colors)
- [Backgrounds](#backgrounds)
- [Borders](#borders)
- [Effects](#effects)
- [Filters](#filters)
- [Transitions & Animation](#transitions--animation)
- [Transforms](#transforms)
- [Interactivity](#interactivity)

## Layout

### Display

| Class | CSS Property | Description |
|-------|--------------|-------------|
| `block` | `display: block` | Block-level element |
| `inline-block` | `display: inline-block` | Inline block element |
| `inline` | `display: inline` | Inline element |
| `flex` | `display: flex` | Flexbox container |
| `inline-flex` | `display: inline-flex` | Inline flexbox |
| `grid` | `display: grid` | Grid container |
| `inline-grid` | `display: inline-grid` | Inline grid |
| `hidden` | `display: none` | Hide element |

### Position

| Class | CSS Property | Description |
|-------|--------------|-------------|
| `static` | `position: static` | Default positioning |
| `fixed` | `position: fixed` | Fixed positioning |
| `absolute` | `position: absolute` | Absolute positioning |
| `relative` | `position: relative` | Relative positioning |
| `sticky` | `position: sticky` | Sticky positioning |

### Top / Right / Bottom / Left

Use with position utilities:

```html
<!-- Positioning examples -->
<div class="absolute top-0 right-0">
<div class="fixed bottom-4 left-4">
<div class="relative top-1/2 left-1/2">
```

Values: `0`, `1`, `2`, `3`, `4`, `6`, `8`, `10`, `12`, `16`, `20`, `24`, `32`, `40`, `48`, `56`, `64`, `auto`, fractions (`1/2`, `1/3`, `1/4`, etc.)

### Z-Index

| Class | CSS Value | Description |
|-------|-----------|-------------|
| `z-0` | `z-index: 0` | Default stacking |
| `z-10` | `z-index: 10` | Layer 10 |
| `z-20` | `z-index: 20` | Layer 20 |
| `z-30` | `z-index: 30` | Layer 30 |
| `z-40` | `z-index: 40` | Layer 40 |
| `z-50` | `z-index: 50` | Layer 50 |
| `z-auto` | `z-index: auto` | Auto stacking |

### Overflow

| Class | CSS Property | Description |
|-------|--------------|-------------|
| `overflow-auto` | `overflow: auto` | Auto scrollbars |
| `overflow-hidden` | `overflow: hidden` | Hide overflow |
| `overflow-visible` | `overflow: visible` | Show overflow |
| `overflow-scroll` | `overflow: scroll` | Always scrollbars |
| `overflow-x-auto` | `overflow-x: auto` | Horizontal auto |
| `overflow-y-auto` | `overflow-y: auto` | Vertical auto |

## Flexbox & Grid

### Flex Direction

| Class | CSS Property | Description |
|-------|--------------|-------------|
| `flex-row` | `flex-direction: row` | Horizontal layout |
| `flex-row-reverse` | `flex-direction: row-reverse` | Reverse horizontal |
| `flex-col` | `flex-direction: column` | Vertical layout |
| `flex-col-reverse` | `flex-direction: column-reverse` | Reverse vertical |

### Flex Wrap

| Class | CSS Property | Description |
|-------|--------------|-------------|
| `flex-wrap` | `flex-wrap: wrap` | Allow wrapping |
| `flex-wrap-reverse` | `flex-wrap: wrap-reverse` | Reverse wrap |
| `flex-nowrap` | `flex-wrap: nowrap` | Prevent wrapping |

### Align Items

| Class | CSS Property | Description |
|-------|--------------|-------------|
| `items-start` | `align-items: flex-start` | Align to start |
| `items-end` | `align-items: flex-end` | Align to end |
| `items-center` | `align-items: center` | Center items |
| `items-baseline` | `align-items: baseline` | Baseline align |
| `items-stretch` | `align-items: stretch` | Stretch items |

### Justify Content

| Class | CSS Property | Description |
|-------|--------------|-------------|
| `justify-start` | `justify-content: flex-start` | Pack to start |
| `justify-end` | `justify-content: flex-end` | Pack to end |
| `justify-center` | `justify-content: center` | Center items |
| `justify-between` | `justify-content: space-between` | Space between |
| `justify-around` | `justify-content: space-around` | Space around |
| `justify-evenly` | `justify-content: space-evenly` | Even spacing |

### Gap

| Class | Spacing | Description |
|-------|---------|-------------|
| `gap-0` | `gap: 0` | No gap |
| `gap-1` | `gap: 0.25rem` | 4px gap |
| `gap-2` | `gap: 0.5rem` | 8px gap |
| `gap-4` | `gap: 1rem` | 16px gap |
| `gap-6` | `gap: 1.5rem` | 24px gap |
| `gap-8` | `gap: 2rem` | 32px gap |
| `gap-x-4` | `column-gap: 1rem` | Horizontal gap |
| `gap-y-4` | `row-gap: 1rem` | Vertical gap |

Full scale: `0`, `0.5`, `1`, `1.5`, `2`, `2.5`, `3`, `3.5`, `4`, `5`, `6`, `7`, `8`, `9`, `10`, `11`, `12`, `14`, `16`, `20`, `24`, `28`, `32`, `36`, `40`, `44`, `48`, `52`, `56`, `60`, `64`, `72`, `80`, `96`

### Grid Template Columns

| Class | CSS Property | Description |
|-------|--------------|-------------|
| `grid-cols-1` | `grid-template-columns: repeat(1, 1fr)` | 1 column |
| `grid-cols-2` | `grid-template-columns: repeat(2, 1fr)` | 2 columns |
| `grid-cols-3` | `grid-template-columns: repeat(3, 1fr)` | 3 columns |
| `grid-cols-4` | `grid-template-columns: repeat(4, 1fr)` | 4 columns |
| `grid-cols-6` | `grid-template-columns: repeat(6, 1fr)` | 6 columns |
| `grid-cols-12` | `grid-template-columns: repeat(12, 1fr)` | 12 columns |

Available: `1` through `12`

### Grid Column Span

| Class | CSS Property | Description |
|-------|--------------|-------------|
| `col-span-1` | `grid-column: span 1 / span 1` | Span 1 column |
| `col-span-2` | `grid-column: span 2 / span 2` | Span 2 columns |
| `col-span-3` | `grid-column: span 3 / span 3` | Span 3 columns |
| `col-span-full` | `grid-column: 1 / -1` | Span all columns |

## Spacing

### Padding

All sides:
```html
<div class="p-0">   <!-- 0 -->
<div class="p-4">   <!-- 1rem / 16px -->
<div class="p-8">   <!-- 2rem / 32px -->
```

Horizontal/Vertical:
```html
<div class="px-4">  <!-- padding-left and padding-right -->
<div class="py-4">  <!-- padding-top and padding-bottom -->
```

Individual sides:
```html
<div class="pt-4">  <!-- padding-top -->
<div class="pr-4">  <!-- padding-right -->
<div class="pb-4">  <!-- padding-bottom -->
<div class="pl-4">  <!-- padding-left -->
```

Scale: `0`, `0.5`, `1`, `1.5`, `2`, `2.5`, `3`, `3.5`, `4`, `5`, `6`, `7`, `8`, `9`, `10`, `11`, `12`, `14`, `16`, `20`, `24`, `28`, `32`, `36`, `40`, `44`, `48`, `52`, `56`, `60`, `64`, `72`, `80`, `96`

### Margin

Same pattern as padding:
```html
<div class="m-4">    <!-- all sides -->
<div class="mx-auto"> <!-- horizontal centering -->
<div class="my-4">   <!-- vertical -->
<div class="mt-4">   <!-- top -->
<div class="-m-4">   <!-- negative margin -->
```

Negative margins available: `-m-1`, `-mt-2`, `-mx-4`, etc.

### Space Between

Add spacing between child elements:
```html
<div class="space-x-4">  <!-- horizontal spacing -->
<div class="space-y-4">  <!-- vertical spacing -->
```

## Sizing

### Width

| Class | CSS Property | Description |
|-------|--------------|-------------|
| `w-0` | `width: 0` | Zero width |
| `w-auto` | `width: auto` | Auto width |
| `w-full` | `width: 100%` | Full width |
| `w-screen` | `width: 100vw` | Viewport width |
| `w-1/2` | `width: 50%` | Half width |
| `w-1/3` | `width: 33.333%` | Third width |
| `w-2/3` | `width: 66.667%` | Two-thirds |
| `w-1/4` | `width: 25%` | Quarter width |

Fixed sizes: `w-4` (1rem), `w-8` (2rem), `w-12` (3rem), `w-16` (4rem), etc.

### Height

Same pattern as width:
```html
<div class="h-screen">   <!-- 100vh -->
<div class="h-full">     <!-- 100% -->
<div class="h-1/2">      <!-- 50% -->
<div class="h-12">       <!-- 3rem -->
```

### Max Width

| Class | Max Width | Description |
|-------|-----------|-------------|
| `max-w-none` | `none` | No maximum |
| `max-w-xs` | `20rem` | Extra small |
| `max-w-sm` | `24rem` | Small |
| `max-w-md` | `28rem` | Medium |
| `max-w-lg` | `32rem` | Large |
| `max-w-xl` | `36rem` | Extra large |
| `max-w-2xl` | `42rem` | 2XL |
| `max-w-4xl` | `56rem` | 4XL |
| `max-w-7xl` | `80rem` | 7XL |
| `max-w-full` | `100%` | Full width |
| `max-w-screen-sm` | `640px` | Small screen |
| `max-w-screen-lg` | `1024px` | Large screen |

### Min/Max Height

```html
<div class="min-h-screen">   <!-- 100vh minimum -->
<div class="min-h-full">     <!-- 100% minimum -->
<div class="max-h-screen">   <!-- 100vh maximum -->
```

## Typography

### Font Size

| Class | Font Size | Line Height |
|-------|-----------|-------------|
| `text-xs` | `0.75rem` (12px) | `1rem` |
| `text-sm` | `0.875rem` (14px) | `1.25rem` |
| `text-base` | `1rem` (16px) | `1.5rem` |
| `text-lg` | `1.125rem` (18px) | `1.75rem` |
| `text-xl` | `1.25rem` (20px) | `1.75rem` |
| `text-2xl` | `1.5rem` (24px) | `2rem` |
| `text-3xl` | `1.875rem` (30px) | `2.25rem` |
| `text-4xl` | `2.25rem` (36px) | `2.5rem` |
| `text-5xl` | `3rem` (48px) | `1` |
| `text-6xl` | `3.75rem` (60px) | `1` |
| `text-9xl` | `8rem` (128px) | `1` |

### Font Weight

| Class | Font Weight | Description |
|-------|-------------|-------------|
| `font-thin` | `100` | Thin |
| `font-extralight` | `200` | Extra light |
| `font-light` | `300` | Light |
| `font-normal` | `400` | Normal |
| `font-medium` | `500` | Medium |
| `font-semibold` | `600` | Semi bold |
| `font-bold` | `700` | Bold |
| `font-extrabold` | `800` | Extra bold |
| `font-black` | `900` | Black |

### Text Alignment

| Class | CSS Property | Description |
|-------|--------------|-------------|
| `text-left` | `text-align: left` | Left align |
| `text-center` | `text-align: center` | Center align |
| `text-right` | `text-align: right` | Right align |
| `text-justify` | `text-align: justify` | Justify |

### Text Color

Color palette with shades from 50-950:

```html
<!-- Primary colors -->
<p class="text-gray-500">
<p class="text-red-500">
<p class="text-blue-500">
<p class="text-green-500">
<p class="text-yellow-500">

<!-- Shades -->
<p class="text-gray-50">    <!-- Lightest -->
<p class="text-gray-500">   <!-- Medium -->
<p class="text-gray-900">   <!-- Darkest -->
<p class="text-gray-950">   <!-- Extra dark -->
```

Colors: `gray`, `red`, `orange`, `amber`, `yellow`, `lime`, `green`, `emerald`, `teal`, `cyan`, `sky`, `blue`, `indigo`, `violet`, `purple`, `fuchsia`, `pink`, `rose`

Shades: `50`, `100`, `200`, `300`, `400`, `500`, `600`, `700`, `800`, `900`, `950`

### Line Height

| Class | Line Height | Description |
|-------|-------------|-------------|
| `leading-none` | `1` | No line height |
| `leading-tight` | `1.25` | Tight spacing |
| `leading-snug` | `1.375` | Snug spacing |
| `leading-normal` | `1.5` | Normal spacing |
| `leading-relaxed` | `1.625` | Relaxed |
| `leading-loose` | `2` | Loose spacing |

### Text Decoration

| Class | CSS Property | Description |
|-------|--------------|-------------|
| `underline` | `text-decoration: underline` | Underline text |
| `overline` | `text-decoration: overline` | Overline text |
| `line-through` | `text-decoration: line-through` | Strike through |
| `no-underline` | `text-decoration: none` | No decoration |

### Text Transform

| Class | CSS Property | Description |
|-------|--------------|-------------|
| `uppercase` | `text-transform: uppercase` | ALL CAPS |
| `lowercase` | `text-transform: lowercase` | all lower |
| `capitalize` | `text-transform: capitalize` | First Letter |
| `normal-case` | `text-transform: none` | No transform |

### Text Overflow

| Class | CSS Properties | Description |
|-------|----------------|-------------|
| `truncate` | `overflow: hidden; text-overflow: ellipsis; white-space: nowrap` | Truncate with ellipsis |
| `text-ellipsis` | `text-overflow: ellipsis` | Ellipsis overflow |
| `text-clip` | `text-overflow: clip` | Clip overflow |

## Colors

### Background Color

Same color palette as text colors:

```html
<div class="bg-white">
<div class="bg-gray-100">
<div class="bg-blue-500">
<div class="bg-red-600">
```

### Border Color

```html
<div class="border border-gray-300">
<div class="border-2 border-blue-500">
<div class="border-t border-red-500">
```

### Opacity

| Class | Opacity | Description |
|-------|---------|-------------|
| `opacity-0` | `0` | Fully transparent |
| `opacity-25` | `0.25` | 25% opaque |
| `opacity-50` | `0.5` | 50% opaque |
| `opacity-75` | `0.75` | 75% opaque |
| `opacity-100` | `1` | Fully opaque |

Available: `0`, `5`, `10`, `20`, `25`, `30`, `40`, `50`, `60`, `70`, `75`, `80`, `90`, `95`, `100`

## Backgrounds

### Background Size

| Class | CSS Property | Description |
|-------|--------------|-------------|
| `bg-auto` | `background-size: auto` | Original size |
| `bg-cover` | `background-size: cover` | Cover container |
| `bg-contain` | `background-size: contain` | Fit container |

### Background Position

```html
<div class="bg-center">
<div class="bg-top">
<div class="bg-bottom">
<div class="bg-left">
<div class="bg-right">
<div class="bg-top-right">
```

### Background Repeat

| Class | CSS Property | Description |
|-------|--------------|-------------|
| `bg-repeat` | `background-repeat: repeat` | Repeat both |
| `bg-no-repeat` | `background-repeat: no-repeat` | No repeat |
| `bg-repeat-x` | `background-repeat: repeat-x` | Repeat horizontal |
| `bg-repeat-y` | `background-repeat: repeat-y` | Repeat vertical |

## Borders

### Border Width

| Class | Border Width | Description |
|-------|--------------|-------------|
| `border` | `1px` | 1px all sides |
| `border-0` | `0` | No border |
| `border-2` | `2px` | 2px all sides |
| `border-4` | `4px` | 4px all sides |
| `border-8` | `8px` | 8px all sides |

Individual sides:
```html
<div class="border-t-2">    <!-- top -->
<div class="border-r-2">    <!-- right -->
<div class="border-b-2">    <!-- bottom -->
<div class="border-l-2">    <!-- left -->
```

### Border Radius

| Class | Border Radius | Description |
|-------|---------------|-------------|
| `rounded-none` | `0` | No rounding |
| `rounded-sm` | `0.125rem` | Small |
| `rounded` | `0.25rem` | Default |
| `rounded-md` | `0.375rem` | Medium |
| `rounded-lg` | `0.5rem` | Large |
| `rounded-xl` | `0.75rem` | Extra large |
| `rounded-2xl` | `1rem` | 2XL |
| `rounded-3xl` | `1.5rem` | 3XL |
| `rounded-full` | `9999px` | Fully rounded |

Individual corners:
```html
<div class="rounded-t-lg">     <!-- top corners -->
<div class="rounded-r-lg">     <!-- right corners -->
<div class="rounded-tl-lg">    <!-- top-left -->
<div class="rounded-tr-lg">    <!-- top-right -->
```

### Border Style

| Class | CSS Property | Description |
|-------|--------------|-------------|
| `border-solid` | `border-style: solid` | Solid border |
| `border-dashed` | `border-style: dashed` | Dashed border |
| `border-dotted` | `border-style: dotted` | Dotted border |
| `border-double` | `border-style: double` | Double border |
| `border-none` | `border-style: none` | No border |

## Effects

### Box Shadow

| Class | Shadow | Description |
|-------|--------|-------------|
| `shadow-sm` | Small shadow | Subtle |
| `shadow` | Default shadow | Standard |
| `shadow-md` | Medium shadow | Moderate |
| `shadow-lg` | Large shadow | Prominent |
| `shadow-xl` | Extra large | Very prominent |
| `shadow-2xl` | 2XL shadow | Maximum |
| `shadow-inner` | Inner shadow | Inset |
| `shadow-none` | No shadow | Remove shadow |

### Drop Shadow

```html
<img class="drop-shadow-md">
<img class="drop-shadow-lg">
<img class="drop-shadow-xl">
```

## Filters

### Blur

| Class | Blur Amount | Description |
|-------|-------------|-------------|
| `blur-none` | `0` | No blur |
| `blur-sm` | `4px` | Small blur |
| `blur` | `8px` | Default blur |
| `blur-md` | `12px` | Medium blur |
| `blur-lg` | `16px` | Large blur |
| `blur-xl` | `24px` | Extra large |
| `blur-2xl` | `40px` | Maximum |

### Brightness, Contrast, Grayscale

```html
<!-- Brightness -->
<img class="brightness-50">   <!-- 50% -->
<img class="brightness-100">  <!-- 100% normal -->
<img class="brightness-150">  <!-- 150% bright -->

<!-- Contrast -->
<img class="contrast-50">
<img class="contrast-100">

<!-- Grayscale -->
<img class="grayscale">       <!-- 100% gray -->
<img class="grayscale-0">     <!-- 0% gray -->
```

## Transitions & Animation

### Transition Property

| Class | Properties | Description |
|-------|------------|-------------|
| `transition-none` | `none` | No transition |
| `transition-all` | `all` | All properties |
| `transition` | Common properties | Default set |
| `transition-colors` | Colors | Color properties |
| `transition-opacity` | `opacity` | Opacity only |
| `transition-shadow` | `box-shadow` | Shadow only |
| `transition-transform` | `transform` | Transform only |

### Transition Duration

| Class | Duration | Description |
|-------|----------|-------------|
| `duration-75` | `75ms` | Very fast |
| `duration-100` | `100ms` | Fast |
| `duration-150` | `150ms` | Quick |
| `duration-200` | `200ms` | Default |
| `duration-300` | `300ms` | Moderate |
| `duration-500` | `500ms` | Slow |
| `duration-700` | `700ms` | Slower |
| `duration-1000` | `1000ms` | Very slow |

### Transition Timing

| Class | Timing Function | Description |
|-------|-----------------|-------------|
| `ease-linear` | `linear` | Constant speed |
| `ease-in` | `ease-in` | Start slow |
| `ease-out` | `ease-out` | End slow |
| `ease-in-out` | `ease-in-out` | Both slow |

### Animation

```html
<div class="animate-spin">      <!-- Spinning -->
<div class="animate-ping">      <!-- Pinging -->
<div class="animate-pulse">     <!-- Pulsing -->
<div class="animate-bounce">    <!-- Bouncing -->
```

## Transforms

### Scale

```html
<div class="scale-0">      <!-- 0% -->
<div class="scale-50">     <!-- 50% -->
<div class="scale-75">     <!-- 75% -->
<div class="scale-90">     <!-- 90% -->
<div class="scale-95">     <!-- 95% -->
<div class="scale-100">    <!-- 100% -->
<div class="scale-105">    <!-- 105% -->
<div class="scale-110">    <!-- 110% -->
<div class="scale-125">    <!-- 125% -->
<div class="scale-150">    <!-- 150% -->

<!-- Axis-specific -->
<div class="scale-x-50">
<div class="scale-y-50">
```

### Rotate

```html
<div class="rotate-0">     <!-- 0deg -->
<div class="rotate-45">    <!-- 45deg -->
<div class="rotate-90">    <!-- 90deg -->
<div class="rotate-180">   <!-- 180deg -->
<div class="-rotate-45">   <!-- -45deg -->
```

### Translate

```html
<div class="translate-x-0">
<div class="translate-x-1">
<div class="translate-y-4">
<div class="-translate-x-1/2">  <!-- -50% centering -->
<div class="-translate-y-1/2">  <!-- -50% centering -->
```

## Interactivity

### Cursor

| Class | CSS Property | Description |
|-------|--------------|-------------|
| `cursor-auto` | `auto` | Default cursor |
| `cursor-default` | `default` | Default arrow |
| `cursor-pointer` | `pointer` | Pointing hand |
| `cursor-wait` | `wait` | Wait/loading |
| `cursor-text` | `text` | Text selection |
| `cursor-move` | `move` | Move cursor |
| `cursor-not-allowed` | `not-allowed` | Disabled |

### User Select

| Class | CSS Property | Description |
|-------|--------------|-------------|
| `select-none` | `user-select: none` | Not selectable |
| `select-text` | `user-select: text` | Text selectable |
| `select-all` | `user-select: all` | All selectable |
| `select-auto` | `user-select: auto` | Auto select |

### Pointer Events

| Class | CSS Property | Description |
|-------|--------------|-------------|
| `pointer-events-none` | `pointer-events: none` | Ignore events |
| `pointer-events-auto` | `pointer-events: auto` | Allow events |

## Responsive & State Variants

All utilities support responsive and state prefixes:

```html
<!-- Responsive -->
<div class="w-full md:w-1/2 lg:w-1/3">

<!-- Hover -->
<button class="bg-blue-500 hover:bg-blue-700">

<!-- Focus -->
<input class="border-gray-300 focus:border-blue-500">

<!-- Active -->
<button class="active:bg-blue-800">

<!-- Dark mode -->
<div class="bg-white dark:bg-gray-800">

<!-- Group hover -->
<a class="group">
  <span class="group-hover:text-blue-500">
</a>

<!-- Combined -->
<div class="md:hover:bg-blue-500 dark:lg:text-white">
```
