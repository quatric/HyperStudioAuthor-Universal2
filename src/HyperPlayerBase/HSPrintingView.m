#import "HSPrintingView.h"

// Base print view: header and footer are laid out in their own text systems and drawn above and below the content.
@implementation HSPrintingView
- (void)layoutFooter
{
    [self createHeaderFooterTextContainer:_footerLayoutManager];
    [self relayout:_footerLayoutManager];
}
- (void)layoutHeader
{
    [self createHeaderFooterTextContainer:_headerLayoutManager];
    [self relayout:_headerLayoutManager];
}
- (void)createHeaderFooterTextContainer:(id)aContainer
{
    NSTextContainer *container = [[NSTextContainer allocWithZone:[self zone]] initWithContainerSize:[self pageSize]];
    [container setWidthTracksTextView:NO];
    [container setHeightTracksTextView:NO];
    [aContainer addTextContainer:container];
    [container release];
}
- (void)layoutPages
{
    [self layoutHeader];
    [self layoutFooter];
}
- (void)drawFooter:(NSRect)aFooter
{
    if (_footerTextStorage == nil)
        return;
    [NSGraphicsContext saveGraphicsState];
    NSRange range = [_footerLayoutManager glyphRangeForTextContainer:[[_footerLayoutManager textContainers] extraFirstObject]];
    if (range.length != 0) {
        @try {
            [_footerLayoutManager drawBackgroundForGlyphRange:range atPoint:aFooter.origin];
            [_footerLayoutManager drawGlyphsForGlyphRange:range atPoint:aFooter.origin];
        }
        @catch (NSException *exception) {
        }
    }
    [NSGraphicsContext restoreGraphicsState];
}
- (void)drawHeader:(NSRect)aHeader
{
    if (_headerTextStorage == nil)
        return;
    [NSGraphicsContext saveGraphicsState];
    NSRange range = [_headerLayoutManager glyphRangeForTextContainer:[[_headerLayoutManager textContainers] extraFirstObject]];
    if (range.length != 0) {
        @try {
            [_headerLayoutManager drawBackgroundForGlyphRange:range atPoint:aHeader.origin];
            [_headerLayoutManager drawGlyphsForGlyphRange:range atPoint:aHeader.origin];
        }
        @catch (NSException *exception) {
        }
    }
    [NSGraphicsContext restoreGraphicsState];
}
- (NSSize)footerSize
{
    NSRect rect = NSZeroRect;
    if (_footerTextStorage != nil)
        rect = [_footerLayoutManager usedRectForTextContainer:[[_footerLayoutManager textContainers] extraFirstObject]];
    return rect.size;
}
- (NSSize)headerSize
{
    NSRect rect = NSZeroRect;
    if (_headerTextStorage != nil)
        rect = [_headerLayoutManager usedRectForTextContainer:[[_headerLayoutManager textContainers] extraFirstObject]];
    return rect.size;
}
- (NSSize)pageSize
{
    NSPrintInfo *printInfo = [[NSPrintOperation currentOperation] printInfo];
    if ([printInfo respondsToSelector:@selector(imageablePageBounds)])
        return [printInfo imageablePageBounds].size;
    NSSize paperSize = [printInfo paperSize];
    return NSMakeSize(paperSize.width - ([printInfo leftMargin] + [printInfo rightMargin]),
                      paperSize.height - ([printInfo topMargin] + [printInfo bottomMargin]));
}
- (void)drawRect:(NSRect)aRect
{
    if ([self currentPage] == 0 || [[NSGraphicsContext currentContext] isDrawingToScreen])
        return;
    [self drawHeader:NSMakeRect(aRect.origin.x, aRect.origin.y, aRect.size.width, [self headerSize].height)];
    NSSize contentSize = [self contentSize];
    [self drawContent:NSMakeRect(aRect.origin.x, aRect.origin.y + [self headerSize].height, contentSize.width, contentSize.height)];
    CGFloat footerHeight = [self footerSize].height;
    [self drawFooter:NSMakeRect(aRect.origin.x, (aRect.origin.y + aRect.size.height) - [self footerSize].height, aRect.size.width, footerHeight)];
}
- (NSPoint)locationOfPrintRect:(NSRect)aRect
{
    NSPrintInfo *printInfo = [[NSPrintOperation currentOperation] printInfo];
    if ([printInfo respondsToSelector:@selector(imageablePageBounds)])
        return [printInfo imageablePageBounds].origin;
    return NSMakePoint([printInfo leftMargin], [printInfo topMargin]);
}
// Every page shares the view's frame; drawing tells pages apart by _currentPage.
- (NSRect)rectForPage:(NSInteger)aPage
{
    if ([self countOfPages] < (NSUInteger)aPage)
        return NSZeroRect;
    NSSize pageSize = [self pageSize];
    _currentPage = (int)aPage;
    return NSMakeRect(NSZeroRect.origin.x, NSZeroRect.origin.y, pageSize.width, pageSize.height);
}
- (BOOL)knowsPageRange:(NSRange *)aRange
{
    if (aRange == NULL)
        return NO;
    [self setFrameSize:[self pageSize]];
    [self layoutPages];
    aRange->location = 1;
    aRange->length = [self countOfPages];
    _currentPage = 0;
    return YES;
}
- (id)printJobTitle
{
    return _printJobTitle;
}
- (BOOL)isFlipped
{
    return YES;
}
- (NSSize)contentSize
{
    NSSize pageSize = [self pageSize];
    return NSMakeSize(pageSize.width, pageSize.height - ([self headerSize].height + [self footerSize].height));
}
- (void)drawContent:(NSRect)aContent
{
}
// Asking for the last line fragment forces the layout manager to lay out all its text.
- (void)relayout:(id)aRelayout
{
    NSUInteger count = [aRelayout numberOfGlyphs];
    if (count != 0)
        [aRelayout lineFragmentRectForGlyphAtIndex:count - 1 effectiveRange:NULL];
}
- (NSInteger)currentPage
{
    return _currentPage;
}
- (NSUInteger)countOfPages
{
    return 1;
}
- (void)preparePrinting
{
}
- (void)setPrintJobTitle:(id)aTitle
{
    if ([aTitle isEqualToString:_printJobTitle])
        return;
    [_printJobTitle release];
    _printJobTitle = [aTitle copy];
}
- (void)setFooterText:(id)aText
{
    if (_footerLayoutManager != nil)
        [_footerTextStorage removeLayoutManager:_footerLayoutManager];
    [_footerTextStorage release];
    _footerTextStorage = nil;
    [_footerLayoutManager release];
    _footerLayoutManager = nil;
    if (aText != nil) {
        _footerTextStorage = [[NSTextStorage allocWithZone:[self zone]] initWithAttributedString:aText];
        _footerLayoutManager = [[NSLayoutManager allocWithZone:[self zone]] init];
        [_footerTextStorage addLayoutManager:_footerLayoutManager];
    }
}
- (void)setHeaderText:(id)aText
{
    if (_headerLayoutManager != nil)
        [_headerTextStorage removeLayoutManager:_headerLayoutManager];
    [_headerTextStorage release];
    _headerTextStorage = nil;
    [_headerLayoutManager release];
    _headerLayoutManager = nil;
    if (aText != nil) {
        _headerTextStorage = [[NSTextStorage allocWithZone:[self zone]] initWithAttributedString:aText];
        _headerLayoutManager = [[NSLayoutManager allocWithZone:[self zone]] init];
        [_headerTextStorage addLayoutManager:_headerLayoutManager];
    }
}
- (void)dealloc
{
    [_printJobTitle release];
    if (_headerLayoutManager != nil)
        [_headerTextStorage removeLayoutManager:_headerLayoutManager];
    [_headerTextStorage release];
    [_headerLayoutManager release];
    if (_footerLayoutManager != nil)
        [_footerTextStorage removeLayoutManager:_footerLayoutManager];
    [_footerTextStorage release];
    [_footerLayoutManager release];
    [super dealloc];
}
@end
