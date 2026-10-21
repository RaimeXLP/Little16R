# Credits and source references

Thank you to the developers, maintainers, and communities behind the projects
below. This file records the relationship to Little16R as precisely as possible.
Being listed does not imply participation in, approval of, or support for this
prototype.

## Little16: direct inspiration and research reference

**[Michael Melita](https://github.com/michaelmelita1) —
[Little16](https://github.com/michaelmelita1/Little16)**

Little16 inspired this attempt to bring modern swipe navigation to an older
iPhone. The inspected reference is commit
[`4c7ad7c`](https://github.com/michaelmelita1/Little16/tree/4c7ad7cacb6804fa25ef63c797966769f6f4d41d),
checked on 2026-10-21.

The following private interfaces and their intended behavior were researched in
[Little16's Tweak.xm](https://github.com/michaelmelita1/Little16/blob/4c7ad7cacb6804fa25ef63c797966769f6f4d41d/Tweak.xm):

| Reference | Contribution to Little16R research |
| --- | --- |
| `SBHomeGestureSettings.isHomeGestureEnabled` | Entry point for enabling Home gestures. |
| `CCSControlCenterDefaults._defaultPresentationGesture` | Reference for selecting modern Control Center presentation. |
| `SBControlCenterController.presentingEdge` | Reference for the modern Control Center edge value. |
| `SBFHomeGrabberSettings.isEnabled` | Reference for the Home indicator setting; Little16R attempts to enable it and still needs visual device testing. |

Little16R uses a separate Objective-C runtime implementation with device checks,
method-signature checks, scoped SpringBoard injection, and diagnostic logging.
The original `.deb` and source files are not bundled with Little16R. The dock,
status-bar, and lock-screen modifications in Little16 are outside this prototype's
scope.

No license file was found in that Little16 reference at the time of inspection.
If Michael would prefer this project and its package source to be taken offline,
Leon is happy to do so; please [open an issue](https://github.com/RaimeXLP/Little16R/issues/new).
Credit corrections and additional source information are welcome through the
same route.

## Earlier work acknowledged by Little16

These projects are named in
[Little16's own credits](https://github.com/michaelmelita1/Little16/blob/4c7ad7cacb6804fa25ef63c797966769f6f4d41d/README.md#credits).
They are part of the history of the original project. Their source has not been
imported directly into Little16R, and this list does not assert a file-by-file
provenance for Little16 itself.

| Creator | Project | Relationship |
| --- | --- | --- |
| ETHN / [nahtedetihw](https://github.com/nahtedetihw) | [FloatingDockXVI](https://github.com/nahtedetihw/FloatingDockXVI) | Floating dock work credited by Little16; dock behavior is outside Little16R's initial scope. |
| [Ryan Nair](https://github.com/ryannair05) | [Little12](https://github.com/ryannair05/Little12) | Earlier iPhone-style gesture project credited by Little16. |
| [duraidabdul](https://github.com/duraidabdul) | [Neptune](https://github.com/duraidabdul/Neptune) | Earlier SpringBoard navigation project credited by Little16. |

## Runtime interfaces, build tools, and distribution

| Project / maintainer | Actual use in Little16R |
| --- | --- |
| [Apple Objective-C runtime](https://developer.apple.com/documentation/objectivec/objective-c-runtime), Foundation, and Xcode | Runtime class/method lookup, signature inspection, logging, compiler, and iPhoneOS SDK. |
| [Cydia Substrate / Jay Freeman (saurik)](https://www.cydiasubstrate.com/api/c/MSHookMessageEx/) | The `MSHookMessageEx` API used to install the runtime hooks. A compatible provider is required on the device. |
| [Theos and its contributors](https://github.com/theos/theos/tree/304e0799973e8145f32e4ca2de6c747a84b758ce) | Pinned build and Debian-packaging framework, including its headers, libraries, and submodules. Their own notices remain with those projects. |
| [GNU Make](https://www.gnu.org/software/make/) | Runs the Theos build rules. |
| [ldid / Jay Freeman (saurik)](https://cydia.saurik.com/info/ldid/) | Signs the built Mach-O tweak through the Theos toolchain. CI installs Homebrew's `ldid` formula, which points to saurik's upstream. |
| [Debian dpkg](https://git.dpkg.org/cgit/dpkg/dpkg.git/) and [APT repository format](https://wiki.debian.org/DebianRepository/Format) | Package creation/inspection and the package index format consumed by Sileo. |
| [XZ Utils / Tukaani](https://tukaani.org/xz/) | Compression support used by the packaging toolchain. |
| [Python and its contributors](https://www.python.org/) | Generates package indices, checksums, compressed indices, and build provenance for the package source. |
| [Homebrew](https://brew.sh/) | Installs the macOS CI build dependencies. |
| [Git](https://git-scm.com/), [GitHub Actions](https://github.com/actions), and [GitHub Pages](https://pages.github.com/) | Source control, hosted builds, official checkout/artifact/Pages actions, package archival, and package-source hosting. The workflow records exact action revisions. |
| [Sileo and its contributors](https://github.com/Sileo/Sileo) | The package manager targeted by the published APT source. Sileo itself is not bundled in the tweak. |
| [actionlint / rhysd](https://github.com/rhysd/actionlint) | Used to validate the GitHub Actions workflow during development. |
| ChatGPT / Codex | Development assistance while preparing and debugging the prototype, documentation, build workflow, and repository tooling. |

## Maintainer and ongoing attribution

**Leon Prinz ([RaimeXLP](https://github.com/RaimeXLP))** initiated and maintains
Little16R for an iPhone 7 with a broken Home button, maintains the package source,
and is the contact for publication and credit concerns. Successful device testing
has not yet been recorded.

Future code imports must record the author, original URL, exact revision, license
or permission, affected files, and required notices here and alongside the code.
If a reference or contribution is missing or described incorrectly, please
[open an issue](https://github.com/RaimeXLP/Little16R/issues/new) so it can be fixed.
