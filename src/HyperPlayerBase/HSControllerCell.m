#import "HSControllerCell.h"
// The base of movie controller cells: a bar of controllerHeight below the
// movie (none here).
@implementation HSControllerCell
- (void)handleMouseDown:(id)aDown inRect:(NSRect)aRect ofView:(id)aView
{
}
- (NSRect)movieFrameForMovieArea:(NSRect)aArea isFlipped:(BOOL)aFlipped
{
    CGFloat height = [self controllerHeight];
    NSRect frame = aArea;
    if (!aFlipped)
        frame.origin.y -= [self controllerHeight];
    frame.size.height += height;
    return frame;
}
- (NSRect)movieAreaForMovieFrame:(NSRect)aFrame isFlipped:(BOOL)aFlipped
{
    CGFloat height = [self controllerHeight];
    NSRect area = aFrame;
    if (!aFlipped)
        area.origin.y += [self controllerHeight];
    area.size.height -= height;
    return area;
}
// (Below the frame's origin unflipped, as the original had it.)
- (NSRect)controllerAreaForMovieFrame:(NSRect)aFrame isFlipped:(BOOL)aFlipped
{
    CGFloat height = [self controllerHeight];
    CGFloat y = aFlipped ? aFrame.origin.y + (aFrame.size.height - height) : aFrame.origin.y - height;
    return NSMakeRect(aFrame.origin.x, y, aFrame.size.width, height);
}
- (CGFloat)controllerHeight
{
    return 0;
}
- (CGFloat)minControllerWidth
{
    return 0;
}
- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}
- (id)delegate
{
    return _delegate;
}
- (void)dealloc
{
    [self setDelegate:nil];
    [super dealloc];
}
@end
