#import "HSStepperCell.h"

@implementation HSStepperCell

- (void)setEnabled:(BOOL)aEnabled
{
    if ([self isEnabled] != aEnabled && [self image] != nil)
        [self setImage:aEnabled ? [_imageProvider stepperNoPressedImage] : [_imageProvider stepperNoPressedDisabledImage]];
    [super setEnabled:aEnabled];
}

- (void)useDefaultImages
{
    [self setImage:[_imageProvider stepperNoPressedImage]];
}

// Position 1 is the up arrow, 0 the down arrow.
- (NSRect)rectForImagePosition:(NSInteger)aPosition
{
    NSSize cellSize = [self cellSize];
    BOOL flipped = [[self controlView] isFlipped];
    if ((aPosition == 1 && !flipped) || (aPosition == 0 && flipped))
        return NSMakeRect(0.0, cellSize.height * 0.5f, cellSize.width, cellSize.height * 0.5f);
    if ((aPosition == 0 && !flipped) || (aPosition == 1 && flipped))
        return NSMakeRect(0.0, 0.0, cellSize.width, cellSize.height * 0.5f);
    return NSZeroRect;
}

- (NSRect)imageRectForBounds:(NSRect)aBounds
{
    NSImage *image = [self image];
    NSSize imageSize = image != nil ? [image size] : NSZeroSize;
    NSSize cellSize = [self cellSize];
    return NSMakeRect((cellSize.width - imageSize.width) * 0.5f + aBounds.origin.x, (cellSize.height - imageSize.height) * 0.5f + aBounds.origin.y, imageSize.width, imageSize.height);
}

- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView
{
    BOOL showsFirstResponder = [self showsFirstResponder];
    if (showsFirstResponder) {
        [NSGraphicsContext saveGraphicsState];
        [self setFocusRingType:NSFocusRingTypeDefault];
        NSSetFocusRingStyle(NSFocusRingAbove);
    }
    if ([self image] != nil)
        [super drawInteriorWithFrame:aFrame inView:aView];
    if (showsFirstResponder)
        [NSGraphicsContext restoreGraphicsState];
}

- (void)stopTracking:(NSPoint)aTracking at:(NSPoint)aAt inView:(id)aView mouseIsUp:(BOOL)aUp
{
    _startTrackingPosition = 2;
    if ([self image] != nil)
        [self setImage:[_imageProvider stepperNoPressedImage]];
    [super stopTracking:aTracking at:aAt inView:aView mouseIsUp:aUp];
}

- (BOOL)continueTracking:(NSPoint)aTracking at:(NSPoint)aAt inView:(id)aView
{
    if ([self image] != nil) {
        if (NSPointInRect(aAt, [self rectForImagePosition:1]) && _startTrackingPosition == 1)
            [self setImage:[_imageProvider stepperUpPressedImage]];
        else if (NSPointInRect(aAt, [self rectForImagePosition:0]) && _startTrackingPosition == 0)
            [self setImage:[_imageProvider stepperDownPressedImage]];
    }
    return [super continueTracking:aTracking at:aAt inView:aView];
}

- (BOOL)startTrackingAt:(NSPoint)aAt inView:(id)aView
{
    if (NSPointInRect(aAt, [self rectForImagePosition:1])) {
        _startTrackingPosition = 1;
        if ([self image] != nil)
            [self setImage:[_imageProvider stepperUpPressedImage]];
    } else {
        _startTrackingPosition = 0;
        if ([self image] != nil)
            [self setImage:[_imageProvider stepperDownPressedImage]];
    }
    return [super startTrackingAt:aAt inView:aView];
}

- (void)dealloc
{
    [super dealloc];
}

- (id)initWithCoder:(id)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self != nil) {
        _imageProvider = [HSControlslImageProvider sharedImageProvider];
        [self useDefaultImages];
    }
    return self;
}

- (id)initImageCell:(id)aCell
{
    self = [super initImageCell:aCell];
    if (self != nil) {
        _imageProvider = [HSControlslImageProvider sharedImageProvider];
        if (aCell == nil)
            [self useDefaultImages];
    }
    return self;
}

@end
