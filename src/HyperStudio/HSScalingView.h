#import "HyperStudioPrefix.h"


@interface HSScalingView : NSView
{
    NSSize _scaleFactor;
}
- (void)setScaleFactor:(NSSize)aFactor;
- (NSSize)scaleFactor;
- (BOOL)isOpaque;
- (void)drawRect:(NSRect)aRect;
- (id)initWithFrame:(NSRect)aFrame;
@end

