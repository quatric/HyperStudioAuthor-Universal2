#import "HSEraseBackgroundView.h"

@implementation HSEraseBackgroundView

- (void)invalidateCardSubobjectsImage
{
    [_cardSubobjectsImage release];
    _cardSubobjectsImage = nil;
}

- (id)cardSubobjectsImage
{
    if (_cardSubobjectsImage == nil && _cardSizeAttributes != nil) {
        NSSize size = [(id<HSSizeAttributes>)_cardSizeAttributes size];
        if (size.width > 0.0 && size.height > 0.0) {
            _cardSubobjectsImage = [[NSImage alloc] initWithSize:size];
            [_cardSubobjectsImage setFlipped:YES];
            [_cardSubobjectsImage lockFocus];
            [[self cardRenderer] drawRegion:[HSRegion regionWithRect:NSMakeRect(0.0, 0.0, size.width, size.height)] withDelegate:[self genericRenderDelegate]];
            [_cardSubobjectsImage unlockFocus];
        }
    }
    return _cardSubobjectsImage;
}

- (id)cardRenderer
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"HSSubobjectsOnlyVisualizationOption", nil];
    return [[[self card] queryHyperInterface:@protocol(HSPlayerVisualization)] queryRendererWithVisualizationOptions:options];
}

- (id)genericRenderDelegate
{
    return [HSGenericRenderDelegate delegateWithDrawable:nil];
}

- (id)backgroundColor
{
    return _backgroundColor;
}

- (void)setBackgroundColor:(id)aColor
{
    if (_backgroundColor != aColor) {
        [_backgroundColor release];
        _backgroundColor = [aColor retain];
    }
}

- (id)card
{
    return _card;
}

- (void)setCard:(id)aCard
{
    if (_card != aCard) {
        [_cardSizeAttributes release];
        [_card release];
        _card = [aCard retain];
        _cardSizeAttributes = [[_card queryHyperInterface:@protocol(HSSizeAttributes)] retain];
        [self invalidateCardSubobjectsImage];
    }
}

- (void)drawRect:(NSRect)aRect
{
    NSRect bounds = [self bounds];
    NSSize cardSize = [(id<HSSizeAttributes>)_cardSizeAttributes size];
    CGFloat cardAspect = cardSize.width / cardSize.height;
    if (cardAspect == 0.0)
        return;
    CGFloat viewAspect = bounds.size.width / bounds.size.height;
    if (viewAspect == 0.0)
        return;
    NSRect drawRect;
    if (cardAspect <= viewAspect) {
        drawRect.size.width = (cardAspect / viewAspect) * bounds.size.width;
        drawRect.size.height = bounds.size.height;
        drawRect.origin.x = (bounds.size.width - drawRect.size.width) * 0.5;
        drawRect.origin.y = 0.0;
    } else {
        drawRect.size.width = bounds.size.width;
        drawRect.size.height = bounds.size.height / (cardAspect / viewAspect);
        drawRect.origin.x = 0.0;
        drawRect.origin.y = (bounds.size.height - drawRect.size.height) * 0.5;
    }
    [(NSColor *)[self backgroundColor] set];
    NSRectFill(drawRect);
    NSImage *image = [self cardSubobjectsImage];
    NSSize imageSize = [image size];
    [image drawInRect:drawRect fromRect:NSMakeRect(0.0, 0.0, imageSize.width, imageSize.height) operation:NSCompositingOperationSourceOver fraction:1.0];
}

- (void)dealloc
{
    [_cardSizeAttributes release];
    [_card release];
    [_cardSubobjectsImage release];
    [_backgroundColor release];
    [super dealloc];
}

@end
