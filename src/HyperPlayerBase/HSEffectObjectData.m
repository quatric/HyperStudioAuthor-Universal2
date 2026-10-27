#import "HSEffectObjectData.h"
// Stored data of an effect card object: the effect's name and attributes.
@implementation HSEffectObjectData
+ (id)nodeDataKeysToNodeKeysMap
{
    id map = [super nodeDataKeysToNodeKeysMap];
    [map setObject:@"attributes" forKey:[@"attributes" extraKeyForCollection]];
    return map;
}
// Styles don't carry the effect's name.
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraStoringWithCodingContext:aContext]];
    if (![[aContext codingOperation] isEqualToString:@"HSObjectStyleCodingOperation"])
        [keys addObject:@"effectName"];
    [keys addObject:[@"attributes" extraKeyForCollection]];
    return keys;
}
- (void)setEffect:(id)aEffect
{
    [aEffect retain];
    [_effect release];
    _effect = aEffect;
}
- (id)effect
{
    return _effect;
}
- (void)setAttributes:(id)aAttributes
{
    [aAttributes retain];
    [_attributes release];
    _attributes = aAttributes;
}
- (id)attributes
{
    return _attributes;
}
- (void)setEffectName:(id)aName
{
    [aName retain];
    [_effectName release];
    _effectName = aName;
}
- (id)effectName
{
    return _effectName;
}
- (void)dealloc
{
    [_effect release];
    [_attributes release];
    [_effectName release];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self != nil)
        _attributes = [NSMutableDictionary new];
    return self;
}
@end
