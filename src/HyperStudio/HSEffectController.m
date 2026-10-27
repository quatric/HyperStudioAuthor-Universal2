#import "HSEffectController.h"

@implementation HSEffectController

+ (id)createEffect
{
    return nil;
}

- (id)objectGeometryAttributes
{
    if (!_geometryAttributes)
        _geometryAttributes = [[[self object] queryHyperInterface:@protocol(HSGeometryAttributes)] retain];
    return _geometryAttributes;
}

- (void)applyChanges
{
    [[self effectApplier] setUndoActionName:[self undoActionName]];
    [[self effectApplier] applyHyperEffect:[self effect]];
}

- (id)undoActionName
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)update
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)didUnmount
{
}

- (void)willUnmount
{
}

- (void)didMount
{
}

- (void)willMount
{
}

- (id)effectApplier
{
    if (!_effectApplier)
        _effectApplier = [[HSHyperObjectEffectApplier effectApplierForHyperObject:[self object]] retain];
    return _effectApplier;
}

- (id)effect
{
    if (!_effect) {
        _effect = [[self class] createEffect];
        [_effect setInputImage:[[self effectApplier] previewImage]];
    }
    return _effect;
}

- (id)object
{
    return _object;
}

- (void)didLoadNib
{
    [self revertSettingsToDefault];
}

- (id)contentView
{
    [self loadNibIfNeeded];
    return _contentView;
}

- (void)revertSettingsToDefault
{
    [self doesNotRecognizeSelector:_cmd];
}

- (id)nibName
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)loadNibIfNeeded
{
    if (!_contentView) {
        [NSBundle loadNibNamed:[self nibName] owner:self];
        [self didLoadNib];
    }
}

- (void)setObject:(id)aObject
{
    if (_object != aObject) {
        [_object release];
        _object = [aObject retain];
        [_geometryAttributes release];
        _geometryAttributes = nil;
    }
    [_effectApplier release];
    _effectApplier = nil;
    [[self effect] setInputImage:[[self effectApplier] previewImage]];
    [self update];
}

- (id)initWithObject:(id)aObject
{
    self = [super init];
    if (self)
        _object = [aObject retain];
    return self;
}

- (id)init
{
    return [self initWithObject:nil];
}

- (void)dealloc
{
    [_effectApplier release];
    [_effect release];
    [_geometryAttributes release];
    [_object release];
    [super dealloc];
}

@end
