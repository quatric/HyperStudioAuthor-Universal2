#import "HSTrackingButtonCell.h"

@implementation HSTrackingButtonCell

// Tracks the mouse to its release, highlighting the cell while it's inside
// and telling the delegate each step.
+ (BOOL)trackingButtonCell:(id)aCell trackMouse:(id)aMouse inRect:(NSRect)aRect ofView:(id)aView untilMouseUp:(BOOL)aUp
{
    [aCell setHighlighted:YES];
    [aView setNeedsDisplay:YES];
    [[aCell delegate] trackingButtonCell:aCell isTracking:YES wasTracking:NO isInside:YES wasInside:NO];
    BOOL wasInside = YES, isInside;
    for (;;) {
        NSEvent *event = [[aView window] nextEventMatchingMask:NSEventMaskLeftMouseUp | NSEventMaskLeftMouseDragged untilDate:[NSDate distantFuture]
                                                         inMode:NSDefaultRunLoopMode dequeue:YES];
        isInside = NSPointInRect([aView convertPoint:[event locationInWindow] fromView:nil], aRect);
        if ([event type] == NSEventTypeLeftMouseUp)
            break;
        if ([event type] == NSEventTypeLeftMouseDragged) {
            [aCell setHighlighted:isInside];
            [aView setNeedsDisplay:YES];
            [[aCell delegate] trackingButtonCell:aCell isTracking:YES wasTracking:YES isInside:isInside wasInside:wasInside];
        }
        wasInside = isInside;
    }
    [aCell setHighlighted:NO];
    [aView setNeedsDisplay:YES];
    [[aCell delegate] trackingButtonCell:aCell isTracking:NO wasTracking:YES isInside:isInside wasInside:wasInside];
    return YES;
}

- (BOOL)trackMouse:(id)aMouse inRect:(NSRect)aRect ofView:(id)aView untilMouseUp:(BOOL)aUp
{
    return [[self class] trackingButtonCell:self trackMouse:aMouse inRect:aRect ofView:aView untilMouseUp:aUp];
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

@end
