#import "HSImportProblems.h"
// Problems met while importing an old stack, by error code: the total, the
// counts by point (where) and by info (what).
@implementation HSImportProblems
// Continue / Cancel / Submit Request; Continue when there is nothing to show.
- (NSInteger)runUserConfirmationAlert
{
    NSArray *descriptions = [self problemsDescriptions];
    if ([descriptions count] == 0 || ![self needToShowAlert])
        return NSAlertFirstButtonReturn;
    HSError *error = [HSError errorWithHSCode:20000];
    HSErrorsAlert *alert = [[HSErrorsAlert new] autorelease];
    [alert setScriptErrors:descriptions];
    [alert setMessageText:[error localizedDescription]];
    [alert setInformativeText:[error localizedRecoverySuggestion]];
    HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
    [alert addButtonWithTitle:[provider localizedStringForKey:@"Continue" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cancel" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Submit Request" value:@"" table:@"Alerts"]];
    [alert setAlertStyle:5];
    return [alert runModal];
}
- (BOOL)needToShowAlert
{
    return YES;
}
// The report: a summary of every problem, then each one's counts by point
// and by info. The info lists are filled in round by round (the n-th info
// of every problem per round, at its "[#k#]" placeholder) while the text
// stays within 20000 characters; a round that overflows is undone and the
// placeholders removed.
- (id)reportTextWithFilename:(id)aFilename
{
    HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
    NSMutableString *report = [NSMutableString stringWithString:[provider localizedStringForKey:@"Importing Problems Header" value:@"" table:@"Alerts"]];
    [report appendFormat:@"%@\n", aFilename];
    NSArray *codes = [[self problems] allKeys];
    NSUInteger count = [codes count];
    for (NSUInteger i = 0; i < count; i++) {
        id code = [codes objectAtIndex:i];
        id total = [[[self problems] objectForKey:code] objectForKey:@"totalNumber"];
        [report appendString:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Importing Problems Item Header" value:@"" table:@"Alerts"]];
        [report appendFormat:@"%d. (%@)\n", (int)(i + 1), total];
        [report appendFormat:@"%@\n", [[HSError errorWithHSCode:[code intValue]] localizedRecoverySuggestion]];
    }
    [report appendString:@"\n"];
    for (NSUInteger i = 0; i < count; i++) {
        NSDictionary *problem = [[self problems] objectForKey:[codes objectAtIndex:i]];
        [report appendFormat:@"%d. (%@)\n", (int)(i + 1), [problem objectForKey:@"totalNumber"]];
        NSDictionary *byPoints = [problem objectForKey:@"byPoints"];
        NSArray *points = [byPoints allKeys];
        int pointCount = (int)[points count];
        for (int k = 0; k < pointCount; k++) {
            id point = [points objectAtIndex:k];
            [report appendFormat:k < pointCount - 1 ? @"%@:%@, " : @"%@:%@\n", point, [byPoints objectForKey:point]];
        }
        [report appendFormat:@"[#%d#]", (int)(i + 1)];
    }
    int rounds = 0;
    for (NSUInteger i = 0; i < count; i++) {
        int infoCount = (int)[[[[[self problems] objectForKey:[codes objectAtIndex:i]] objectForKey:@"byInfo"] allKeys] count];
        rounds = MAX(rounds, infoCount);
    }
    for (int round = 0; round <= rounds; round++) {
        NSMutableString *before = [[report mutableCopy] autorelease];
        for (NSUInteger i = 0; i < count; i++) {
            NSDictionary *byInfo = [[[self problems] objectForKey:[codes objectAtIndex:i]] objectForKey:@"byInfo"];
            NSArray *infos = [byInfo allKeys];
            int infoCount = (int)[infos count];
            NSString *placeholder = [NSString stringWithFormat:@"[#%d#]", (int)(i + 1)];
            NSString *replacement;
            if (round < infoCount && [report length] <= 20000) {
                id info = [infos objectAtIndex:round];
                id number = [byInfo objectForKey:info];
                replacement = round < infoCount - 1
                    ? [NSString stringWithFormat:@"%@:%@, %@", info, number, placeholder]
                    : [NSString stringWithFormat:@"%@:%@\n", info, number];
            } else {
                if ([report length] > 20000)
                    report = before;
                replacement = @"";
            }
            [report replaceOccurrencesOfString:placeholder withString:replacement options:NSCaseInsensitiveSearch
                                         range:NSMakeRange(0, [report length])];
        }
    }
    return report;
}
- (id)problemsDescriptions
{
    NSMutableArray *descriptions = [NSMutableArray array];
    NSArray *codes = [[self problems] allKeys];
    NSUInteger count = [codes count];
    for (NSUInteger i = 0; i < count; i++) {
        NSString *suggestion = [[HSError errorWithHSCode:[[codes objectAtIndex:i] intValue]] localizedRecoverySuggestion];
        if (suggestion != nil)
            [descriptions addObject:[NSString stringWithFormat:@"%@\n", suggestion]];
    }
    return descriptions;
}
- (void)addImportingProblemForCode:(NSInteger)aCode point:(id)aPoint info:(id)aInfo
{
    NSNumber *code = [NSNumber numberWithInt:(int)aCode];
    NSMutableDictionary *problem = [[self problems] objectForKey:code];
    if (problem == nil) {
        problem = [NSMutableDictionary dictionary];
        NSMutableDictionary *byPoints = [NSMutableDictionary dictionary];
        [byPoints setObject:[NSNumber numberWithInt:0] forKey:aPoint];
        [problem setObject:byPoints forKey:@"byPoints"];
        [[self problems] setObject:problem forKey:code];
        [problem setObject:[NSMutableDictionary dictionary] forKey:@"byInfo"];
    }
    id total = [problem objectForKey:@"totalNumber"];
    [problem setObject:[NSNumber numberWithInt:total != nil ? [total intValue] + 1 : 1] forKey:@"totalNumber"];
    NSMutableDictionary *byPoints = [problem objectForKey:@"byPoints"];
    [byPoints setObject:[NSNumber numberWithInt:[[byPoints objectForKey:aPoint] intValue] + 1] forKey:aPoint];
    if (aInfo != nil) {
        NSMutableDictionary *byInfo = [problem objectForKey:@"byInfo"];
        id number = [byInfo objectForKey:aInfo];
        [byInfo setObject:[NSNumber numberWithInt:number != nil ? [number intValue] + 1 : 1] forKey:aInfo];
    }
}
- (id)problems
{
    if (_problems == nil)
        _problems = [NSMutableDictionary new];
    return _problems;
}
- (void)dealloc
{
    [_problems release];
    [super dealloc];
}
@end
