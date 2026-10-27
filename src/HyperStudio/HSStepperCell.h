#import "HyperStudioPrefix.h"


@interface HSStepperCell : NSStepperCell
{
    NSRect _stepperImageRect;
    int _startTrackingPosition;
    HSControlslImageProvider *_imageProvider;
}
- (void)setEnabled:(BOOL)aEnabled;
- (void)useDefaultImages;
- (NSRect)rectForImagePosition:(NSInteger)aPosition;
- (NSRect)imageRectForBounds:(NSRect)aBounds;
- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView;
- (void)stopTracking:(NSPoint)aTracking at:(NSPoint)aAt inView:(id)aView mouseIsUp:(BOOL)aUp;
- (BOOL)continueTracking:(NSPoint)aTracking at:(NSPoint)aAt inView:(id)aView;
- (BOOL)startTrackingAt:(NSPoint)aAt inView:(id)aView;
- (void)dealloc;
- (id)initWithCoder:(id)aCoder;
- (id)initImageCell:(id)aCell;
@end

