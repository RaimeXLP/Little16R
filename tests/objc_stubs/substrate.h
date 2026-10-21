#import <objc/runtime.h>
void MSHookMessageEx(Class target, SEL selector, IMP replacement, IMP *original);
