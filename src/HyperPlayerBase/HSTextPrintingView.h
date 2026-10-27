#import "HyperPlayerBasePrefix.h"
#import "HSPrintingView.h"


@interface HSTextPrintingView : HSPrintingView <NSLayoutManagerDelegate, NSObject>
{
    NSTextStorage *_contentTextStorage;
    NSLayoutManager *_contentLayoutManager;
}
- (void)layoutManager:(id)aManager didCompleteLayoutForTextContainer:(id)aContainer atEnd:(BOOL)aEnd;
- (void)setContentText:(id)aText;
- (void)addPage;
- (void)drawContent:(NSRect)aContent;
- (void)layoutPages;
- (NSUInteger)countOfPages;
- (void)dealloc;
- (id)initWithContentText:(id)aText;
@end

