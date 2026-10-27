#import "HSStoryboardLayout.h"

@implementation HSStoryboardLayout

- (void)animationDidEnd:(id)aEnd
{
    int count = (int)[_items numberOfItems];
    for (int i = 0; i < count; i++)
        [[_items objectInStoryboardItemsAtIndex:i] endAnimation];
    [_delegate animationDidEndForStoryboardLayout:self];
}

- (void)animationDidStop:(id)aStop
{
    [_delegate animationDidEndForStoryboardLayout:self];
}

- (void)invalidateLayoutWithAnimation:(BOOL)aAnimation
{
    if ([_animation isAnimating] && aAnimation)
        [_animation stopAnimation];
    int count = (int)[_items numberOfItems];
    for (int i = 0; i < count; i++) {
        id item = [_items objectInStoryboardItemsAtIndex:i];
        if (aAnimation) {
            [item animateToFrame:[self frameForItemAtIndex:i]];
        } else {
            [(NSView *)item setFrame:[self frameForItemAtIndex:i]];
            [item invalidateAnimation];
        }
    }
    if (aAnimation) {
        [_animation release];
        _animation = [self newAnimation];
        [_delegate animationWillStartForStoryboardLayout:self];
        [_animation startAnimation];
    }
}

- (void)invalidateLayout
{
    [self invalidateLayoutWithAnimation:YES];
}

- (NSUInteger)itemIndexAtPoint:(NSPoint)aPoint
{
    NSUInteger cardsPerRow = [_cell maxCardsPerRow];
    NSUInteger column = (NSUInteger)(aPoint.x / [_cell itemFrameSize].width);
    if (cardsPerRow < column)
        return NSNotFound;
    NSUInteger row = (NSUInteger)(aPoint.y / [_cell itemFrameSize].height);
    NSUInteger index = row * cardsPerRow + column;
    return index < [_items numberOfItems] ? index : NSNotFound;
}

- (NSRect)frameForItemAtIndex:(NSInteger)aIndex
{
    int cardsPerRow = (int)[_cell maxCardsPerRow];
    NSSize itemSize = [_cell itemFrameSize];
    return NSMakeRect(itemSize.width * (float)((int)aIndex % cardsPerRow), itemSize.height * (float)((int)aIndex / cardsPerRow), itemSize.width, itemSize.height);
}

- (id)newAnimation
{
    id animation = [[NSClassFromString(@"HSStoryboardAnimation") alloc] initWithItems:_items duration:0.3];
    [animation setFrameRate:50.0f];
    [animation setAnimationBlockingMode:NSAnimationNonblocking];
    [animation setDelegate:self];
    return animation;
}

- (void)setCell:(id)aCell
{
    if (_cell != aCell) {
        [_cell release];
        _cell = [aCell retain];
    }
}

- (void)setItems:(id)aItems
{
    if (_items != aItems) {
        [_items release];
        _items = [aItems retain];
    }
}

- (void)dealloc
{
    [_cell release];
    [_items release];
    [_animation release];
    [super dealloc];
}

- (id)initWithItems:(id)aItems cell:(id)aCell delegate:(id)aDelegate
{
    self = [super init];
    if (self != nil) {
        [self setItems:aItems];
        [self setCell:aCell];
        [_cell setStoryboardLayout:self];
        _delegate = aDelegate;
    }
    return self;
}

@end
