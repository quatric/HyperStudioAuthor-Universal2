#import "HSUniqueDisplayNamingStrategy.h"
@implementation HSUniqueDisplayNamingStrategy
static HSUniqueDisplayNamingStrategy *sDefaultNamingStrategy;
+ (id)defaultNamingStrategy
{
    if (sDefaultNamingStrategy == nil)
        sDefaultNamingStrategy = [[self alloc] init];
    return sDefaultNamingStrategy;
}
- (id)uniqueName:(id)aName step:(NSUInteger)aStep uniqueSeparator:(id)aSeparator
{
    // "Name" -> "Name<sep>2"; "Name<sep>2" -> "Name<sep>3" (assumes a
    // one-character separator when stripping the old number).
    NSArray *components = [aName componentsSeparatedByString:aSeparator];
    NSString *last = [components lastObject];
    NSString *base = aName;
    int number;
    if ([components count] > 1) {
        number = [last intValue];
        if (number > 1)
            base = [aName substringToIndex:[aName length] - 1 - [last length]];
    } else
        number = 1;
    return [base stringByAppendingFormat:@"%@%i", aSeparator, (int)(number + aStep)];
}
- (void)dealloc
{
    if (sDefaultNamingStrategy == self)
        sDefaultNamingStrategy = nil;
    [super dealloc];
}
- (id)init
{
    // A singleton: later inits dispose of the new instance and return the shared one.
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
