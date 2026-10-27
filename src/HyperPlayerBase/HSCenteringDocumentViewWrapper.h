#import "HyperPlayerBasePrefix.h"


@interface HSCenteringDocumentViewWrapper : NSView
{
    NSView *_subviewToCenter;
}
- (void)HSCenteringDocumentViewWrapper_environmentDidChange:(id)aChange;
- (void)willRemoveSubview:(id)aSubview;
- (void)viewDidMoveToSuperview;
- (void)viewWillMoveToSuperview:(id)aSuperview;
- (void)setFrameSize:(NSSize)aSize;
- (void)setBoundsSize:(NSSize)aSize;
- (void)setSubviewToCenter:(id)aCenter;
- (id)subviewToCenter;
- (void)awakeFromNib;
- (BOOL)isFlipped;
- (void)HSCenteringDocumentViewWrapper_positionSubview;
- (void)HSCenteringDocumentViewWrapper_recalculateFrameSize;
@end

