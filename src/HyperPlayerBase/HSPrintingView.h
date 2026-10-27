#import "HyperPlayerBasePrefix.h"


@interface HSPrintingView : NSView
{
    NSString *_printJobTitle;
    int _currentPage;
    NSTextStorage *_headerTextStorage;
    NSLayoutManager *_headerLayoutManager;
    NSTextStorage *_footerTextStorage;
    NSLayoutManager *_footerLayoutManager;
}
- (void)layoutFooter;
- (void)layoutHeader;
- (void)createHeaderFooterTextContainer:(id)aContainer;
- (void)layoutPages;
- (void)drawFooter:(NSRect)aFooter;
- (void)drawHeader:(NSRect)aHeader;
- (NSSize)footerSize;
- (NSSize)headerSize;
- (NSSize)pageSize;
- (void)drawRect:(NSRect)aRect;
- (NSPoint)locationOfPrintRect:(NSRect)aRect;
- (NSRect)rectForPage:(NSInteger)aPage;
- (BOOL)knowsPageRange:(NSRange *)aRange;
- (id)printJobTitle;
- (BOOL)isFlipped;
- (NSSize)contentSize;
- (void)drawContent:(NSRect)aContent;
- (void)relayout:(id)aRelayout;
- (NSInteger)currentPage;
- (NSUInteger)countOfPages;
- (void)preparePrinting;
- (void)setPrintJobTitle:(id)aTitle;
- (void)setFooterText:(id)aText;
- (void)setHeaderText:(id)aText;
- (void)dealloc;
@end

