#import "HSGhostWriterTypeTextCommand.h"
// Ghost writer command that types a string. It may be created from
// attributed text, whose plain string is taken on first use; only the
// string is archived.

@implementation HSGhostWriterTypeTextCommand

- (id)stringRepresentation
{
    return [self stringToType];
}

- (id)descriprtion
{
    return [NSString stringWithFormat:@"%@: %@", self, _stringToType];
}

- (BOOL)shouldRunWithoutDelayAfterCommand:(id)aCommand
{
    return ![[[aCommand queryHyperInterface:@protocol(HSGhostWriterStuffCommandInterface)] stuffType] isEqualToString:HSGhostWriterBackspace];
}

// (The original does not call [super init] here.)
- (id)initWithCoder:(id)aCoder
{
    _stringToType = [[aCoder decodeObjectForKey:@"stringToType"] retain];
    return self;
}

- (void)encodeWithCoder:(id)aCoder
{
    [aCoder encodeObject:[self stringToType] forKey:@"stringToType"];
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObjects:@"textToType", @"stringToType", nil];
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObject:@"stringToType"];
}

- (void)executeWithActionPerformer:(id)aPerformer
{
    [aPerformer setTextToType:[self stringToType]];
}

- (id)copyWithZone:(NSZone *)aZone
{
    id string = [[self stringToType] copy];
    id copy = [[[self class] alloc] initWithStringToType:string];
    [string release];
    return copy;
}

- (BOOL)isEqual:(id)aEqual
{
    if (![aEqual isKindOfClass:[self class]])
        return NO;
    return [[self stringToType] isEqualToString:[aEqual stringToType]];
}

- (void)setStringToType:(id)aType
{
    if (![aType isEqualToString:_stringToType]) {
        [_stringToType release];
        _stringToType = [aType retain];
    }
}

- (void)setTextToType:(id)aType
{
    if (![_textToType isEqualToAttributedString:aType]) {
        [_textToType release];
        _textToType = [aType retain];
    }
}

- (id)stringToType
{
    if (!_stringToType && _textToType)
        _stringToType = [[_textToType string] retain];
    return _stringToType;
}

- (id)initWithStringToType:(id)aType
{
    self = [super init];
    if (self)
        [self setStringToType:aType];
    return self;
}

- (void)dealloc
{
    [_textToType release];
    [_stringToType release];
    [super dealloc];
}

@end
