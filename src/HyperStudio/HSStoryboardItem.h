#import "HyperStudioPrefix.h"


@interface HSStoryboardItem : NSObject
{
    id<HSStoryboardItemParent> _parent;
    HSCard *_card;
    BOOL _observesImageNotifications;
    BOOL _observesTitleNotifications;
    BOOL _isSelected;
    BOOL _isHighlighted;
    NSImage *_cardThumbnail;
    NSImage *_cachedItemImage;
    NSImage *_cachedSelectedItemImage;
    NSRect _frame;
    NSRect _sourceFrame;
    NSRect _destinationFrame;
    int _tag;
}
+ (id)placeholderImage;
- (void)invalidateAnimation;
- (void)endAnimation;
- (void)animateWithProgress:(CGFloat)aProgress;
- (void)animateToFrame:(NSRect)aFrame;
- (void)setFrame:(NSRect)aFrame;
- (NSRect)frame;
- (id)indexString;
- (id)titleString;
- (BOOL)isHighlighted;
- (void)setHighlighted:(BOOL)aHighlighted;
- (BOOL)isSelected;
- (void)setSelected:(BOOL)aSelected;
- (void)setCachedSelectedItemImage:(id)aImage;
- (id)cachedSelectedItemImage;
- (void)setCachedItemImage:(id)aImage;
- (id)cachedItemImage;
- (void)setCardThumbnail:(id)aThumbnail;
- (id)cachedCardThumbnail;
- (id)cardThumbnailForCardSize:(NSSize)aSize;
- (BOOL)needsRenderThumbnailOfSize:(NSSize)aSize;
- (void)invalidateImageCaches;
- (void)invalidateAllImageCaches;
- (void)exportDidEnd:(id)aEnd;
- (void)exportWillStart:(id)aStart;
- (void)observeNotificationsIfNeeded;
- (void)observeTitleNotificationsIfNeeded;
- (void)observeImageNotificationsIfNeeded;
- (void)setTag:(NSInteger)aTag;
- (NSInteger)tag;
- (void)setCard:(id)aCard;
- (id)card;
- (void)cardTitleDidChange:(id)aChange;
- (void)cardImageDidChange:(id)aChange;
- (id)parent;
- (void)setParent:(id)aParent;
- (void)dealloc;
@end

