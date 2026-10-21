# Implementation plan

## 1. Establish the device environment

- Record the jailbreak name/version and confirm rootful packaging.
- Record the active tweak loader and verify SpringBoard injection.
- Establish a working way to disable/remove the test tweak if SpringBoard fails.

## 2. Implement a minimal navigation prototype

- Inspect the iOS 15.8.8 Home gesture and Control Center interfaces.
- Write scoped hooks, loaded into SpringBoard only initially.
- Add guards for unsupported classes or methods and a diagnostic load message.
- Implement Home, app-switcher, and Control Center gestures first.
- Verify the visible Home indicator separately, including whether application
  processes require additional hooks or layout handling.
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
- Confirm uninstall restores the original behavior.

Only mark iPhone 7 / iOS 15.8.8 as supported after recording successful device
checks, including the jailbreak, loader, and package version used.
