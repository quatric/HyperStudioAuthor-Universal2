#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>

// The original OS answered an empty rect for the bounds of a path without
// elements; current AppKit raises "No current point for control point bounds".
// Callers throughout the sources rely on the old answer, so the two bounds
// getters are wrapped once at load time.
@interface NSBezierPath (HSEmptyPathBounds)
- (NSRect)HSEmptyPathBounds_bounds;
- (NSRect)HSEmptyPathBounds_controlPointBounds;
@end

@implementation NSBezierPath (HSEmptyPathBounds)

+ (void)load
{
    Method original = class_getInstanceMethod(self, @selector(bounds));
    Method wrapped = class_getInstanceMethod(self, @selector(HSEmptyPathBounds_bounds));
    if (original != NULL && wrapped != NULL)
        method_exchangeImplementations(original, wrapped);
    original = class_getInstanceMethod(self, @selector(controlPointBounds));
    wrapped = class_getInstanceMethod(self, @selector(HSEmptyPathBounds_controlPointBounds));
    if (original != NULL && wrapped != NULL)
        method_exchangeImplementations(original, wrapped);
}

// After the exchange these names run the original implementations.
- (NSRect)HSEmptyPathBounds_bounds
{
    if ([self elementCount] == 0)
        return NSZeroRect;
    return [self HSEmptyPathBounds_bounds];
}

- (NSRect)HSEmptyPathBounds_controlPointBounds
{
    if ([self elementCount] == 0)
        return NSZeroRect;
    return [self HSEmptyPathBounds_controlPointBounds];
}

@end
