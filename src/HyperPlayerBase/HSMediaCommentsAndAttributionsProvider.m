#import "HSMediaCommentsAndAttributionsProvider.h"
@implementation HSMediaCommentsAndAttributionsProvider
+ (id)commentsAndAttributionsForMediaUID:(id)aUID
{
    static NSDictionary *commentsAndAttributions;
    if (commentsAndAttributions == nil)
        commentsAndAttributions = [[HSPlayerBaseID extraDictionaryNamed:@"MediaCommentsAndAttributions.plist"] retain];
    return [commentsAndAttributions objectForKey:[aUID stringValue]];
}
@end
