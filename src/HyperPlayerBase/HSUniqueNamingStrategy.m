#import "HSUniqueNamingStrategy.h"
@implementation HSUniqueNamingStrategy
static HSUniqueNamingStrategy *sDefaultNamingStrategy;
+ (id)defaultNamingStrategy
{
    if (sDefaultNamingStrategy == nil)
        sDefaultNamingStrategy = [[self alloc] init];
    return sDefaultNamingStrategy;
}
// "Name" -> "Name2", "Name 1" -> "Name 1<sep>2": the separator only goes in
// when the name ends with a digit.
- (id)uniqueName:(id)aName step:(NSUInteger)aStep uniqueSeparator:(id)aSeparator
{
    NSUInteger length = [aName length];
    NSString *separator = @"";
    if (length != 0 && [[self digitCharacterSet] characterIsMember:[aName characterAtIndex:length - 1]])
        separator = aSeparator;
    return [aName stringByAppendingFormat:@"%@%u", separator, (unsigned)(aStep + 1)];
}
- (id)digitCharacterSet
{
    if (_digitCharacterSet == nil)
        _digitCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] retain];
    return _digitCharacterSet;
}
- (void)dealloc
{
    if (sDefaultNamingStrategy == self)
        sDefaultNamingStrategy = nil;
    [_digitCharacterSet release];
    [super dealloc];
}
// A singleton: later inits dispose of the new instance and return the shared one.
- (id)init
{
    if (sDefaultNamingStrategy == nil) {
        self = [super init];
        if (self != nil)
            sDefaultNamingStrategy = self;
        return self;
    }
    [super dealloc];
    return [sDefaultNamingStrategy retain];
}
@end
