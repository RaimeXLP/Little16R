#import <UIKit/UIKit.h>

@interface UIColor ()
@property(nonatomic) BOOL white;
@end
@implementation UIColor
+ (instancetype)whiteColor { UIColor *color = [self new]; color.white = YES; return color; }
+ (instancetype)blackColor { return [self new]; }
- (CGColorRef)CGColor { return CGColorGetConstantColor(self.white ? kCGColorWhite : kCGColorBlack); }
@end

@interface UIView ()
@property(nonatomic, strong) CALayer *layer;
@property(nonatomic, weak) UIView *superview;
@property(nonatomic, strong) NSMutableArray<UIView *> *children;
@end
@implementation UIView
- (instancetype)init { return [self initWithFrame:CGRectZero]; }
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        _frame = frame;
        _bounds = (CGRect){CGPointZero, frame.size};
        _layer = [CALayer layer];
        _children = [NSMutableArray array];
        _userInteractionEnabled = YES;
    }
    return self;
}
- (void)setFrame:(CGRect)frame { _frame = frame; _bounds.size = frame.size; }
- (NSArray *)subviews { return [self.children copy]; }
- (void)addSubview:(UIView *)view {
    [view removeFromSuperview];
    [self.children addObject:view];
    view.superview = self;
}
- (void)bringSubviewToFront:(UIView *)view {
    if (view.superview == self) { [self.children removeObject:view]; [self.children addObject:view]; }
}
- (void)removeFromSuperview { [self.superview.children removeObject:self]; self.superview = nil; }
@end
@implementation UIViewController
- (void)viewDidLayoutSubviews { self.layoutPasses++; }
@end
