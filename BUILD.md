# Building Little16R

## Status

The source is an experimental prototype, not a verified working release. It has
not been compiled or run on an iPhone in the preparation environment. The build
workflow has not yet run. Do not interpret an uploaded source ZIP as an installable tweak.

## Build on GitHub

1. Upload the files and folders from this project to the root of `RaimeXLP/Little16R`.
   In particular, the workflow must be `.github/workflows/build.yml`, not `build.yml`
   at the repository root. Your file manager may hide `.github` and `.gitignore`.
2. Open **Actions → Build rootful prototype → Run workflow**.
3. Wait for a successful build. Download the `Little16R-rootful-alpha` artifact.
4. Extract the artifact to obtain the `.deb`. A successful build checks packaging,
   not whether gestures work on iOS 15.8.8.

The workflow is manual, has read-only repository permissions, and does not create
commits, publish releases, or install anything on a device. GitHub Actions and
Theos revisions are pinned; the macOS runner, Xcode and Homebrew packages are not.

## Build locally

Install Theos using its official instructions:

- macOS: https://theos.dev/docs/installation-macos
- Linux/Windows (WSL): https://theos.dev/docs/installation-linux

With `THEOS` set to that installation, run from this project:

```sh
unset THEOS_PACKAGE_SCHEME
make clean package
```

The resulting package is written under `packages/`. Use the package manager to
install it only after identifying the active jailbreak/loader and establishing
a working recovery procedure. Remove competing gesture tweaks first. Respring
after installation. There is no Settings pane: this prototype activates on load.

## Before the first device test

Record the jailbreak name/version and verify that its loader supports Substrate's
`MSHookMessageEx` interface. A package manager showing an installed tweak is not
proof that SpringBoard injection works. The `mobilesubstrate` dependency must be
satisfied by the appropriate package/provider for that jailbreak.

Have a verified way to enter the jailbreak's mode without tweak injection and
remove the package if SpringBoard crashes. The exact procedure depends on the
jailbreak; this project does not assume one.

## Diagnosing a test

Look for `[Little16R]` messages in a connected device/system log viewer:

- `loaded into SpringBoard`: the loader reached the constructor.
- `navigation interface check failed`: source adaptation is required; no navigation
  hooks were installed. The preceding messages name the missing/mismatched methods.
- `Navigation hooks installed`: hooks were registered, not proof of functional gestures.
- No message: investigate loader activity, installation paths, or log collection.

The Home indicator getter is experimental. Its appearance inside apps may require
additional implementation; this version deliberately injects into SpringBoard only.

To undo a test, remove Little16R in the package manager and respring. If SpringBoard
is unusable, use the previously verified no-tweak mode before removing the package.
