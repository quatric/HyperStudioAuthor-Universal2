#import "HSUserObjectNamingStrategy.h"
static HSUserObjectNamingStrategy *HSUserObjectNamingStrategyDefault = nil;
@implementation HSUserObjectNamingStrategy
+ (id)defaultNamingStrategy
{
    if (HSUserObjectNamingStrategyDefault == nil)
        HSUserObjectNamingStrategyDefault = [[self alloc] init];
    return HSUserObjectNamingStrategyDefault;
}
- (BOOL)isAcceptableObjectName:(id)aName
{
    return [self isAcceptableObjectName:aName correctName:NULL];
}
- (id)acceptableObjectName:(id)aName
{
    id correctName = nil;
    if ([self isAcceptableObjectName:aName correctName:&correctName])
        return aName;
    return correctName;
}
// Names are one line of at most 32 characters: the correct name is the
// part before the first line break, cut at 32.
- (BOOL)isAcceptableObjectName:(id)aName correctName:(id *)aName2
{
    NSMutableString *correctName = aName2 != NULL ? [NSMutableString string] : nil;
    NSUInteger length = [aName length];
    NSCharacterSet *newlines = [NSCharacterSet hyperNewlineCharacterSet];
    NSUInteger index = 0;
    BOOL brokenAtStart = NO;
    while (index < length && index < 32) {
        if ([newlines characterIsMember:[aName characterAtIndex:index]])
            break;
        index++;
    }
    BOOL lineBreak = index < length && index < 32;
    if (lineBreak && index == 0)
        brokenAtStart = YES;
    else if (index != 0)
        [correctName appendString:[aName substringWithRange:NSMakeRange(0, index)]];
    if (lineBreak)
        index = 0;
    if (aName2 != NULL)
        *aName2 = correctName;
    return !brokenAtStart && index == length;
}
- (void)dealloc
{
    if (HSUserObjectNamingStrategyDefault == self)
        HSUserObjectNamingStrategyDefault = nil;
    [super dealloc];
}
// A singleton: later instances give way to the default one.
- (id)init
{
    if (HSUserObjectNamingStrategyDefault != nil) {
        [super dealloc];
        return [HSUserObjectNamingStrategyDefault retain];
    }
    self = [super init];
    if (self != nil)
        HSUserObjectNamingStrategyDefault = self;
    return self;
}
@end
