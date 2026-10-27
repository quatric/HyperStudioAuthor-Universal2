#import "HSScalingView.h"

@implementation HSScalingView

- (void)setScaleFactor:(NSSize)aFactor
{
    [self scaleUnitSquareToSize:[[NSAffineTransform hyperScalingBy:_scaleFactor] hyperInverseScaleFactor]];
    _scaleFactor = aFactor;
    [self scaleUnitSquareToSize:aFactor];
}

- (NSSize)scaleFactor
{
    return _scaleFactor;
}

- (BOOL)isOpaque
{
    return NO;
}

- (void)drawRect:(NSRect)aRect
{
    [[NSColor clearColor] set];
    NSRectFillUsingOperation(aRect, NSCompositingOperationSourceOver);
}

- (id)initWithFrame:(NSRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self != nil)
        _scaleFactor = [[NSAffineTransform transform] hyperScaleFactor];
    return self;
}

@end
