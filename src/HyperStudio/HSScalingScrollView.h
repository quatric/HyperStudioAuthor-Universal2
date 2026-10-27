#import "HyperStudioPrefix.h"


@interface HSScalingScrollView : NSScrollView
{
    HSEditorCardView *_cardView;
    BOOL _isInsideScrollViewWillTileNotification;
    BOOL _isNotInEditMode;
}
- (void)setDocumentView:(id)aView;
- (void)scrollWheel:(id)aWheel;
- (id)cardViewInEditMode;
- (void)setInEditMode:(BOOL)aMode;
- (BOOL)isInEditMode;
- (void)reflectScrolledClipView:(id)aView;
- (void)setFrameSize:(NSSize)aSize;
- (void)awakeFromNib;
- (void)dealloc;
@end

