#import "HSUserScript.h"

@implementation HSUserScript
+ (id)userScriptWithSource:(id)aSource
{
    HSUserScript *script = [[HSUserScript alloc] init];
    [script setJavaScriptSource:aSource];
    return [script autorelease];
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObjects:@"javaScriptSource", [@"usedUIDsArray" extraKeyForCollection], @"usesValidUIDs", @"isValid", @"hasPotentialErrors", nil];
}
- (id)copyWithZone:(NSZone *)aZone
{
    HSUserScript *copy = [[[self class] allocWithZone:aZone] init];
    [copy setJavaScriptSource:_javaScriptSource];
    [copy setUsedUIDs:_usedUIDs];
    [copy setUsesValidUIDs:[self usesValidUIDs]];
    [copy setValid:[self isValid]];
    [copy setHasPotentialErrors:[self hasPotentialErrors]];
    return copy;
}
// Only the source is compared.
- (BOOL)isEqual:(id)aEqual
{
    if (!aEqual)
        return NO;
    if (self == aEqual)
        return YES;
    if ([self class] != [aEqual class])
        return NO;
    if ([aEqual javaScriptSource] == [self javaScriptSource])
        return YES;
    return [[aEqual javaScriptSource] isEqualToString:[self javaScriptSource]];
}
- (void)setUsesValidUIDs:(BOOL)aDs
{
    _usesValidUIDs = aDs;
}
- (BOOL)usesValidUIDs
{
    return _usesValidUIDs;
}
- (void)setHasPotentialErrors:(BOOL)aErrors
{
    _hasPotentialErrors = aErrors;
}
- (BOOL)hasPotentialErrors
{
    return _hasPotentialErrors;
}
- (void)setValid:(BOOL)aValid
{
    _isValid = aValid;
}
- (BOOL)isValid
{
    return _isValid;
}
- (void)setUsedUIDsArray:(id)aArray
{
    [self setUsedUIDs:[NSSet setWithArray:aArray]];
}
- (id)usedUIDsArray
{
    return [[self usedUIDs] allObjects];
}
- (void)setUsedUIDs:(id)aDs
{
    if (_usedUIDs != aDs) {
        [_usedUIDs release];
        _usedUIDs = [aDs copy];
    }
}
- (id)usedUIDs
{
    return _usedUIDs ? _usedUIDs : [NSSet set];
}
- (void)setJavaScriptSource:(id)aSource
{
    if (_javaScriptSource != aSource) {
        [_javaScriptSource release];
        _javaScriptSource = [aSource copy];
    }
}
- (id)javaScriptSource
{
    return _javaScriptSource ? _javaScriptSource : @"";
}
- (void)dealloc
{
    [_usedUIDs release];
    [_javaScriptSource release];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self) {
        _usesValidUIDs = YES;
        _isValid = YES;
    }
    return self;
}
@end
