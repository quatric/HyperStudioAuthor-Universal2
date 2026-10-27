#import "HSDropImageView.h"

@implementation HSDropImageView

- (void)paste:(id)aPaste
{
    if ([_delegate respondsToSelector:@selector(hyperImageViewDidPasted:)])
        [_delegate hyperImageViewDidPasted:self];
}

- (void)setImage:(id)aImage
{
    if ([self image] != aImage) {
        [super setImage:aImage];
        if ([_delegate respondsToSelector:@selector(hyperImageViewDidChangeImage:)])
            [_delegate hyperImageViewDidChangeImage:self];
    }
}

- (void)concludeDragOperation:(id)aOperation
{
    if ([_delegate respondsToSelector:@selector(hyperImageView:didAcceptedDropWithDraggingInfo:)])
        [_delegate hyperImageView:self didAcceptedDropWithDraggingInfo:aOperation];
    [super concludeDragOperation:aOperation];
}

- (NSUInteger)draggingEntered:(id)aEntered
{
    if ([_delegate respondsToSelector:@selector(draggingEntered:inHyperImageView:)])
        return (NSUInteger)[(id<NSObject>)_delegate performSelector:@selector(draggingEntered:inHyperImageView:) withObject:aEntered withObject:self];
    return [super draggingEntered:aEntered];
}

@end
