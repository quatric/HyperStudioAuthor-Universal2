#import "HSPaneScroller.h"

// A vertical scroller drawn with the pane images: arrows apart (top and
// bottom) or together (both at the bottom), and a three-part knob.
//
// _scrollerImages: 0/1 down arrow (pressed), 2/3 together down arrow,
// 4/5 up arrow, 6/7 together up arrow, 8 top cap, 9 slot, 10-12 knob
// top, middle and bottom; _scrollerImagesRects are their sizes (one per
// pair).

@implementation HSPaneScroller

- (BOOL)isScrollerTogether
{
    id variant = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleScrollBarVariant"];
    return [variant isEqualToString:@"DoubleMax"] || variant == nil;
}

- (void)loadScrollerImages
{
    HSControlslImageProvider *provider = [HSControlslImageProvider sharedImageProvider];
    _scrollerImages[0] = [[provider verticalScrollerDownImage] retain];
    _scrollerImages[1] = [[provider verticalScrollerDownPressedImage] retain];
    _scrollerImagesRects[0] = [self imageRect:_scrollerImages[0]];
    _scrollerImages[2] = [[provider verticalScrollerTogetherDownImage] retain];
    _scrollerImages[3] = [[provider verticalScrollerTogetherDownPressedImage] retain];
    _scrollerImagesRects[1] = [self imageRect:_scrollerImages[2]];
    _scrollerImages[4] = [[provider verticalScrollerUpImage] retain];
    _scrollerImages[5] = [[provider verticalScrollerUpPressedImage] retain];
    _scrollerImagesRects[2] = [self imageRect:_scrollerImages[4]];
    _scrollerImages[6] = [[provider verticalScrollerTogetherUpImage] retain];
    _scrollerImages[7] = [[provider verticalScrollerTogetherUpPressedImage] retain];
    _scrollerImagesRects[3] = [self imageRect:_scrollerImages[6]];
    _scrollerImages[8] = [[provider verticalScrollerTopImage] retain];
    _scrollerImagesRects[4] = [self imageRect:_scrollerImages[8]];
    _scrollerImages[9] = [[provider verticalScrollerMiddleImage] retain];
    _scrollerImagesRects[5] = [self imageRect:_scrollerImages[9]];
    _scrollerImages[10] = [[provider verticalScrollerTopKnobImage] retain];
    _scrollerImages[11] = [[provider verticalScrollerMiddleKnobImage] retain];
    _scrollerImages[12] = [[provider verticalScrollerBottomKnobImage] retain];
    _scrollerImagesRects[6] = [self imageRect:_scrollerImages[10]];
    _scrollerImagesRects[7] = [self imageRect:_scrollerImages[11]];
    _scrollerImagesRects[8] = [self imageRect:_scrollerImages[12]];
    [self applyFlipToImagesIfNeeded];
}

- (void)applyFlipToImagesIfNeeded
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    BOOL flipped = [self isFlipped];
    for (NSInteger i = 0; i < 13; i++) {
        if ([_scrollerImages[i] isFlipped] != flipped)
            [_scrollerImages[i] setFlipped:flipped];
    }
#pragma clang diagnostic pop
}

- (NSRect)imageRect:(id)aRect
{
    NSRect rect = NSZeroRect;
    rect.size = [(NSImage *)aRect size];
    return rect;
}

// The rect (pixel aligned) the image at the position is drawn in.
- (NSRect)rectForImagePosition:(NSInteger)aPosition
{
    NSRect bounds = [self bounds];
    NSRect slot = [self rectForPart:NSScrollerKnobSlot];
    NSRect rect = NSZeroRect;
    switch (aPosition) {
        case 0:
        case 1:
            rect.size = _scrollerImagesRects[0].size;
            rect.origin.y = bounds.size.height - rect.size.height;
            break;
        case 2:
        case 3:
            rect.size = _scrollerImagesRects[1].size;
            rect.origin.y = bounds.size.height - rect.size.height;
            break;
        case 4:
        case 5:
            rect.size = _scrollerImagesRects[2].size;
            break;
        case 6:
        case 7:
            rect.size = _scrollerImagesRects[3].size;
            rect.origin.y = bounds.size.height - _scrollerImagesRects[1].size.height - rect.size.height;
            break;
        case 8:
            rect.size = _scrollerImagesRects[4].size;
            break;
        case 10:
            rect.size = _scrollerImagesRects[6].size;
            rect.origin.x = (slot.size.width - rect.size.width) * 0.5;
            rect.origin.y = slot.origin.y;
            break;
        case 11:
            rect.size.width = _scrollerImagesRects[7].size.width;
            rect.size.height = slot.size.height - (_scrollerImagesRects[6].size.height + _scrollerImagesRects[8].size.height);
            rect.origin.x = (slot.size.width - rect.size.width) * 0.5;
            rect.origin.y = slot.origin.y + _scrollerImagesRects[6].size.height;
            break;
        case 12:
            rect.size = _scrollerImagesRects[8].size;
            rect.origin.x = (slot.size.width - rect.size.width) * 0.5;
            rect.origin.y = slot.origin.y + slot.size.height - rect.size.height;
            break;
    }
    rect = NSIntegralRect([self convertRect:rect toView:nil]);
    return [self convertRect:rect fromView:nil];
}

- (void)drawKnobSlotInRect:(NSRect)aRect highlight:(BOOL)aHighlight
{
    [_scrollerImages[9] drawInRect:aRect fromRect:_scrollerImagesRects[5] operation:NSCompositingOperationCopy fraction:1.0];
}

- (void)drawKnob
{
    for (NSInteger i = 0; i < 3; i++)
        [_scrollerImages[10 + i] drawInRect:[self rectForImagePosition:10 + i] fromRect:_scrollerImagesRects[6 + i] operation:NSCompositingOperationSourceOver fraction:1.0];
}

- (void)drawArrow:(NSInteger)aArrow highlightPart:(NSInteger)aPart
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    _isScrollerTogether = [self isScrollerTogether];
    if (aArrow == NSScrollerDecrementArrow) {
        if (_isScrollerTogether) {
            [_scrollerImages[8] drawInRect:[self rectForImagePosition:8] fromRect:_scrollerImagesRects[4] operation:NSCompositingOperationCopy fraction:1.0];
        } else {
            NSInteger position = aPart == 1 ? 5 : 4;
            [_scrollerImages[position] drawInRect:[self rectForImagePosition:position] fromRect:_scrollerImagesRects[2] operation:NSCompositingOperationCopy fraction:1.0];
        }
    } else if (aArrow == NSScrollerIncrementArrow) {
        if (_isScrollerTogether) {
            NSInteger position = aPart == 0 ? 3 : 2;
            [_scrollerImages[position] drawInRect:[self rectForImagePosition:position] fromRect:_scrollerImagesRects[1] operation:NSCompositingOperationCopy fraction:1.0];
            position = aPart == 1 ? 7 : 6;
            [_scrollerImages[position] drawInRect:[self rectForImagePosition:position] fromRect:_scrollerImagesRects[3] operation:NSCompositingOperationCopy fraction:1.0];
        } else {
            NSInteger position = aPart == 0 ? 1 : 0;
            [_scrollerImages[position] drawInRect:[self rectForImagePosition:position] fromRect:_scrollerImagesRects[0] operation:NSCompositingOperationCopy fraction:1.0];
        }
    }
#pragma clang diagnostic pop
}

- (void)dealloc
{
    for (NSInteger i = 0; i < 13; i++)
        [_scrollerImages[i] release];
    [super dealloc];
}

- (id)initWithCoder:(id)aCoder
{
    if ((self = [super initWithCoder:aCoder]))
        [self defaultInitialization];
    return self;
}

- (id)initWithFrame:(NSRect)aFrame
{
    if ((self = [super initWithFrame:aFrame]))
        [self defaultInitialization];
    return self;
}

- (void)defaultInitialization
{
    [self loadScrollerImages];
    _isScrollerTogether = [self isScrollerTogether];
}

@end
