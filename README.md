# Ricebar

RICE'd MacOS menubar.

Ricebar is a customizable menu bar with consisting of a plethora of cosmetic and functional features, meant to replace the traditional MacOS menu bar.

![Ricebar Demo](demos/demo_pong.gif)

<video src="demos/so_ricebar.mov" controls title="Ricebar Demo">Ricebar Demo</video>

## Motivation
__*Riced Menu Bar*__: RICE, or Race Inspired Cosmetic Enhancements (R.I.C.E.), is the act of making unnecessary cosmetic changes to your set-up (e.g. laptop) to make it seem cool. I want to make a menu bar that looks very fancy and different from the default Mac menu bar, with some additional functionalities mirroring the activities monitor widget. This is “helpful” because it is cool looking.

There are a few feature ideas I may potentially build. Note that this is semi-ambitious and I plan to tackle at least half of the extension mentioned, but we shall see.

In my V1, I made it replace the entire menu bar, but quickly realized that it means I would have to rewrite a lot of the MacOS menu bar features (e.g. running application, “File”, “Edit”, etc). For it to be usable, I have decided my ricebar is a half bar that replaces the right side of a MacOS menu bar and also be collapsible

## Completed Features
- Games
  - Pong with the menu bar
- Shaders (time varying)
- Systems Insight
  - Clock
  - Battery (charging vs static)
  - CPU Utilization
  - Opens activity monitor
  - Wi-Fi + IP address copying
  - Weather
- Set up timed alerts
- Cosmetics: rolling animation
- User Settings
  - Allow users to customize their ricebar color palatte and hide certain icons.
- Keyboard shortcut to open and close

## WIP Features & Bugs
- More efficient ricebar (CPU / memory usage)
  - Phase 1 optimization done; 6~10% CPU utilization. More is always better but to achieve that we may need to disable GPU shaders by default and have them be user enabled.
- Notchless menu bar (better width / height calculations)
- Pong
  - Smoother animation and bouncier ball physics (not just basic, but boing)
  - When it hits a corner, it bounces back and forth a bunch and gets a bajillion points :P
- Customizable menu bar icons (choose which features to show)
- Close activity monitor too when you press it again
- Cosmetics: 
  - Rolling is jank sometimes
  - Perlin noise / gradient dithering
- Ricebar only shows up on main page instead of always and toggle show/hide only works when application is selected.
- Cosmetics: Cursor dependent shaders

## Planned features
- Execute ad-hoc bash scripts you decide to write :D
