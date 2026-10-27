#import "HyperStudioPrefix.h"


@interface HSStoryboardCell : NSObject
{
    HSCardBorderRenderer *_cardBorderRenderer;
    NSTextStorage *_textStorage;
    NSLayoutManager *_layoutManager;
    NSTextContainer *_textContainer;
    NSSize _itemFrameSize;
    NSRect _cardImageFrame;
    NSRect _cardTitleFrame;
    NSRect _cardIndexFrame;
    unsigned int _requiredWidth;
    unsigned int _requiredHeight;
    unsigned int _boundsWidth;
    unsigned int _maxCardsPerRow;
    unsigned int _numberOfItems;
    BOOL _canRecacheCardThumbnail;
    BOOL _shouldDrawBadgedIcons;
    HSStoryboardLayout *_storyboardLayout;
    HSAuxiliaryUserObjectTraits *_auxiliaryUserObjectTraits;
}
+ (NSSize)requiredRenderingSizeForNumberOfItems:(NSUInteger)aItems;
+ (NSSize)requiredSizeForNumberOfDigits:(NSUInteger)aDigits;
+ (NSSize)calculateRequiredSizeForNumberOfDigits:(NSUInteger)aDigits;
+ (NSUInteger)defaultLineHeightWithLayoutManager:(id)aManager;
+ (NSUInteger)minimalAcceptableWidthForTitleStringWithTextStorage:(id)aStorage;
+ (id)indexRenderingAttributes;
+ (id)selectedTitleRenderingAttributes;
+ (id)titleRenderingAttributes;
+ (id)titleFont;
+ (NSSize)storyboardItemSizeForCardSize:(NSSize)aSize itemsCount:(NSUInteger)aCount offset:(NSPoint *)aOffset titleRect:(NSRect *)aRect cardIndexRect:(NSRect *)aRect2 defaultTitleSize:(NSSize)aSize2;
+ (NSSize)requiredSizeToFitNumberOfItems:(NSUInteger)aItems itemSize:(NSSize)aSize withMaxCardsPerRow:(NSUInteger)aRow;
- (void)renderIndex:(id)aIndex inRect:(NSRect)aRect;
- (void)renderTitle:(id)aTitle selected:(BOOL)aSelected inRect:(NSRect)aRect;
- (CGFloat)rolloverCornerRadius;
- (NSSize)defaultTitleSize;
- (BOOL)prepareTextStorageForRenderingIndex:(id)aIndex;
- (BOOL)prepareTextStorageForRenderingTitle:(id)aTitle selected:(BOOL)aSelected;
- (BOOL)prepareTextStorageForRenderingText:(id)aText attributeSelector:(SEL)aSelector;
- (id)textContainer;
- (id)layoutManager;
- (id)textStorage;
- (void)setCanRecacheCardThumbnail:(BOOL)aThumbnail;
- (BOOL)canRecacheCardThumbnail;
- (void)setShouldDrawBadgedIcons:(BOOL)aIcons;
- (BOOL)shouldDrawBadgedIcons;
- (id)auxiliaryUserObjectTraits;
- (BOOL)calcSizeWithScaledCardSize:(NSSize)aSize;
- (BOOL)calcSizeWithItemsCount:(NSUInteger)aCount;
- (BOOL)calcSizeWithScaledCardSize:(NSSize)aSize itemsCount:(NSUInteger)aCount;
- (BOOL)calcSizeWithBoundsWidth:(NSUInteger)aWidth;
- (BOOL)calcSizeWithBoundsWidth:(NSUInteger)aWidth force:(BOOL)aForce;
- (NSSize)requiredSizeToFitAllItems;
- (NSUInteger)maxCardsPerRow;
- (void)setNeedsDisplayItem:(id)aItem inView:(id)aView;
- (void)renderItem:(id)aItem inView:(id)aView rect:(NSRect)aRect;
- (id)selectedImageForItem:(id)aItem;
- (id)imageForItem:(id)aItem;
- (id)newImageForItem:(id)aItem selected:(BOOL)aSelected withText:(BOOL)aText;
- (BOOL)hitTestPoint:(NSPoint)aPoint inItem:(id)aItem atIndex:(NSUInteger)aIndex inView:(id)aView;
- (NSRect)borderedCardFrameForItem:(id)aItem atIndex:(NSUInteger)aIndex;
- (void)setCardBorderRenderer:(id)aRenderer;
- (id)cardBorderRenderer;
- (NSPoint)cardFrameOffset;
- (NSSize)cardFrameSize;
- (NSSize)itemFrameSize;
- (void)setStoryboardLayout:(id)aLayout;
- (id)storyboardLayout;
- (void)dealloc;
- (id)init;
@end

