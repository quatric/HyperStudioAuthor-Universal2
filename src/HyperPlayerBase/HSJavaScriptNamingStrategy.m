#import "HSJavaScriptNamingStrategy.h"
// JavaScript identifiers for stack objects: "$" + the object's name;
// "mechanic" (generated) names use the lexer's prefix, "$" without it.
static NSRange HSJavaScriptCharacterRange(unichar aFirst, unichar aLast)
{
    if (aFirst > aLast)
        return HSJavaScriptCharacterRange(aLast, aFirst);
    return NSMakeRange(aFirst, aLast - aFirst + 1);
}

@implementation HSJavaScriptNamingStrategy
+ (id)defaultNamingStrategy
{
    static HSJavaScriptNamingStrategy *strategy = nil;
    if (strategy == nil)
        strategy = [HSJavaScriptNamingStrategy new];
    return strategy;
}
+ (BOOL)isMechanicIdentifier:(id)aIdentifier
{
    Class lexer = [self lexerClass];
    if (lexer != Nil)
        return [lexer isMechanicIdentifier:aIdentifier];
    return [aIdentifier rangeOfString:[[self class] mechanicPrefix] options:NSAnchoredSearch].location == 0;
}
+ (id)mechanicPrefix
{
    Class lexer = [self lexerClass];
    return lexer != Nil ? [lexer mechanicPrefix] : @"$";
}
// The lexer lives in the editor, if loaded.
+ (Class)lexerClass
{
    static Class lexer = Nil;
    if (lexer == Nil)
        lexer = NSClassFromString(@"HSJavaScriptLexer");
    return lexer;
}
- (id)lettersCharacterSet
{
    NSMutableCharacterSet *set = [[[NSMutableCharacterSet alloc] init] autorelease];
    [set addCharactersInRange:HSJavaScriptCharacterRange('a', 'z')];
    [set addCharactersInRange:HSJavaScriptCharacterRange('A', 'Z')];
    return [[set copy] autorelease];
}
- (id)nonZeroDigitsCharacterSet
{
    return [NSCharacterSet characterSetWithRange:HSJavaScriptCharacterRange('1', '9')];
}
- (id)digitsCharacterSet
{
    NSMutableCharacterSet *set = [[[NSCharacterSet characterSetWithRange:HSJavaScriptCharacterRange('0', '0')] mutableCopy] autorelease];
    [set formUnionWithCharacterSet:[self nonZeroDigitsCharacterSet]];
    return [[set copy] autorelease];
}
- (unsigned short)validFirstCharacterForMechanicIdentifier
{
    return '_';
}
- (id)validBeginningCharactersForMechanicIdentifiers
{
    if (_validBeginningCharactersForMechanicIdentifiers == nil) {
        NSMutableCharacterSet *set = [[[self validCharactersForIdentifiers] mutableCopy] autorelease];
        [set removeCharactersInRange:HSJavaScriptCharacterRange('$', '$')];
        [set formIntersectionWithCharacterSet:[[self digitsCharacterSet] invertedSet]];
        _validBeginningCharactersForMechanicIdentifiers = [set copy];
    }
    return _validBeginningCharactersForMechanicIdentifiers;
}
- (id)validBeginningCharactersForIdentifiers
{
    if (_validBeginningCharactersForIdentifiers == nil) {
        NSMutableCharacterSet *set = [[[NSMutableCharacterSet alloc] init] autorelease];
        [set addCharactersInRange:HSJavaScriptCharacterRange('_', '_')];
        [set addCharactersInRange:HSJavaScriptCharacterRange('$', '$')];
        [set formUnionWithCharacterSet:[self lettersCharacterSet]];
        _validBeginningCharactersForIdentifiers = [set copy];
    }
    return _validBeginningCharactersForIdentifiers;
}
- (id)validCharactersForIdentifiers
{
    if (_validCharactersForIdentifiers == nil) {
        NSMutableCharacterSet *set = [[[NSMutableCharacterSet alloc] init] autorelease];
        [set addCharactersInRange:HSJavaScriptCharacterRange('_', '_')];
        [set addCharactersInRange:HSJavaScriptCharacterRange('$', '$')];
        [set formUnionWithCharacterSet:[self digitsCharacterSet]];
        [set formUnionWithCharacterSet:[self lettersCharacterSet]];
        _validCharactersForIdentifiers = [set copy];
    }
    return _validCharactersForIdentifiers;
}
// A UID-based name: prefix, then the UID's five groups joined by "_".
- (id)regularExpressionPatternForUIDName
{
    return [NSString stringWithFormat:@"[%@]_[A-Z0-9]{8}_[A-Z0-9]{4}_[A-Z0-9]{4}_[A-Z0-9]{4}_[A-Z0-9]{12}.*", [[self class] mechanicPrefix]];
}
- (id)objectNameForMechanicName:(id)aName
{
    NSString *prefix = [[self class] mechanicPrefix];
    if ([[self class] isMechanicIdentifier:aName])
        return [aName substringFromIndex:[prefix length]];
    return aName;
}
- (id)mechanicNameForObjectName:(id)aName
{
    if ([aName length] == 0)
        return aName;
    return [[self prefix] stringByAppendingString:aName];
}
- (id)prefix
{
    return @"$";
}
- (void)dealloc
{
    [_validCharactersForIdentifiers release];
    [_validBeginningCharactersForIdentifiers release];
    [_validBeginningCharactersForMechanicIdentifiers release];
    [super dealloc];
}
- (BOOL)isMechanicIdentifier:(id)aIdentifier
{
    return [[self class] isMechanicIdentifier:aIdentifier];
}
@end
