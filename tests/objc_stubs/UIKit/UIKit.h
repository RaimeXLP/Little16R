#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
// Host-only ABI stand-in. Production builds use Apple's iPhoneOS UIKit header.
typedef struct UIEdgeInsets {
    CGFloat top, left, bottom, right;
} UIEdgeInsets;

@interface UIColor : NSObject
+ (instancetype)whiteColor;
+ (instancetype)blackColor;
@property(nonatomic, readonly) CGColorRef CGColor;
@end
@interface UIView : NSObject
- (instancetype)initWithFrame:(CGRect)frame;
@property(nonatomic) CGRect frame;
@property(nonatomic) CGRect bounds;
@property(nonatomic) BOOL userInteractionEnabled;
@property(nonatomic) BOOL isAccessibilityElement;
@property(nonatomic) BOOL accessibilityElementsHidden;
@property(nonatomic, strong) UIColor *backgroundColor;
@property(nonatomic, readonly) CALayer *layer;
@property(nonatomic, weak, readonly) UIView *superview;
@property(nonatomic, readonly) NSArray<UIView *> *subviews;
- (void)addSubview:(UIView *)view;
- (void)bringSubviewToFront:(UIView *)view;
- (void)removeFromSuperview;
@end
@interface UIViewController : NSObject
@property(nonatomic, strong) UIView *view;
@property(nonatomic) NSUInteger layoutPasses;
- (void)viewDidLayoutSubviews;
@end
