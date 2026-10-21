# Building Little16R

## Status

The experimental prototype has successfully compiled in GitHub Actions and passed
rootful package layout and arm64 checks. Leon has installed the first prototype;
the new Homebar mode and preference pane still need device validation.
Compiled packages are published at https://raimexlp.github.io/little16r/.

## Build on GitHub

Push changes to `main`, or open **Actions → Build rootful prototype → Run workflow**
and select `main`. After the build and package checks pass, the publication job
updates the Sileo source. The `Little16R-rootful-alpha` artifact remains available
for direct `.deb` downloads for 14 days.

The package version is the base `Version` in `control` plus
`+build.<workflow run number>.<run attempt>`. Each new build or rerun has a distinct
version, allowing Sileo to recognize updates without replacing older downloads.
Increase the base version in `control` for a new development milestone.

The build job has read-only repository access. The publication job can update the
`gh-pages` package archive and deploy GitHub Pages using its short-lived workflow
token. Archive commits explicitly use Leon Prinz / RaimeXLP as author and committer,
with no co-author trailer. Publication does not modify `main` or create releases.
The workflow does not install anything on a device. Actions and Theos revisions
are pinned; macOS/Ubuntu runners, Xcode and Homebrew packages are not.

## Package source layout

GitHub Pages uses **GitHub Actions** as its build source. The `gh-pages` branch
stores the generated files and versioned `.deb` downloads. `scripts/build_repo.py`
generates flat APT metadata (`Release`, `Packages`, and gzip/bzip2/xz indices),
checks package identity/architecture, records hashes and build provenance, and
keeps older packages and index hashes for cached clients. Existing package files
cannot be replaced with different bytes under the same filename.

The Pages artifact is exported with `git archive`, so it contains only committed
public files and no Git credentials. Only successful `main` builds publish; builds
dispatched against other branches do not change the Sileo source. Publication runs
are serialized. The source uses HTTPS and checksummed metadata without an OpenPGP
repository signature.

The repository generator uses only the Python 3 standard library. It can also run locally:

```sh
python3 scripts/build_repo.py --packages packages --output /tmp/little16r-repo \
  --template repo --source-commit "$(git rev-parse HEAD)" --build-url local
```

It expects exactly one incoming `.deb` in the packages directory. Existing versions
in the output's `pool/` directory are retained. The output folder is what Pages
serves, and its URL is what users add in Sileo.

Sileo requires a `Components` field even for a flat source, so `Release` includes
`Components: main`. Before publication, regression checks cover this Sileo
requirement, package paths, and index/download checksums. Run them locally with
`python3 -B -m unittest discover -s tests -v`.

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
after installation. Navigation activates on load; the optional Homebar is controlled
under Settings → Little16R and defaults to off.

The `preferences` subproject builds an arm64 PreferenceLoader bundle under
`/Library/PreferenceBundles/Little16RPrefs.bundle`. Its entry is installed under
`/Library/PreferenceLoader/Preferences/Little16R.plist`. The package depends on
`preferenceloader`. CI checks the bundle executable, resources, loader entry and
architecture as well as the SpringBoard dylib and postinst.

Apple's standard SDK does not include the private Preferences linker stub. CI
downloads only `Preferences.tbd` from the pinned Theos SDK revision recorded in
the workflow, verifies its SHA-256, and points `LITTLE16R_PRIVATE_FRAMEWORKS_DIR`
at the containing framework directory. This is build-only input; no Apple
framework or stub is included in the `.deb`. Local builds need a patched Theos
SDK with Preferences or the same framework search path. The optional relaunch
frameworks are opened from their iOS system paths at runtime.

`L16RPreferences.h` shares the domain `io.github.raimexlp.little16r` and boolean key
`ShowHomebar` between the preference pane and SpringBoard. CFPreferences persists
the switch. Missing or malformed values mean off. Changes are applied at the next
SpringBoard launch, through the pane's confirmed `SBSRelaunchAction` request or a
manual respring. No live preference notification installs/removes hooks mid-session.

When enabled, optional signature-checked hooks disable the grabber's effective
auto-hide and the app-scene auto-hide request. Four
`UIMutableApplicationSceneSettings` inset setters store a minimum 21-point bottom
inset before forwarding to their original implementations, so the native scene
settings can carry the spacing into apps. This remains SpringBoard-only injection.
Unsupported inset signatures skip the entire orientation group. The native bar
and this transport/layout behavior still require on-device verification on iOS 15.

Native macOS tests run the actual runtime hook code against mock Objective-C
classes, checking default-off behavior, malformed preference values, all four
orientations, preservation of larger/other-edge insets, and whole-group ABI failure.
They do not emulate SpringBoard rendering or scene delivery. The same unit-test
command runs these tests on macOS; Ubuntu skips the native cases.

## Before the first device test

`layout/DEBIAN/postinst` requests Sileo/Cydia's `finish:restart` completion action
when dpkg calls it with `configure`, covering installation, upgrades, and
reinstallation. It writes to the manager-provided `SILEO`/`CYDIA` file descriptor;
the manager controls the respring. The script does not call a restart utility.
CLI installs without a completion channel still succeed and need a manual
respring. `INSTALL_TARGET_PROCESSES` in the Makefile applies to Theos's local
install command and does not by itself request Sileo's completion button.

CI verifies that the executable postinst script is included in the built `.deb`.
Tests exercise the completion pipe, Cydia fallback, missing/invalid descriptors,
and recovery actions without restarting any process.

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

`Homebar off` confirms the optional mode is disabled. `scene spacing installed`
means the four inset setters were hooked; `App spacing unavailable` names a missing
or mismatched setter. These logs establish hook installation, not rendering or
correct app layout. Reopen apps retaining cached layouts after a settings change.

To undo a test, remove Little16R in the package manager and respring. If SpringBoard
is unusable, use the previously verified no-tweak mode before removing the package.
