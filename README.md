# Little16R

Experimental iPhone X-style gesture navigation for rootful jailbreaks.
**R stands for Rootful.** Maintained by Leon Prinz ([RaimeXLP](https://github.com/RaimeXLP)).

## Install through Sileo

Add this package source in **Sileo → Sources → +**:

**https://raimexlp.github.io/little16r/**

On your iPhone, you can also open that page and tap **Add to Sileo**, **Cydia**,
**Zebra**, **Installer**, or **Saily**. A copy-address button is provided as well.
The source URL is now entirely lowercase; replace any previously saved source
using the old `/Little16R/` path.

Refresh sources, search for **Little16R**, install it, and respring. Remove
competing gesture tweaks before testing. The package requires a **rootful**
jailbreak with a compatible Substrate API provider; confirm the active jailbreak
and tweak loader before the first installation.

The package requests **Restart SpringBoard / Respring** through Sileo's standard
installation-completion action after installation, update, or reinstallation.
If an older build was installed without a respring button, refresh sources and
update Little16R; then use the completion button at the end of that installation.

New successful builds from `main` are published to this source automatically.
Each build receives its own package version, so Sileo can offer subsequent
builds as updates. Older package files remain available for cached downloads.
The GitHub source-code URL itself is not a Sileo source.

See [START_HERE_DE.md](START_HERE_DE.md) for the German installation guide.

## Status and scope

The `0.1.0-alpha1` prototype has successfully compiled and passed rootful package
layout and arm64 checks in [GitHub Actions](https://github.com/RaimeXLP/little16r/actions).
**It has not yet been tested on an iPhone.** A successful build does not confirm
working gestures, loader compatibility, or a visible Home indicator.

The initial target is an iPhone 7 (arm64/A10) on iOS 15.8.8 with a rootful jailbreak.
Runtime checks currently restrict activation to `iPhone9,1` / `iPhone9,3` on iOS 15.
There is no Settings pane; the prototype attempts to activate when loaded into
SpringBoard. It collects or transmits no user data.

Intended features:

- Swipe up to return Home.
- Swipe up and hold to open the app switcher.
- Swipe down from the top-right corner to open Control Center.
- A visible Home indicator, whose appearance inside applications remains unresolved.

An iPad dock, a replacement status bar, and lock-screen quick actions are outside
the initial scope. See [PLAN.md](PLAN.md) for the remaining device checks and
[BUILD.md](BUILD.md) for build, publication, and diagnostic information.

## Why Little16R exists

My iPhone 7 has a broken Home button, and I wanted to keep using it with swipe
navigation. [Little16](https://github.com/michaelmelita1/Little16) by
[Michael Melita](https://github.com/michaelmelita1) inspired this project. Its
published rootless package did not fit the rootful setup targeted here, so I
started this small, independently written prototype focused on navigation.

Thank you, Michael, and everyone whose earlier work helped make these ideas
accessible. The [credits and source references](CREDITS.md) explain what each
project contributed to the research and which tools this prototype actually uses.
Little16R is an independent project and does not claim to be an official Little16
release or to have its creator's endorsement.

## A note from Leon to the original creator and contributors

I mean this project in a friendly spirit and have no wish to cause bad feelings
with Michael or any other original contributor. When I looked at Little16 on
2026-10-21, I could not find a license file in the repository. This prototype was
written separately; Little16's source and compiled package are not bundled here.
The private gesture selectors researched in Little16 are explicitly acknowledged
in [CREDITS.md](CREDITS.md).

**If you are the original creator and would prefer this project not to be online,
please [open an issue](https://github.com/RaimeXLP/little16r/issues/new). I am happy
to take the project, the published package source, and its downloads offline.**
The same contact route is open to contributors who want a credit corrected,
expanded, or added. I want to handle concerns respectfully and directly.

This repository does not currently declare a general redistribution license for
its own source. Any future third-party code will need its permission and notices
recorded alongside the relevant files. Attribution here documents the work and
research behind the project; it does not claim ownership of anyone else's work.
