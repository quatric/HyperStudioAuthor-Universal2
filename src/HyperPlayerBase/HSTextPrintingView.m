#import "HSTextPrintingView.h"
// Prints text over as many pages as it takes: a text container per page,
// added as the last one fills.
@implementation HSTextPrintingView
- (void)layoutManager:(id)aManager didCompleteLayoutForTextContainer:(id)aContainer atEnd:(BOOL)aEnd
{
    if (!aEnd && [[_contentLayoutManager textContainers] lastObject] == aContainer)
        [self addPage];
}
- (void)setContentText:(id)aText
{
    if (_contentLayoutManager != nil)
        [_contentTextStorage removeLayoutManager:_contentLayoutManager];
    [_contentTextStorage release];
    _contentTextStorage = nil;
    [_contentLayoutManager release];
    _contentLayoutManager = nil;
    if (aText != nil) {
        _contentTextStorage = [[NSTextStorage allocWithZone:[self zone]] initWithAttributedString:aText];
        _contentLayoutManager = [[NSLayoutManager allocWithZone:[self zone]] init];
        [_contentLayoutManager setDelegate:self];
        [_contentTextStorage addLayoutManager:_contentLayoutManager];
    }
}
- (void)addPage
{
    NSTextContainer *container = [[NSTextContainer allocWithZone:[self zone]] initWithContainerSize:[self contentSize]];
    [container setWidthTracksTextView:NO];
    [container setHeightTracksTextView:NO];
    [_contentLayoutManager addTextContainer:container];
    [container release];
}
// Drawing errors are ignored.
- (void)drawContent:(NSRect)aContent
{
    NSTextContainer *container = [[_contentLayoutManager textContainers] objectAtIndex:[self currentPage] - 1];
    if (container == nil)
        return;
    [NSGraphicsContext saveGraphicsState];
    NSRange range = [_contentLayoutManager glyphRangeForTextContainer:container];
    if (range.length != 0) {
        @try {
            [_contentLayoutManager drawBackgroundForGlyphRange:range atPoint:aContent.origin];
            [_contentLayoutManager drawGlyphsForGlyphRange:range atPoint:aContent.origin];
        } @catch (NSException *exception) {
        }
    }
    [NSGraphicsContext restoreGraphicsState];
}
- (void)layoutPages
{
    if ([[_contentLayoutManager textContainers] count] == 0) {
        [super layoutPages];
        [self addPage];
        [self relayout:_contentLayoutManager];
    }
}
- (NSUInteger)countOfPages
{
    return [[_contentLayoutManager textContainers] count];
}
- (void)dealloc
{
    if (_contentLayoutManager != nil)
        [_contentTextStorage removeLayoutManager:_contentLayoutManager];
    [_contentTextStorage release];
    [_contentLayoutManager release];
    [super dealloc];
}
- (id)initWithContentText:(id)aText
{
    self = [super initWithFrame:NSZeroRect];
    if (self != nil)
        [self setContentText:aText];
    return self;
}
@end
