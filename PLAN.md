# Implementation plan

## Current progress

The initial prototype compiled, passed rootful/arm64 checks, and was installed
by Leon through Sileo. Successful main builds publish automatically. Version
0.2.0-alpha1 adds a PreferenceLoader pane, a Homebar switch defaulting to off,
and an explicit apply/respring action. Leon confirmed those controls and Homebar/
layout adaptation in Spotify, Sileo, palera1n, Phone and Safari with build 10.1.
0.2.1 adds the missing Home/Lock screen indicators; these visuals need a device
retest. YouTube could not be used as a test because an unavailable app update is
required; no app-specific exception or framework incompatibility is assumed.
The checklist below contains remaining validation, not claims of passed tests.

## 1. Establish the device environment

- Record the jailbreak name/version and confirm rootful packaging.
- Record the active tweak loader and verify SpringBoard injection.
- Establish a working way to disable/remove the test tweak if SpringBoard fails.

## 2. Implement a minimal navigation prototype

- Inspect the iOS 15.8.8 Home gesture and Control Center interfaces.
- Write scoped hooks, loaded into SpringBoard only initially.
- Add guards for unsupported classes or methods and a diagnostic load message.
- Implement Home, app-switcher, and Control Center gestures first.
- Verify the optional Homebar on the Home screen and in applications, and confirm
  that mutable scene inset setters transport the bottom spacing into app processes.
- Keep the default off and avoid app-process injection unless device evidence
  establishes a need for it.
- Do not change status-bar styling, dock behavior, or lock-screen quick actions.

## 3. Build for rootful

- Configure Theos for arm64 and iOS 15, without the rootless package scheme.
- Use a distinct Little16R package identifier and appropriate loader dependency.
- Check the package architecture and rootful installation paths.
- Inspect the compiled binary's linked-library paths and package contents.
- Preserve upstream notices if explicitly licensed code is incorporated.

## 4. Device acceptance checks

- Remove competing gesture tweaks before testing.
- Confirm that the tweak loads after a respring.
- Test Home and app-switcher gestures from the Home screen and multiple apps.
- Test Control Center and Notification Center independently.
- Test portrait/landscape, keyboard, lock/unlock, and full-screen applications.
- Check Home indicator visibility and bottom layout in applications.
- Retest the new Home/Lock indicators, including lock/unlock, rotation, original
  view layout, repeated layout calls, and gestures/taps near the indicator.
- Check Settings → Little16R, default off after an upgrade, saved switch persistence,
  apply/respring, both toggling directions, and app reopening for cached layouts.
- Test 21-point bottom spacing with the keyboard, tab bars, Safari, Settings,
  landscape and games; confirm no accumulated or reduced existing insets.
- Confirm uninstall restores the original behavior.

Only mark iPhone 7 / iOS 15.8.8 as supported after recording successful device
checks, including the jailbreak, loader, and package version used.
