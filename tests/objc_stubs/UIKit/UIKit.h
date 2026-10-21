#import <CoreGraphics/CoreGraphics.h>
// Host-only ABI stand-in. Production builds use Apple's iPhoneOS UIKit header.
typedef struct UIEdgeInsets {
    CGFloat top, left, bottom, right;
} UIEdgeInsets;
