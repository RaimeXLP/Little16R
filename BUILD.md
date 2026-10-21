# Building Little16R

## Status

The experimental prototype has successfully compiled in GitHub Actions and passed
rootful package layout and arm64 checks. It has not yet been run on an iPhone.
Compiled packages are published at https://raimexlp.github.io/Little16R/.

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
