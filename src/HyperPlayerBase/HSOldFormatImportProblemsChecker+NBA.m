#import "HSOldFormatImportProblemsChecker+NBA.h"
@implementation HSOldFormatImportProblemsChecker (NBA)
- (void)processKeyMapperNBAWithData:(id)aData
{
    // one "key\target" mapping per line; a key used twice is problem 20014
    NSArray *lines = [[NSString hyperStringWithASCIIData:aData] componentsSeparatedByString:@"\r"];
    NSMutableSet *keys = [NSMutableSet set];
    NSInteger count = [lines count];
    for (NSInteger i = 0; i < count; i++) {
        NSString *line = [lines objectAtIndex:i];
        if ([line isEqualToString:@""])
            continue;
        NSArray *parts = [line componentsSeparatedByString:@"\\"];
        if ([parts count] != 2)
            continue;
        NSString *key = [parts objectAtIndex:1];
        if ([keys containsObject:key]) {
            [self addImportingProblemForCode:0x4e2e point:@"001" info:nil];
            return;
        }
        [keys addObject:key];
    }
}
@end
