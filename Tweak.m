// Little16R: experimental SpringBoard-only navigation for iOS 15.
// Private selector names are compatibility assumptions, not verified iOS 15.8.8 headers.
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <substrate.h>
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

__attribute__((constructor)) static void L16RInitialize(void) {
    @autoreleasepool {
        if (![[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
            return;
        }
        NSLog(@"[Little16R] 0.1.0-alpha1 loaded into SpringBoard");
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

        const L16RGetter indicator = {
            "SBFHomeGrabberSettings", "isEnabled", (IMP)L16REnabled, @encode(BOOL)
        };
        if (L16RSupportsGetter(indicator)) {
            L16RInstallGetter(indicator);
            NSLog(@"[Little16R] Home indicator setting enabled; visual behavior requires testing");
        }
        NSLog(@"[Little16R] Navigation hooks installed; device verification required");
    }
}
