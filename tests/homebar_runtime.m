// Exercise the actual hook installation against host Objective-C classes.
// No preference files, SpringBoard process, or device are modified by this test.
#define L16R_UNIT_TEST 1
#import "../Tweak.m"
#import "../SurfaceHomebar.m"
#include <assert.h>

static unsigned hookCount;
void MSHookMessageEx(Class target, SEL selector, IMP replacement, IMP *original) {
    Method method = class_getInstanceMethod(target, selector);
    if (original) *original = method_getImplementation(method);
    if (!class_addMethod(target, selector, replacement, method_getTypeEncoding(method))) {
        method_setImplementation(method, replacement);
    }
    hookCount++;
}

@interface SBFHomeGrabberSettings : NSObject
- (BOOL)isEnabled;
@end
@implementation SBFHomeGrabberSettings
- (BOOL)isEnabled { return YES; }
@end
@interface SBHomeGrabberView : NSObject
- (BOOL)_autohideEffectivelyEnabled;
@end
@implementation SBHomeGrabberView
- (BOOL)_autohideEffectivelyEnabled { return YES; }
@end
@interface UIApplicationSceneClientSettings : NSObject
- (BOOL)homeIndicatorAutoHidden;
@end
@implementation UIApplicationSceneClientSettings
- (BOOL)homeIndicatorAutoHidden { return YES; }
@end

@interface L16RMockScene : NSObject
@property(nonatomic) UIEdgeInsets safeAreaInsetsPortrait;
@property(nonatomic) UIEdgeInsets safeAreaInsetsPortraitUpsideDown;
@property(nonatomic) UIEdgeInsets safeAreaInsetsLandscapeLeft;
@property(nonatomic) UIEdgeInsets safeAreaInsetsLandscapeRight;
@end
@implementation L16RMockScene
@end

@interface SBHomeScreenViewController : UIViewController
@end
@implementation SBHomeScreenViewController
@end
@interface CSCoverSheetViewController : UIViewController
@end
@implementation CSCoverSheetViewController
@end

static void IncorrectSetter(id receiver, SEL selector, double value) {
    (void)receiver; (void)selector; (void)value;
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        assert(argc == 2);
        assert(!L16RHomebarValueIsEnabled(NULL));
        assert(!L16RHomebarValueIsEnabled(kCFBooleanFalse));
        assert(!L16RHomebarValueIsEnabled(CFSTR("true")));
        assert(!L16RHomebarValueIsEnabled((__bridge CFTypeRef)@1));
        assert(L16RHomebarValueIsEnabled(kCFBooleanTrue));

        BOOL off = strcmp(argv[1], "off") == 0;
        BOOL badABI = strcmp(argv[1], "bad-abi") == 0;
        Class sceneClass = objc_allocateClassPair([L16RMockScene class],
                                                   "UIMutableApplicationSceneSettings", 0);
        if (badABI) {
            class_addMethod(sceneClass, @selector(setSafeAreaInsetsLandscapeRight:),
                            (IMP)IncorrectSetter, "v@:d");
        }
        objc_registerClassPair(sceneClass);
        L16RMockScene *scene = [[sceneClass alloc] init];
        L16RConfigureHomebar(!off);

        assert([[SBFHomeGrabberSettings new] isEnabled] == !off);
        assert([[SBHomeGrabberView new] _autohideEffectivelyEnabled] == off);
        assert([[UIApplicationSceneClientSettings new] homeIndicatorAutoHidden] == off);
        // One indicator getter while off; no app layout hooks. An incompatible
        // orientation rejects all four inset hooks while preserving navigation.
        assert(hookCount == (off ? 1U : (badABI ? 5U : 9U)));

        UIEdgeInsets small = {8.0, 4.0, 0.0, 6.0};
        scene.safeAreaInsetsPortrait = small;
        scene.safeAreaInsetsPortraitUpsideDown = small;
        scene.safeAreaInsetsLandscapeLeft = small;
        UIEdgeInsets values[] = {scene.safeAreaInsetsPortrait,
            scene.safeAreaInsetsPortraitUpsideDown, scene.safeAreaInsetsLandscapeLeft};
        for (size_t i = 0; i < 3; i++) {
            assert(values[i].top == 8.0 && values[i].left == 4.0 && values[i].right == 6.0);
            assert(values[i].bottom == ((!off && !badABI) ? 21.0 : 0.0));
        }
        if (!badABI) {
            scene.safeAreaInsetsLandscapeRight = small;
            assert(scene.safeAreaInsetsLandscapeRight.bottom == (off ? 0.0 : 21.0));
        }
        UIEdgeInsets large = {0.0, 0.0, 34.0, 0.0};
        scene.safeAreaInsetsPortrait = large;
        assert(scene.safeAreaInsetsPortrait.bottom == 34.0);

        for (UIViewController *surface in @[[SBHomeScreenViewController new], [CSCoverSheetViewController new]]) {
            surface.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375, 667)];
            [surface viewDidLayoutSubviews];
            assert(surface.layoutPasses == 1);
            assert(surface.view.subviews.count == (off ? 0U : 1U));
            if (!off) {
                UIView *pill = surface.view.subviews.lastObject;
                assert(!pill.userInteractionEnabled && !pill.isAccessibilityElement && pill.accessibilityElementsHidden);
                assert(pill.frame.size.width == 134.0 && pill.frame.size.height == 5.0);
                assert(CGRectGetMaxY(pill.frame) == 659.0);
                [surface viewDidLayoutSubviews];
                assert(surface.view.subviews.count == 1 && surface.view.subviews.lastObject == pill);
                surface.view.bounds = CGRectMake(0, 0, 667, 375);
                [surface viewDidLayoutSubviews];
                assert(CGRectGetMidX(pill.frame) == 333.5 && CGRectGetMaxY(pill.frame) == 367.0);
                [pill removeFromSuperview];
                [surface viewDidLayoutSubviews];
                assert(pill.superview == surface.view && surface.view.subviews.count == 1);
            }
        }
        UIViewController *ordinary = [UIViewController new];
        ordinary.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375, 667)];
        [ordinary viewDidLayoutSubviews];
        assert(ordinary.view.subviews.count == 0);
        scene.safeAreaInsetsPortrait = scene.safeAreaInsetsPortrait;
        assert(scene.safeAreaInsetsPortrait.bottom == 34.0);
    }
    return 0;
}
