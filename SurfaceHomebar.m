#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import <substrate.h>
#import "SurfaceHomebar.h"
#include <string.h>

// Home-button devices may omit the native indicator on these system surfaces
// even when the app indicator is enabled. Keep a passive visual inside each
// surface instead of spoofing hardware capabilities or creating a global window.
@interface L16RSurfacePill : UIView
@end
@implementation L16RSurfacePill
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        self.isAccessibilityElement = NO;
        self.accessibilityElementsHidden = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 2.5;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.65;
        self.layer.shadowRadius = 1.5;
        self.layer.shadowOffset = CGSizeZero;
    }
    return self;
}
@end

static char L16RSurfacePillKey;
static void L16RLayoutSurfacePill(UIViewController *controller) {
    UIView *host = controller.view;
    CGRect bounds = host.bounds;
    if (CGRectIsEmpty(bounds)) return;
    L16RSurfacePill *pill = objc_getAssociatedObject(host, &L16RSurfacePillKey);
    if (!pill) {
        pill = [[L16RSurfacePill alloc] initWithFrame:CGRectZero];
        objc_setAssociatedObject(host, &L16RSurfacePillKey, pill, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    CGFloat width = MIN(134.0, MAX(0.0, CGRectGetWidth(bounds) - 32.0));
    pill.frame = CGRectMake(CGRectGetMidX(bounds) - width / 2.0,
                            CGRectGetMaxY(bounds) - 13.0, width, 5.0);
    if (pill.superview != host) [host addSubview:pill];
    [host bringSubviewToFront:pill];
}

static void (*L16ROriginalHomeLayout)(id, SEL);
static void (*L16ROriginalLockLayout)(id, SEL);
static void L16RHomeLayout(id receiver, SEL selector) {
    L16ROriginalHomeLayout(receiver, selector);
    L16RLayoutSurfacePill(receiver);
}
static void L16RLockLayout(id receiver, SEL selector) {
    L16ROriginalLockLayout(receiver, selector);
    L16RLayoutSurfacePill(receiver);
}

static void L16RInstallSurfaceLayout(const char *name, IMP replacement, IMP *original) {
    Class target = objc_getClass(name);
    SEL layout = @selector(viewDidLayoutSubviews);
    Method method = target ? class_getInstanceMethod(target, layout) : NULL;
    NSMethodSignature *signature = method ?
        [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(method)] : nil;
    if (!target || ![target isSubclassOfClass:[UIViewController class]] ||
        !signature || signature.numberOfArguments != 2 ||
        strcmp(signature.methodReturnType, @encode(void)) != 0) {
        NSLog(@"[Little16R] Surface indicator unavailable: incompatible %s layout", name);
        return;
    }
    MSHookMessageEx(target, layout, replacement, original);
    NSLog(@"[Little16R] Surface indicator installed for %s", name);
}

void L16RInstallSurfaceHomebars(void) {
    L16RInstallSurfaceLayout("SBHomeScreenViewController", (IMP)L16RHomeLayout, (IMP *)&L16ROriginalHomeLayout);
    L16RInstallSurfaceLayout("CSCoverSheetViewController", (IMP)L16RLockLayout, (IMP *)&L16ROriginalLockLayout);
}
