#import "HSConcreteCardObjectData.h"
#import "HSEffect.h"

@implementation HSConcreteCardObjectData

+ (id)nodeDataKeysToNodeKeysMap
{
    id map = [super nodeDataKeysToNodeKeysMap];
    [map removeObjectForKey:@"groupObjectFlag"];
    return map;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraStoringWithCodingContext:aContext]];
    if (![[aContext codingOperation] isEqualToString:@"HSObjectStyleCodingOperation"]) {
        [keys addObject:@"resizable"];
        [keys addObject:@"rotatableInPlayer"];
        [keys addObject:@"draggable"];
        [keys addObject:@"locked"];
        [keys addObject:@"hyperIgnoredInLayoutGuiding"];
        [keys addObject:@"dropOffOnly"];
        [keys addObject:@"noClick"];
        [keys addObject:@"groupObjectFlag"];
        [keys addObject:@"hidden"];
        [keys addObject:@"effectName"];
        [keys addObject:@"effectSettings"];
    }
    return keys;
}

- (void)applyEffectSettings
{
    NSEnumerator *enumerator = [[[self effectPerObject] inputKeys] objectEnumerator];
    id key;
    while ((key = [enumerator nextObject]) != nil) {
        id value = [[self effectSettings] objectForKey:key];
        if (value != nil)
            [[self effectPerObject] setValue:value forKey:key];
    }
}

- (void)setEffectSettings:(id)aSettings
{
    [aSettings retain];
    [_effectPerObjectSettings release];
    _effectPerObjectSettings = aSettings;
    if ([self effectPerObject] != nil)
        [self applyEffectSettings];
}

- (id)effectSettings
{
    return _effectPerObjectSettings;
}

- (void)setEffectName:(id)aName settings:(id)aSettings
{
    [_effectPerObject release];
    [aSettings retain];
    [_effectPerObjectSettings release];
    _effectPerObjectSettings = aSettings;
    if (aName == nil) {
        _effectPerObject = nil;
    } else {
        _effectPerObject = [[HSEffect effectWithName:aName] retain];
        [_effectPerObject setDefaults];
        if (_effectPerObjectSettings != nil)
            [self applyEffectSettings];
    }
}

- (void)setEffectName:(id)aName
{
    [self setEffectName:aName settings:_effectPerObjectSettings];
}

- (id)effectName
{
    return [(HSEffect *)[self effectPerObject] name];
}

- (id)effectPerObject
{
    return _effectPerObject;
}

- (void)setOpacity:(CGFloat)aOpacity
{
    _opacity = aOpacity;
}

- (CGFloat)opacity
{
    return _opacity;
}

- (void)setHidden:(BOOL)aHidden
{
    _hidden = aHidden;
    _isHiddenInPlayer = aHidden;
}

- (BOOL)isHidden
{
    return _hidden;
}

- (BOOL)isVisibleInEditor
{
    return _isVisibleInEditor;
}

- (void)setIsVisibleInEditor:(BOOL)aEditor
{
    _isVisibleInEditor = aEditor;
}

- (BOOL)isHiddenInPlayer
{
    return _isHiddenInPlayer;
}

- (void)setHiddenInPlayer:(BOOL)aPlayer
{
    _isHiddenInPlayer = aPlayer;
}

- (void)setGroupObjectFlag:(BOOL)aFlag
{
    _groupObjectFlag = aFlag;
}

- (BOOL)groupObjectFlag
{
    return _groupObjectFlag;
}

- (void)setNoClick:(BOOL)aClick
{
    _noClick = aClick;
}

- (BOOL)isNoClick
{
    return _noClick;
}

- (void)setDropOffOnly:(BOOL)aOnly
{
    _dropOffOnly = aOnly;
}

- (BOOL)isDropOffOnly
{
    return _dropOffOnly;
}

- (void)setHyperIgnoredInLayoutGuiding:(BOOL)aGuiding
{
    _hyperIgnoredInLayoutGuiding = aGuiding;
}

- (BOOL)isHyperIgnoredInLayoutGuiding
{
    return _hyperIgnoredInLayoutGuiding;
}

- (void)setLocked:(BOOL)aLocked
{
    _locked = aLocked;
}

- (BOOL)isLocked
{
    return _locked;
}

- (void)setDraggable:(BOOL)aDraggable
{
    _draggable = aDraggable;
}

- (BOOL)isDraggable
{
    return _draggable;
}

- (void)setRotatableInPlayer:(BOOL)aPlayer
{
    _rotatable = aPlayer;
}

- (BOOL)isRotatableInPlayer
{
    return _rotatable;
}

- (void)setResizable:(BOOL)aResizable
{
    _resizable = aResizable;
}

- (BOOL)isResizable
{
    return _resizable;
}

- (void)dealloc
{
    [_effectPerObjectSettings release];
    [_effectPerObject release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _resizable = NO;
        _rotatable = NO;
        _draggable = NO;
        _hidden = NO;
        _locked = NO;
        _hyperIgnoredInLayoutGuiding = NO;
        _dropOffOnly = NO;
        _noClick = NO;
        _groupObjectFlag = NO;
        _isVisibleInEditor = YES;
        _opacity = 1.0f;
    }
    return self;
}

@end
