#import "HSHeadlineObjectData.h"
// Node data of a headline: text object data plus a background (graphics
// and its thumbnail) and an optional text outline.

@implementation HSHeadlineObjectData

+ (id)nodeDataKeysToNodeKeysMap
{
    id map = [super nodeDataKeysToNodeKeysMap];
    [map setObject:@"outlineColor" forKey:[@"outlineColor" extraKeyForMultiRepresentations]];
    return map;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraStoringWithCodingContext:aContext]];
    [keys addObject:[HSHeadlineObject backgroundAttributesSerializationKey]];
    [keys addObject:@"outlineEnabled"];
    [keys addObject:@"outlineWidth"];
    [keys addObject:[@"outlineColor" extraKeyForMultiRepresentations]];
    return keys;
}

- (id)undoManagerForGraphics:(id)aGraphics
{
    if (![self hasOwner])
        return nil;
    return [[[self owner] anyOwningObjectForNodeData:self] undoManager];
}

- (void)hyperVisualAttributesChanged:(id)aChanged
{
    if ([self hasOwner])
        [[[self owner] anyOwningObjectForNodeData:self] hyperVisualAttributesChanged:aChanged];
}

- (void)setOutlineEnabled:(BOOL)aEnabled
{
    _outlineEnabled = aEnabled;
}

- (BOOL)isOutlineEnabled
{
    return _outlineEnabled;
}

- (void)setOutlineWidth:(CGFloat)aWidth
{
    _outlineWidth = aWidth;
}

- (CGFloat)outlineWidth
{
    return _outlineWidth;
}

- (void)setOutlineColor:(id)aColor
{
    [aColor retain];
    [_outlineColor release];
    _outlineColor = aColor;
}

- (id)outlineColor
{
    return _outlineColor;
}

- (void)setBackgroundGraphics:(id)aGraphics
{
    [_backgroundGraphics setHyperOwner:nil];
    [aGraphics retain];
    [_backgroundGraphics release];
    _backgroundGraphics = aGraphics;
    [aGraphics setHyperOwner:self];
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

- (void)dealloc
{
    [_outlineColor release];
    [_backgroundGraphics setHyperOwner:nil];
    [_backgroundGraphics release];
    [_backgroundThumbnail release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        _outlineWidth = 0;
        _outlineEnabled = NO;
    }
    return self;
}

@end
