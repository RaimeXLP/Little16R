// Little16R: experimental SpringBoard-only navigation for iOS 15.
// Private selector names are compatibility assumptions, not verified iOS 15.8.8 headers.
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <substrate.h>
#import "L16RPreferences.h"
#include <string.h>
#include <sys/sysctl.h>

typedef struct {
    const char *className;
    const char *selectorName;
    IMP replacement;
    const char *returnType;
} L16RGetter;

static BOOL L16REnabled(id receiver, SEL selector) {
    (void)receiver;
    (void)selector;
    return YES;
}

static BOOL L16RDisabled(id receiver, SEL selector) {
    (void)receiver;
    (void)selector;
    return NO;
}

// These private APIs use the value 1 for the modern Control Center gesture/edge.
// This interpretation must be checked on the target device, not inferred from compilation.
static unsigned long long L16RModernControlCenter(id receiver, SEL selector) {
    (void)receiver;
    (void)selector;
    return 1ULL;
}

static BOOL L16RIsTargetDevice(void) {
    char machine[64] = {0};
    size_t size = sizeof(machine);
    if (sysctlbyname("hw.machine", machine, &size, NULL, 0) != 0) {
        return NO;
    }
    // Both hardware variants of the 4.7-inch iPhone 7. Other models remain untested.
    return strcmp(machine, "iPhone9,1") == 0 || strcmp(machine, "iPhone9,3") == 0;
}

// Validate the ABI before installing any navigation hooks. A matching signature
// cannot establish semantics, but prevents invoking an incompatible replacement.
static BOOL L16RSupportsGetter(L16RGetter hook) {
    Class target = objc_getClass(hook.className);
    SEL selector = sel_registerName(hook.selectorName);
    Method method = target ? class_getInstanceMethod(target, selector) : NULL;
    if (!method) {
        NSLog(@"[Little16R] Missing %s -%s", hook.className, hook.selectorName);
        return NO;
    }
    NSMethodSignature *signature =
        [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(method)];
    if (signature.numberOfArguments != 2 ||
        strcmp(signature.methodReturnType, hook.returnType) != 0) {
        NSLog(@"[Little16R] Unsupported signature for %s -%s: %s",
              hook.className, hook.selectorName, method_getTypeEncoding(method));
        return NO;
    }
    return YES;
}

static void L16RInstallGetter(L16RGetter hook) {
    MSHookMessageEx(objc_getClass(hook.className),
                    sel_registerName(hook.selectorName), hook.replacement, NULL);
}

typedef void (*L16RInsetSetter)(id, SEL, UIEdgeInsets);
static L16RInsetSetter L16ROriginalInsetSetters[4];

static UIEdgeInsets L16RHomebarInsets(UIEdgeInsets insets) {
    // A compact bottom area for the 4.7-inch screen, in points. Preserve any
    // larger system inset and all other edges; never accumulate extra padding.
    if (insets.bottom < 21.0) insets.bottom = 21.0;
    return insets;
}

#define L16R_INSET_SETTER(NAME, INDEX) \
    static void NAME(id receiver, SEL selector, UIEdgeInsets insets) { \
        L16ROriginalInsetSetters[INDEX](receiver, selector, L16RHomebarInsets(insets)); \
    }
L16R_INSET_SETTER(L16RSetPortraitInsets, 0)
L16R_INSET_SETTER(L16RSetUpsideDownInsets, 1)
L16R_INSET_SETTER(L16RSetLandscapeLeftInsets, 2)
L16R_INSET_SETTER(L16RSetLandscapeRightInsets, 3)
#undef L16R_INSET_SETTER

static BOOL L16RInstallSceneInsets(void) {
    Class target = objc_getClass("UIMutableApplicationSceneSettings");
    const char *names[] = {"setSafeAreaInsetsPortrait:",
        "setSafeAreaInsetsPortraitUpsideDown:", "setSafeAreaInsetsLandscapeLeft:",
        "setSafeAreaInsetsLandscapeRight:"};
    const IMP replacements[] = {(IMP)L16RSetPortraitInsets, (IMP)L16RSetUpsideDownInsets,
        (IMP)L16RSetLandscapeLeftInsets, (IMP)L16RSetLandscapeRightInsets};
    // Validate the entire orientation group before modifying any method. These
    // setters change the stored scene settings sent to apps, not just a local
    // getter's result. App processes do not need Little16R injection.
    for (size_t index = 0; index < 4; index++) {
        Method method = target ? class_getInstanceMethod(target, sel_registerName(names[index])) : NULL;
        NSMethodSignature *signature = method ?
            [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(method)] : nil;
        if (!signature || signature.numberOfArguments != 3 ||
            strcmp(signature.methodReturnType, @encode(void)) != 0 ||
            strcmp([signature getArgumentTypeAtIndex:2], @encode(UIEdgeInsets)) != 0) {
            NSLog(@"[Little16R] App spacing unavailable: incompatible %s", names[index]);
            return NO;
        }
    }
    for (size_t index = 0; index < 4; index++) {
        MSHookMessageEx(target, sel_registerName(names[index]), replacements[index],
                        (IMP *)&L16ROriginalInsetSetters[index]);
    }
    return YES;
}

static void L16RConfigureHomebar(BOOL showHomebar) {
    const L16RGetter indicator = {"SBFHomeGrabberSettings", "isEnabled",
        showHomebar ? (IMP)L16REnabled : (IMP)L16RDisabled, @encode(BOOL)};
    if (!L16RSupportsGetter(indicator)) return;
    L16RInstallGetter(indicator);
    if (!showHomebar) {
        NSLog(@"[Little16R] Homebar off; application layout unchanged");
        return;
    }

    // Keep the native indicator from timing out, without overriding hidden
    // states used for locking, transitions, or other system-owned overlays.
    const L16RGetter visibility[] = {
        {"SBHomeGrabberView", "_autohideEffectivelyEnabled", (IMP)L16RDisabled, @encode(BOOL)},
        {"UIApplicationSceneClientSettings", "homeIndicatorAutoHidden", (IMP)L16RDisabled, @encode(BOOL)},
    };
    for (size_t index = 0; index < sizeof(visibility) / sizeof(visibility[0]); index++) {
        if (L16RSupportsGetter(visibility[index])) L16RInstallGetter(visibility[index]);
    }
    BOOL spacing = L16RInstallSceneInsets();
    NSLog(@"[Little16R] Homebar on; scene spacing %@; visual device testing required",
          spacing ? @"installed" : @"unavailable");
}

#ifndef L16R_UNIT_TEST
__attribute__((constructor)) static void L16RInitialize(void) {
    @autoreleasepool {
        if (![[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
            return;
        }
        NSLog(@"[Little16R] 0.2.0-alpha1 loaded into SpringBoard");
        if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion != 15 ||
            !L16RIsTargetDevice()) {
            NSLog(@"[Little16R] Inactive: prototype restricted to iPhone 7 on iOS 15");
            return;
        }

        const L16RGetter navigation[] = {
            {"SBHomeGestureSettings", "isHomeGestureEnabled", (IMP)L16REnabled, @encode(BOOL)},
            {"CCSControlCenterDefaults", "_defaultPresentationGesture",
                (IMP)L16RModernControlCenter, @encode(unsigned long long)},
            {"SBControlCenterController", "presentingEdge",
                (IMP)L16RModernControlCenter, @encode(unsigned long long)},
        };
        const size_t count = sizeof(navigation) / sizeof(navigation[0]);
        BOOL supported = YES;
        for (size_t index = 0; index < count; index++) {
            if (!L16RSupportsGetter(navigation[index])) supported = NO;
        }
        if (!supported) {
            // Do not enable Home gestures while leaving the old Control Center gesture active.
            NSLog(@"[Little16R] Inactive: navigation interface check failed; no hooks installed");
            return;
        }
        for (size_t index = 0; index < count; index++) {
            L16RInstallGetter(navigation[index]);
        }

        // Applied once per SpringBoard launch: a respring rebuilds all scene
        // settings consistently when switching either on or off.
        L16RConfigureHomebar(L16RReadShowHomebar());
        NSLog(@"[Little16R] Navigation hooks installed; device verification required");
    }
}
#endif
