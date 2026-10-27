#import "HyperEditorBasePrefix.h"
#import "HSDragImageView.h"


@interface HSDropImageView : HSDragImageView
{
}
- (void)paste:(id)aPaste;
- (void)setImage:(id)aImage;
- (void)concludeDragOperation:(id)aOperation;
- (NSUInteger)draggingEntered:(id)aEntered;
@end

