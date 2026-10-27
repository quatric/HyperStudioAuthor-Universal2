#import "HSTestingFunctionsManager.h"
// Records quiz answers per card (the last answer on each card counts) and
// appends them to "HS.Test.Results.txt" next to the stack (or next to the
// application, for stacks inside it).
@implementation HSTestingFunctionsManager
- (id)implementationForHyperObject:(id)aObject
{
    if (_stack == aObject)
        return self;
    return [[[[self class] alloc] initWithStack:aObject] autorelease];
}
- (id)hyperObject
{
    return _stack;
}
- (BOOL)implementsHyperInterface:(id)aInterface
{
    return protocol_conformsToProtocol(aInterface, @protocol(HSTestingFunctions));
}
- (id)queryHyperInterface:(id)aInterface
{
    return [_stack queryHyperInterface:aInterface];
}
- (void)resetTestingInformation
{
    [_cardUIDsToAnswersMap release];
    _cardUIDsToAnswersMap = nil;
    [_userName release];
    _userName = nil;
}
- (void)storeTestingInformation
{
    if ([self numberOfAnswers] == 0)
        return;
    NSString *stackPath = [[_stack support] auxillaryPath];
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *folderOf = [stackPath hasPrefix:bundlePath] ? bundlePath : stackPath;
    NSString *path = [[folderOf stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"HS.Test.Results.txt"];
    if (path != nil) {
        NSMutableString *results = [[NSMutableString alloc] initWithContentsOfFile:path usedEncoding:NULL error:NULL];
        if (results == nil)
            results = [NSMutableString new];
        [results appendString:[self stringForStoring]];
        NSError *error = nil;
        if (![[results dataUsingEncoding:NSUnicodeStringEncoding] writeToFile:path options:NSDataWritingAtomic error:&error]) {
            NSAlert *alert = [[NSAlert new] autorelease];
            // (Style 5 as in the original; not one of NSAlertStyle's values.)
            [alert setAlertStyle:(NSAlertStyle)5];
            HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
            NSString *informativeKey;
            if ([error code] == NSFileWriteOutOfSpaceError) {
                [alert setMessageText:[provider localizedStringForKey:@"Not enough disk space to save testing results" value:@"" table:@"Alerts"]];
                informativeKey = @"Free some disk space.";
            } else {
                NSString *format = [provider localizedStringForKey:@"CantSaveTestResultsPermissionsMessage" value:@"" table:@"Alerts"];
                [alert setMessageText:[NSString stringWithFormat:format, [path lastPathComponent]]];
                informativeKey = @"CantSaveTestResultsPermissionsInfoText";
            }
            [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:informativeKey value:@"" table:@"Alerts"]];
            [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"OK" value:@"" table:@"Alerts"]];
            [alert runModal];
        }
        [results release];
    }
    [self resetTestingInformation];
}
// One tab-separated line per answered card, in card order: stack, user,
// date, time, card, answering object, correct (1/0), number of answers.
- (id)stringForStoring
{
    NSMutableString *string = [NSMutableString string];
    if ([self numberOfAnswers] == 0)
        return string;
    NSURL *URL = [[_stack document] fileURL];
    NSString *stackName = URL != nil ? [[[URL path] lastPathComponent] stringByDeletingPathExtension] : [_stack name];
    NSString *prefix = [NSString stringWithFormat:@"%@\t%@\t", stackName, [self userName]];
    NSUInteger answers = [self numberOfAnswers];
    NSDictionary *map = [self cardUIDsToAnswersMap];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [timeFormatter setDateStyle:NSDateFormatterNoStyle];
    [timeFormatter setTimeStyle:NSDateFormatterFullStyle];
    for (id card in [_stack hyperChildren]) {
        id cardUID = [card hyperUID];
        NSDictionary *answer = [map objectForKey:cardUID];
        if (answer == nil)
            continue;
        [string appendString:prefix];
        NSDate *date = [answer objectForKey:@"HSTestingFunctionsAnswerDateKey"];
        NSString *objectName = [[[_stack childInTreeWithUID:[answer objectForKey:@"HSTestingFunctionsObjectUIDKey"]] queryHyperInterface:@protocol(HSObjectAttributes)] hyperName];
        NSString *cardName = [[_stack childWithUID:cardUID] hyperName];
        BOOL correct = [[answer objectForKey:@"HSTestingFunctionsAnswerKey"] boolValue];
        [string appendString:[NSString stringWithFormat:@"%@\t%@\t%@\t%@\t%d\t%u\n", [dateFormatter stringFromDate:date], [timeFormatter stringFromDate:date], cardName, objectName, (int)correct, (unsigned)answers]];
    }
    [dateFormatter release];
    [timeFormatter release];
    return string;
}
- (NSUInteger)numberOfAnswers
{
    return [[self cardUIDsToAnswersMap] count];
}
- (NSUInteger)numberOfCorrectAnswers
{
    NSUInteger correct = 0;
    for (NSDictionary *answer in [[self cardUIDsToAnswersMap] objectEnumerator])
        correct += [[answer objectForKey:@"HSTestingFunctionsAnswerKey"] boolValue] != NO;
    return correct;
}
- (void)setUserName:(id)aName
{
    if ([_userName isEqual:aName])
        return;
    [_userName release];
    _userName = [aName retain];
}
- (id)userName
{
    return _userName != nil ? _userName : [NSString string];
}
- (void)recordIncorrectAnswerForObjectWithUID:(id)aUID cardUID:(id)aUID2
{
    NSDictionary *answer = [NSDictionary dictionaryWithObjectsAndKeys:aUID, @"HSTestingFunctionsObjectUIDKey", [NSNumber numberWithBool:NO], @"HSTestingFunctionsAnswerKey", [NSDate date], @"HSTestingFunctionsAnswerDateKey", nil];
    [[self cardUIDsToAnswersMap] setObject:answer forKey:aUID2];
}
- (void)recordCorrectAnswerForObjectWithUID:(id)aUID cardUID:(id)aUID2
{
    NSDictionary *answer = [NSDictionary dictionaryWithObjectsAndKeys:aUID, @"HSTestingFunctionsObjectUIDKey", [NSNumber numberWithBool:YES], @"HSTestingFunctionsAnswerKey", [NSDate date], @"HSTestingFunctionsAnswerDateKey", nil];
    [[self cardUIDsToAnswersMap] setObject:answer forKey:aUID2];
}
- (id)cardUIDsToAnswersMap
{
    if (_cardUIDsToAnswersMap == nil)
        _cardUIDsToAnswersMap = [NSMutableDictionary new];
    return _cardUIDsToAnswersMap;
}
// (The original didn't release the user name.)
- (void)dealloc
{
    [_cardUIDsToAnswersMap release];
    [_userName release];
    [super dealloc];
}
// The stack isn't retained: the manager is one of its implementations.
- (id)initWithStack:(id)aStack
{
    self = [super init];
    if (self != nil)
        _stack = aStack;
    return self;
}
@end
