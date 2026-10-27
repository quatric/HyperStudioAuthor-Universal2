#import "HSOldFormatGhostWriterNBA.h"
@implementation HSOldFormatGhostWriterNBA
+ (id)ghostWriterActionCommandsForString:(id)aString card:(id)aCard
{
    // "text{command}text{command}...": text is typed, commands change speed,
    // erase, backspace or pick the field to type into
    NSMutableArray *commands = [NSMutableArray array];
    NSMutableString *string = [NSMutableString stringWithString:aString];
    [string replaceOccurrencesOfString:@"@" withString:@"{backspace}" options:NSLiteralSearch
                                 range:NSMakeRange(0, [string length])];
    NSArray *pieces = [string componentsSeparatedByString:HSOldFileFormatImportAutoTypeActionOpenBracket];
    NSUInteger count = [pieces count];
    for (NSUInteger i = 0; i < count; i++) {
        NSArray *parts = [[pieces objectAtIndex:i] componentsSeparatedByString:HSOldFileFormatImportAutoTypeActionCloseBracket];
        NSString *first = [parts objectAtIndex:0];
        NSString *text = nil;
        if ([parts count] == 1)
            text = first;
        else if ([parts count] == 2) {
            id command = [self ghostWriterCommandForString:first card:aCard];
            if (command != nil)
                [commands addObject:command];
            text = [parts objectAtIndex:1];
        }
        // the original never released these (a leak): autoreleased here
        if ([text length] != 0)
            [commands addObject:[[[HSGhostWriterTypeTextCommand alloc] initWithStringToType:text] autorelease]];
    }
    return commands;
}
+ (id)ghostWriterCommandForString:(id)aString card:(id)aCard
{
    if (aString == nil || [aString length] == 0)
        return nil;
    NSString *command = [aString lowercaseString];
    NSArray *speeds = [NSArray arrayWithObjects:HSOldFileFormatImportAutoTypeActionFastestCommand,
        HSOldFileFormatImportAutoTypeActionFasterCommand, HSOldFileFormatImportAutoTypeActionFastCommand,
        HSOldFileFormatImportAutoTypeActionDefaultCommand, HSOldFileFormatImportAutoTypeActionSlowCommand,
        HSOldFileFormatImportAutoTypeActionSlowerCommand, HSOldFileFormatImportAutoTypeActionSlowestCommand, nil];
    NSUInteger speed = [speeds indexOfObject:command];
    id result;
    if (speed != NSNotFound)
        result = [[HSGhostWriterSpeedCommand alloc] initWithSpeed:speed + 1];   // fastest 1 ... slowest 7
    else if ([command isEqualToString:HSOldFileFormatImportAutoTypeActionEraseCommand])
        result = [[HSGhostWriterStuffCommand alloc] initWithStuffType:HSGhostWriterErase];
    else if ([command isEqualToString:HSOldFileFormatImportAutoTypeActionBackspaceCommand])
        result = [[HSGhostWriterStuffCommand alloc] initWithStuffType:HSGhostWriterBackspace];
    else {
        // anything else names the text field to type into
        NSString *key = [NSString stringWithFormat:@"~itemShortName_%@_type_%@",
            [HSOldFormatDocument recreationItemNameFromString:aString], @"FIELD"];
        id field = [[aCard userInfoForKey:key] queryHyperInterface:@protocol(HSObjectAttributes)];
        result = [[HSGhostWriterTargetCommand alloc] initWithTargetObjectUID:[field hyperUID]];
    }
    return [result autorelease];
}
@end
