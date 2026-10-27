#import "HSSegmentGraphicObject.h"

@implementation HSSegmentGraphicObject

- (void)drawInRect:(NSRect)aRect
{
}

- (BOOL)hitTest:(NSPoint)aTest
{
    return NSPointInRect(aTest, _bounds);
}

- (void)setBounds:(NSRect)aBounds
{
    _bounds = aBounds;
}

- (NSRect)bounds
{
    return _bounds;
}

@end
