#import "NSCharacterSet+HSExtentions.h"
@implementation NSCharacterSet (HSExtentions)
+ (id)hyperNewlineAndPunctuationCharacterSet
{
    static NSCharacterSet *set;
    if (set == nil) {
        NSMutableCharacterSet *characters = [[[self hyperNewlineCharacterSet] mutableCopy] autorelease];
        [characters addCharactersInString:@".,;!?"];
        set = [characters copy];
    }
    return set;
}
+ (id)hyperNewlineCharacterSet
{
    // whitespace and newlines without the whitespace: just the newlines
    static NSCharacterSet *set;
    if (set == nil) {
        NSMutableCharacterSet *characters = [[[NSCharacterSet whitespaceAndNewlineCharacterSet] mutableCopy] autorelease];
        [characters formIntersectionWithCharacterSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]];
        set = [characters copy];
    }
    return set;
}
@end
