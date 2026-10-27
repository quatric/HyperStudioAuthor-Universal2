#import "HSEffectCompositeController.h"

@implementation HSEffectCompositeController

- (void)setObject:(id)aObject
{
    [super setObject:aObject];
    [_originalPreviewImage release];
    _originalPreviewImage = nil;
}

- (void)update
{
    [[self previewController] update];
}

- (void)didMount
{
    [[self previewController] update];
}

- (void)didLoadNib
{
    [super didLoadNib];
    [_previewsContainer addSubview:[[self previewController] containerView]];
    [[[self previewController] containerView] setFrame:[_previewsContainer bounds]];
}

- (id)effectPreviewImage
{
    return [[self effectApplier] previewImageForImage:[[self effect] outputImage]];
}

- (id)originalPreviewImage
{
    if (_originalPreviewImage == nil)
        _originalPreviewImage = [[[self effectApplier] previewImageForImage:nil] retain];
    return _originalPreviewImage;
}

- (BOOL)isOriginalObjectFlippedHorizontally
{
    return [[self objectGeometryAttributes] isFlippedHorizontally];
}

- (BOOL)isOriginalObjectFlippedVertically
{
    return [[self objectGeometryAttributes] isFlippedVertically];
}

- (id)previewController
{
    if (_previewController == nil) {
        _previewController = [[HSEffectsPreviewController alloc] init];
        [_previewController setDelegate:self];
        [_previewController setDataSource:self];
    }
    return _previewController;
}

- (void)dealloc
{
    [_originalPreviewImage release];
    [_previewController release];
    [super dealloc];
}

@end
