#import "HyperStudioPrefix.h"


@interface HSSegmentGraphicObject : NSObject
{
    NSRect _bounds;
}
- (void)drawInRect:(NSRect)aRect;
- (BOOL)hitTest:(NSPoint)aTest;
- (void)setBounds:(NSRect)aBounds;
- (NSRect)bounds;
@end

