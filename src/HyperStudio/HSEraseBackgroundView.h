#import "HyperStudioPrefix.h"


@interface HSEraseBackgroundView : NSView
{
    HSCard *_card;
    id<HSSizeAttributes> _cardSizeAttributes;
    NSImage *_cardSubobjectsImage;
    NSColor *_backgroundColor;
}
- (void)invalidateCardSubobjectsImage;
- (id)cardSubobjectsImage;
- (id)cardRenderer;
- (id)genericRenderDelegate;
- (id)backgroundColor;
- (void)setBackgroundColor:(id)aColor;
- (id)card;
- (void)setCard:(id)aCard;
- (void)drawRect:(NSRect)aRect;
- (void)dealloc;
@end

