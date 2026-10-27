#import "HSEffectsPreviewController.h"

@implementation HSEffectsPreviewController

- (void)mouseDownAtPoint:(NSPoint)aPoint atColor:(id)aColor inView:(id)aView
{
    if (aView == _originalPreview && [_delegate respondsToSelector:@selector(mouseDownInOriginalImageAtColor:)])
        [_delegate mouseDownInOriginalImageAtColor:aColor];
    else if (aView == _effectPreview && [_delegate respondsToSelector:@selector(mouseDownInEffectImageAtColor:)])
        [_delegate mouseDownInEffectImageAtColor:aColor];
}

- (id)delegate
{
    return _delegate;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)dataSource
{
    return _dataSource;
}

- (void)setDataSource:(id)aSource
{
    _dataSource = aSource;
}

- (void)update
{
    BOOL flippedVertically = [_dataSource isOriginalObjectFlippedVertically];
    BOOL flippedHorizontally = [_dataSource isOriginalObjectFlippedHorizontally];
    [_originalPreview setFlippedVertically:flippedVertically];
    [_originalPreview setFlippedHorizontally:flippedHorizontally];
    [_originalPreview setImage:[_dataSource originalPreviewImage]];
    [_effectPreview setFlippedVertically:flippedVertically];
    [_effectPreview setFlippedHorizontally:flippedHorizontally];
    [_effectPreview setImage:[_dataSource effectPreviewImage]];
}

- (id)containerView
{
    [self loadNibIfNeeded];
    return _containerView;
}

- (void)loadNibIfNeeded
{
    if (_containerView != nil)
        return;
    [NSBundle loadNibNamed:@"EffectsPreview" owner:self];
    [_originalPreview setDelegate:self];
    [_effectPreview setDelegate:self];
}

@end
