#import "KeynoteStroke.h"

@implementation KeynoteStroke

- (void)setPatternType:(id)aType
{
    if (_patternType != aType) {
        [_patternType release];
        _patternType = [aType retain];
    }
}

- (id)patternType
{
    [self calculate];
    return _patternType;
}

- (void)setPatternPhase:(CGFloat)aPhase
{
    _patternPhase = aPhase;
}

- (CGFloat)patternPhase
{
    [self calculate];
    return _patternPhase;
}

- (void)setPatterns:(id)aPatterns
{
    if (_patterns != aPatterns) {
        [_patterns release];
        _patterns = [aPatterns retain];
    }
}

- (id)patterns
{
    [self calculate];
    return _patterns;
}

- (void)setColor:(id)aColor
{
    if (_color != aColor) {
        [_color release];
        _color = [aColor retain];
    }
}

- (id)color
{
    [self calculate];
    return _color;
}

- (void)setWidth:(CGFloat)aWidth
{
    [self calculate];
    _width = aWidth;
}

- (CGFloat)width
{
    [self calculate];
    return _width;
}

// Reads the stroke lazily from whichever stroke element is present, or from the referenced one.
- (void)calculate
{
    if (_isCalculated)
        return;
    id stroke = [self keynoteObjectForXMLPath:@"./stroke"];
    if (stroke == nil)
        stroke = [self keynoteObjectForXMLPath:@"./manipulated-stroke"];
    if (stroke == nil)
        stroke = [self keynoteObjectForXMLPath:@"./calligraphy-stroke"];
    if (stroke == nil) {
        id strokeId = [[[self keynoteObjectForXMLPath:@"./stroke-ref"] nodeAttributes] objectForKey:@"IDREF"];
        stroke = [[self cache] objectOfType:@"stroke" inCacheForId:strokeId];
    }
    if (stroke != nil) {
        _width = [[[stroke nodeAttributes] objectForKey:@"width"] floatValue];
        [self setColor:[(KeynoteStroke *)[stroke keynoteObjectForXMLPath:@"./color"] color]];
        id pattern = [stroke keynoteObjectForXMLPath:@"./pattern"];
        _patternPhase = [[[pattern nodeAttributes] objectForKey:@"phase"] floatValue];
        [self setPatternType:[[pattern nodeAttributes] objectForKey:@"type"]];
        NSArray *values = [[stroke keynoteObjectForXMLPath:@"./pattern/pattern"] children];
        NSMutableArray *patterns = [NSMutableArray array];
        int count = (int)[values count];
        for (int i = 0; i < count; i++)
            [patterns addObject:[NSNumber numberWithFloat:[[[[values objectAtIndex:i] nodeAttributes] objectForKey:@"val"] floatValue]]];
        [self setPatterns:patterns];
    }
    _isCalculated = YES;
}

- (void)didInitFromParser
{
    [super didInitFromParser];
    [[self cache] addObject:self type:@"stroke" inCacheForId:[self nodeId]];
}

- (void)dealloc
{
    [_color release];
    [_patterns release];
    [_patternType release];
    [super dealloc];
}

@end
