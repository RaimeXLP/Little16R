# Little16R

Experimental iPhone X-style gesture navigation for rootful jailbreaks. **R stands for Rootful.**

## Status

Version 0.1.0-alpha1 is an independently written source prototype, not a working
release. It has **not been compiled or tested on a device**. No `.deb` is included.
The initial target is an iPhone 7 (arm64/A10) running iOS 15.8.8 with a rootful jailbreak.
The runtime guard allows only iPhone7 identifiers `iPhone9,1` / `iPhone9,3` on iOS 15.
See [BUILD.md](BUILD.md) for the manual GitHub Actions build and testing procedure.

## Why this project exists

The target iPhone has a broken Home button and needs swipe navigation. Little16
inspired this project, but its published rootless package does not match the
target rootful environment. Little16R aims to provide a small implementation
focused on navigation for this setup.

## Intended features

- Swipe up to return Home.
- Swipe up and hold to open the app switcher.
- Swipe down from the top-right corner to open Control Center.
- A visible Home indicator (experimental setting; in-app visibility is unresolved).

An iPad dock, a replacement status bar, and additional lock-screen buttons are
outside the initial scope.

## Development approach

Use Theos, Objective-C and Substrate's hook API to interact with the existing iOS gesture system.
Build an arm64 rootful Debian package (`iphoneos-arm` package architecture).
The package architecture label is separate from the CPU architecture.

Before installation, identify the active jailbreak and its tweak loader.
The prototype checks private method signatures at runtime and logs missing methods.
These checks do not verify method semantics or guarantee crash-free operation.
A successful build alone will not establish runtime compatibility.

There is no Settings pane. Hooks activate when the tweak loads into SpringBoard.
No user data is collected or transmitted by the tweak.

See [PLAN.md](PLAN.md) for implementation and device checks, and
[CREDITS.md](CREDITS.md) for inspiration and attribution.

## Source and licensing status

This project does not include copied Little16 source code or its compiled package.
At inspection on 2026-10-21, the Little16 repository did not declare a license.
Attribution is not treated as a grant to redistribute or relicense its code.
The current implementation is independently written using the Objective-C runtime
and Substrate API. Future third-party code must have an explicit compatible license
with the required notices preserved. This repository does not yet grant a general
redistribution license for its own source.

Little16R is an independent project and is not an official Little16 release.
