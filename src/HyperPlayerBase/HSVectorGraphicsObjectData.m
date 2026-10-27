#import "HSVectorGraphicsObjectData.h"

@implementation HSVectorGraphicsObjectData
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    BOOL isShape = [self vg] ? [(HSVectorGraphics *)[self vg] isHyperShape] : NO;
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraStoringWithCodingContext:aContext]];
    if (![[aContext codingOperation] isEqualToString:@"HSObjectStyleCodingOperation"]) {
        [keys addObject:@"objectKindName"];
        if (isShape)
            [keys addObject:[HSVectorGraphicsObject backgroundAttributesSerializationKey]];
    }
    [keys addObject:@"vg"];
    [keys addObject:@"opacity"];
    if (!isShape) {
        [keys addObject:@"headEnding"];
        [keys addObject:@"tailEnding"];
    }
    [keys addObject:@"backgroundGraphics"];
    return keys;
}
- (id)hyperObjectForLineEnding:(id)aEnding
{
    return [self hasOwner] ? [[self owner] anyOwningObjectForNodeData:self] : nil;
}
- (id)hyperObjectForVectorGraphics:(id)aGraphics
{
    return [self hasOwner] ? [[self owner] anyOwningObjectForNodeData:self] : nil;
}
- (id)undoManagerForGraphics:(id)aGraphics
{
    return [self hasOwner] ? [[[self owner] anyOwningObjectForNodeData:self] undoManager] : nil;
}
- (void)hyperVisualAttributesChanged:(id)aChanged
{
    if ([self hasOwner])
        [[[self owner] anyOwningObjectForNodeData:self] hyperVisualAttributesChanged:aChanged];
}
- (void)setBackgroundGraphics:(id)aGraphics
{
    [_backgroundGraphics setHyperOwner:nil];
    [aGraphics retain];
    [_backgroundGraphics release];
    _backgroundGraphics = aGraphics;
    [(HSGraphics *)aGraphics setHyperOwner:self];
}
- (id)backgroundGraphics
{
    return _backgroundGraphics;
}
- (void)setBackgroundThumbnail:(id)aThumbnail
{
    [aThumbnail retain];
    [_backgroundThumbnail release];
    _backgroundThumbnail = aThumbnail;
}
- (id)backgroundThumbnail
{
    return _backgroundThumbnail;
}
- (void)setTailEnding:(id)aEnding
{
    [_tailEnding setOwner:nil];
    [aEnding retain];
    [_tailEnding release];
    _tailEnding = aEnding;
    [(HSVectorGraphicsLineEnding *)aEnding setOwner:self];
}
- (id)tailEnding
{
    if (!_tailEnding) {
        _tailEnding = [HSVectorGraphicsLineEnding new];
        [_tailEnding setOwner:self];
    }
    return _tailEnding;
}
- (void)setHeadEnding:(id)aEnding
{
    [_headEnding setOwner:nil];
    [aEnding retain];
    [_headEnding release];
    _headEnding = aEnding;
    [(HSVectorGraphicsLineEnding *)aEnding setOwner:self];
}
- (id)headEnding
{
    if (!_headEnding) {
        _headEnding = [HSVectorGraphicsLineEnding new];
        [_headEnding setOwner:self];
    }
    return _headEnding;
}
- (void)setVg:(id)aVg
{
    [_vg setOwner:nil];
    [aVg retain];
    [_vg release];
    _vg = aVg;
    [(HSVectorGraphics *)aVg setOwner:self];
}
- (id)vg
{
    if (!_vg) {
        _vg = [HSVectorGraphics new];
        [_vg setOwner:self];
    }
    return _vg;
}
- (void)setObjectKindName:(id)aName
{
    [aName retain];
    [_objectKindName release];
    _objectKindName = aName;
}
- (id)objectKindName
{
    return _objectKindName;
}
- (void)dealloc
{
    [_backgroundGraphics setHyperOwner:nil];
    [_backgroundGraphics release];
    [_backgroundThumbnail release];
    [_tailEnding setOwner:nil];
    [_tailEnding release];
    [_headEnding setOwner:nil];
    [_headEnding release];
    [_vg setOwner:nil];
    [_vg release];
    [_objectKindName release];
    [super dealloc];
}
@end
