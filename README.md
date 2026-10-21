# Little16R

Planned iPhone X-style gesture navigation for rootful jailbreaks. **R stands for Rootful.**

## Status

Project scaffold only: no tweak implementation or installable package is included yet.
The initial target is an iPhone 7 (arm64/A10) running iOS 15.8.8 with a rootful jailbreak.
Compatibility has **not** been verified on a device.

## Why this project exists

The target iPhone has a broken Home button and needs swipe navigation. Little16
inspired this project, but its published rootless package does not match the
target rootful environment. Little16R aims to provide a small implementation
focused on navigation for this setup.

## Intended features

- Swipe up to return Home.
- Swipe up and hold to open the app switcher.
- Swipe down from the top-right corner to open Control Center.
- A visible Home indicator.

An iPad dock, a replacement status bar, and additional lock-screen buttons are
outside the initial scope.

## Development approach

Use Theos and Objective-C/Logos to interact with the existing iOS gesture system.
Build an arm64 rootful Debian package (`iphoneos-arm` package architecture).
The package architecture label is separate from the CPU architecture.

First identify the active jailbreak and its tweak loader. Inspect the relevant
iOS 15.8.8 classes and method signatures before implementing hooks. A successful
build alone will not establish runtime compatibility.

See [PLAN.md](PLAN.md) for implementation and device checks, and
[CREDITS.md](CREDITS.md) for inspiration and attribution.

## Source and licensing status

This scaffold does not include Little16 source code or its compiled package.
At inspection on 2026-10-21, the Little16 repository did not declare a license.
Attribution is not treated as a grant to redistribute or relicense its code.
Implementation will be independently written, or based on code with an explicit
compatible license while preserving the required notices.

Little16R is an independent project and is not an official Little16 release.
