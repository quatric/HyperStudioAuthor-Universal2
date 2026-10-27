#import "HSOldFormatDocument+HSOldFormatDocumentNBARecreation.h"

// Old New Button Actions (NBAs) become actions. Each takes the NBA's data
// and the button, and returns the action; NBAs that act on other objects
// leave the action and the object names on the button, keyed by the current
// action type, for later.
@implementation HSOldFormatDocument (HSOldFormatDocumentNBARecreation)

// The names of a comma-separated list, without returns, newlines, commas or
// spaces at either end; empty names are dropped and a list ending in commas
// ends there.
- (NSMutableArray *)HSOldFormatDocumentNBARecreation_namesFromList:(NSString *)aList
{
    NSMutableArray *names = [NSMutableArray array];
    NSCharacterSet *commas = [NSCharacterSet characterSetWithCharactersInString:@","];
    NSCharacterSet *separators = [NSCharacterSet characterSetWithCharactersInString:@"\r\n, "];
    NSString *rest = aList;
    while ([rest length]) {
        NSRange comma = [rest hyperRangeOfCharacterFromSet:commas];
        if (comma.location == 0) {
            NSUInteger start = NSMaxRange(comma);
            if (start == [rest length])
                break;
            comma = [rest hyperRangeOfCharacterFromSet:commas options:0 range:NSMakeRange(start, [rest length] - start)];
        }
        NSMutableString *name;
        if (comma.location == NSNotFound) {
            name = [[rest mutableCopy] autorelease];
            rest = nil;
        } else {
            if (comma.location == 0 && NSMaxRange(comma) == [rest length])
                break;
            name = [[[rest substringToIndex:comma.location] mutableCopy] autorelease];
            rest = [rest substringFromIndex:NSMaxRange(comma)];
        }
        if (![name length])
            continue;
        NSRange space = [name hyperRangeOfCharacterFromSet:separators];
        if (space.location != NSNotFound) {
            if (space.location == 0) {
                if (NSMaxRange(space) == [name length])
                    continue;
                [name deleteCharactersInRange:space];
            }
            space = [name hyperRangeOfCharacterFromSet:separators options:NSBackwardsSearch];
            if (space.location != NSNotFound) {
                if (space.location == 0 && NSMaxRange(space) == [name length])
                    continue;
                if (NSMaxRange(space) == [name length])
                    [name deleteCharactersInRange:space];
            }
        }
        [names addObject:name];
    }
    return names;
}

// "<sound>;<buttons>": "buttonName" speaks each button's name, "None" or
// nothing is silent, any other name is a sound to play. The buttons go on
// the button for later. NO when there is no button list.
- (BOOL)HSOldFormatDocumentNBARecreation_setSoundAndButtonsFrom:(NSString *)aString action:(id)aAction button:(id)aButton actionKey:(NSString *)aActionKey soundKey:(NSString *)aSoundKey namesKey:(NSString *)aNamesKey
{
    NSUInteger semicolon = [aString rangeOfString:@";"].location;
    if (semicolon == 0 || semicolon == NSNotFound)
        return NO;
    NSString *sound = [aString substringToIndex:semicolon];
    if ([sound isEqualToString:@"buttonName"]) {
        [aAction setAudioCueType:1];
    } else if ([sound length] && ![sound isEqualToString:@"None"]) {
        [aAction setAudioCueType:2];
        [self setUserInfoWithActionTypeForObject:aButton info:aAction key:aActionKey];
        [self setUserInfoWithActionTypeForObject:aButton info:sound key:aSoundKey];
    } else {
        [aAction setAudioCueType:0];
    }
    if (semicolon >= [aString length] + 1)
        return NO;
    NSString *list = [aString substringFromIndex:semicolon + 1];
    if (!list)
        return NO;
    NSMutableArray *names = [self HSOldFormatDocumentNBARecreation_namesFromList:list];
    [self setUserInfoWithActionTypeForObject:aButton info:aAction key:aActionKey];
    [self setUserInfoWithActionTypeForObject:aButton info:names key:aNamesKey];
    return YES;
}

// "<delay in ticks> <On|Off> <sound>;<buttons>".
- (id)processButtonListerNBAWithData:(id)aData button:(id)aButton
{
    HSButtonListerAction *action = [[HSButtonListerAction new] autorelease];
    NSString *string = [[[NSMutableString hyperStringWithASCIIData:aData] mutableCopy] autorelease];
    if (![string length])
        return action;
    NSUInteger space = [string rangeOfString:@" "].location;
    if (space != NSNotFound) {
        [action setPerformDelay:[[string substringToIndex:space] floatValue] / 60.0f];
        if (space < [string length])
            string = [[[string substringFromIndex:space + 1] mutableCopy] autorelease];
        else
            string = nil;
    }
    space = [string rangeOfString:@" "].location;
    if (space != NSNotFound) {
        [action setShouldRepeat:[[string substringToIndex:space] isEqualToString:@"On"]];
        if (space < [string length])
            string = [[[string substringFromIndex:space + 1] mutableCopy] autorelease];
    }
    [self HSOldFormatDocumentNBARecreation_setSoundAndButtonsFrom:string action:action button:aButton actionKey:@"~actionForButtonListerNBAKey" soundKey:@"~soundNameForButtonListerNBAKey" namesKey:@"~ButtonNamesForButtonListerNBAKey"];
    return action;
}

// "<sound>;<buttons>".
- (id)processButtonStepperNBAWithData:(id)aData button:(id)aButton
{
    HSButtonStepperAction *action = [[HSButtonStepperAction new] autorelease];
    NSString *string = [NSString hyperStringWithASCIIData:aData];
    if ([string length])
        [self HSOldFormatDocumentNBARecreation_setSoundAndButtonsFrom:string action:action button:aButton actionKey:@"~actionForButtonStepperNBAKey" soundKey:@"~soundNameForButtonStepperNBAKey" namesKey:@"~ButtonNamesForButtonStepperNBAKey"];
    return action;
}

// The fixed-width field at the offset, trimmed.
static NSString *HSOldFormatNBAField(NSString *aString, NSUInteger aOffset, NSUInteger aWidth)
{
    NSUInteger length = [aString length];
    NSString *field = [aString substringWithRange:NSMakeRange(aOffset, MIN(length - aOffset, aWidth))];
    return [field stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

// Fixed-width fields: scan delay and reset delay in ticks, cycles, the sound
// cue (1 a sound named after column 16, 2 the button names).
- (id)processButtonScannerNBAWithData:(id)aData button:(id)aButton
{
    HSButtonScannerAction *action = [[HSButtonScannerAction new] autorelease];
    NSString *string = [NSString hyperStringWithASCIIData:aData];
    if (![string length])
        return action;
    NSUInteger length = [string length];
    NSString *scanDelay = HSOldFormatNBAField(string, 0, 5);
    NSString *resetDelay = length > 4 ? HSOldFormatNBAField(string, 5, 4) : nil;
    NSString *cycles = length > 8 ? HSOldFormatNBAField(string, 9, 4) : nil;
    NSString *cue = length > 12 ? HSOldFormatNBAField(string, 13, 3) : nil;
    if (scanDelay && [scanDelay length])
        [action setScanDelay:(float)([scanDelay intValue] / 60.0)];
    if (resetDelay && [resetDelay length])
        [action setResetDelay:(float)([resetDelay intValue] / 60.0)];
    if (cycles && [cycles length])
        [action setScanCyclesCount:[cycles intValue]];
    if (!cue || ![cue length])
        return action;
    switch ([cue intValue]) {
    case 2:
        [action setAudioCueType:1];
        break;
    case 1: {
        [action setAudioCueType:2];
        // Fix: the original raised for data shorter than the sound's column.
        NSString *sound = length > 0x10 ? [string substringWithRange:NSMakeRange(0x10, length - 0x10)] : nil;
        if ([sound length]) {
            [self setUserInfoWithActionTypeForObject:aButton info:action key:@"~actionForButtonScannerNBAKey"];
            [self setUserInfoWithActionTypeForObject:aButton info:sound key:@"~soundNameForButtonScannerNBAKey"];
        }
        break;
    }
    default:
        [action setAudioCueType:0];
        break;
    }
    return action;
}

// A mail address ("mailto:") or a web page, http by default.
- (id)processExpPageNBAWithData:(id)aData button:(id)aButton
{
    id action = [HSGoToURLAction action];
    id attributes = [action queryHyperInterface:@protocol(HSGoToURLActionAttributes)];
    NSString *string = [NSString hyperStringWithASCIIData:aData];
    BOOL mail = [string hasPrefix:@"mailto:"];
    [attributes setURLType:mail];
    NSUInteger last = [string length] - 1;
    if ([string characterAtIndex:last] == 0)
        string = [string substringToIndex:last];
    if (mail) {
        [[attributes sendMailActionAttributes] setHyperEmailAddress:[string substringFromIndex:[@"mailto:" length]]];
        return action;
    }
    NSURL *url = [NSURL URLWithString:string];
    if (![url scheme] || ![[url scheme] length])
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"http://", string]];
    [[attributes openWebPageActionAttributes] setURL:url];
    return action;
}

// Lines of "<key>\<object title>"; a key of "*" and one character is that
// character with the command key. Each object is mapped once.
- (id)processKeyMapperNBAWithData:(id)aData button:(id)aButton
{
    NSArray *lines = [[NSString hyperStringWithASCIIData:aData] componentsSeparatedByString:@"\r"];
    id action = [HSKeyMapperAction action];
    id attributes = [action queryHyperInterface:@protocol(HSKeyMapperActionAttributes)];
    NSMutableArray *mappings = [NSMutableArray array];
    NSMutableSet *titles = [NSMutableSet set];
    int count = (int)[lines count];
    for (int i = 0; i < count; i++) {
        NSString *line = [lines objectAtIndex:i];
        if ([line isEqualToString:@""])
            continue;
        NSArray *parts = [line componentsSeparatedByString:@"\\"];
        if ([parts count] != 2)
            continue;
        NSString *key = [parts objectAtIndex:0];
        NSString *title = [parts objectAtIndex:1];
        if ([titles containsObject:title])
            continue;
        [titles addObject:title];
        NSString *mapped = [[self keyMappings] objectForKey:[key uppercaseString]];
        if (mapped)
            key = mapped;
        BOOL command = NO;
        if ([key length] == 2 && [[key substringToIndex:1] isEqualToString:@"*"]) {
            command = YES;
            key = [key substringFromIndex:1];
        }
        NSNumber *code = [NSNumber numberWithUnsignedShort:[key characterAtIndex:0]];
        [mappings addObject:[NSDictionary dictionaryWithObjectsAndKeys:key, @"HSKeyMapperActionCharacterKey", code, @"HSKeyMapperActionCharacterCodeKey", title, @"HSKeyMapperActionObjectTitleKey", [NSNumber numberWithBool:command], @"HSKeyMapperActionUseCommandKeyKey", nil]];
    }
    [attributes setKeyMappings:mappings];
    return action;
}

// A duration, possibly after one character; a duration of nothing after a
// space is one second.
- (id)processStarFieldNBAWithData:(id)aData button:(id)aButton
{
    NSString *string = [NSString hyperStringWithASCIIData:aData];
    id action = [HSStarFieldAction action];
    id attributes = [action queryHyperInterface:@protocol(HSStarFieldActionAttributes)];
    double duration = [string doubleValue];
    NSInteger mode = 0;
    if (duration != 0.0) {
        mode = 1;
    } else if ([string length] > 1) {
        string = [string substringFromIndex:1];
        duration = [string doubleValue];
        if (duration != 0.0) {
            mode = 1;
        } else if ([string hasPrefix:@" "]) {
            mode = 1;
            duration = 1.0;
        }
    }
    [attributes setStarFieldDurationMode:mode];
    [attributes setStarFieldDuration:duration];
    return action;
}

- (id)processSpeechRecognitionNBAWithData:(id)aData button:(id)aButton
{
    NSArray *names = [[NSString hyperStringWithASCIIData:aData] componentsSeparatedByString:@"\r"];
    id action = [HSSpeechRecognitionAction action];
    id attributes = [action queryHyperInterface:@protocol(HSSpeechRecognitionActionAttributes)];
    [self setUserInfoWithActionTypeForObject:aButton info:attributes key:@"~actionForSpeechRecognitionNBA"];
    [self setUserInfoWithActionTypeForObject:aButton info:names key:@"~buttonNamesForSpeechRecognitionNBA"];
    return action;
}

// A 28-byte record: object kind, show/hide/toggle, a Pascal name, then the
// hide and show transitions and their durations in quarter seconds.
- (id)processHideShow2NBAWithData:(id)aData button:(id)aButton
{
    id action = [HSShowHideObjectAction action];
    if ([aData length] != 0x1c)
        return action;
    unsigned char record[0x1c];
    [aData getBytes:record length:sizeof(record)];
    unsigned short kind = OSReadBigInt16(record, 0);
    NSString *kindName;
    if (kind == 1)
        kindName = @"field";
    else if (kind == 0)
        kindName = @"button";
    else if (kind == 2)
        kindName = @"graphic";
    else
        kindName = @"*";
    unsigned short verb = OSReadBigInt16(record, 2);
    NSString *verbName = verb == 1 ? @"show" : verb == 2 ? @"toggle" : @"hide";
    // Fix: the name's length byte could reach past the record.
    NSUInteger nameLength = MIN((NSUInteger)record[4], sizeof(record) - 5);
    NSString *name = [NSString hyperStringWithASCIIData:[NSData dataWithBytes:record + 5 length:nameLength]];
    name = [HSOldFormatDocument stringByTrimmingWhitespacesSuffixFromString:name];
    NSString *item = [[NSString stringWithFormat:@"%@ %@ %@", verbName, kindName, name] uppercaseString];
    [self setUserInfoWithActionTypeForObject:aButton info:[action queryHyperInterface:@protocol(HSShowHideObjectActionAttributes)] key:@"~actionForMultipleHideShowNBA"];
    float showDuration = MAX(0.05f, OSReadBigInt16(record, 0x1a) * 4.0f * 0.0625f);
    [self setUserInfoWithActionTypeForObject:aButton info:[NSArray arrayWithObject:item] key:@"~itemNamesForMultipleHideShowNBA"];
    NSDictionary *show = [NSDictionary dictionaryWithObjectsAndKeys:[[self transitionsNew] objectAtIndex:OSReadBigInt16(record, 0x16)], @"HSShowHideTransitionName", [NSNumber numberWithFloat:showDuration], @"HSShowHideTransitionDuration", nil];
    float hideDuration = MAX(0.05f, OSReadBigInt16(record, 0x18) * 4.0f * 0.0625f);
    NSDictionary *hide = [NSDictionary dictionaryWithObjectsAndKeys:[[self transitionsNew] objectAtIndex:OSReadBigInt16(record, 0x14)], @"HSShowHideTransitionName", [NSNumber numberWithFloat:hideDuration], @"HSShowHideTransitionDuration", nil];
    [self setUserInfoWithActionTypeForObject:aButton info:show key:@"~showEffectSettingsForMultipleHideShowNBA"];
    [self setUserInfoWithActionTypeForObject:aButton info:hide key:@"~hideEffectSettingsForMultipleHideShowNBA"];
    return action;
}

// One item per line, single-spaced.
- (id)processMultipleHideShowNBAWithData:(id)aData button:(id)aButton
{
    NSMutableString *string = [NSMutableString stringWithString:[[NSString hyperStringWithASCIIData:aData] uppercaseString]];
    while ([string rangeOfString:@"  "].location != NSNotFound)
        [string replaceOccurrencesOfString:@"  " withString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [string length])];
    // Quirk kept: no double spaces are left by now, so this never matches.
    while ([string rangeOfString:@"  \r"].location != NSNotFound)
        [string replaceOccurrencesOfString:@"  \r" withString:@"\r" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [string length])];
    NSArray *items = [string componentsSeparatedByString:@"\r"];
    id action = [HSShowHideObjectAction action];
    [self setUserInfoWithActionTypeForObject:aButton info:[action queryHyperInterface:@protocol(HSShowHideObjectActionAttributes)] key:@"~actionForMultipleHideShowNBA"];
    [self setUserInfoWithActionTypeForObject:aButton info:items key:@"~itemNamesForMultipleHideShowNBA"];
    return action;
}

- (id)processAutoTypeNBAWithData:(id)aData button:(id)aButton
{
    NSString *text = [NSString hyperStringWithASCIIData:aData];
    id action = [HSGhostWriterAction action];
    [aButton setUserInfo:[action queryHyperInterface:@protocol(HSGhostWriterActionAttributes)] forKey:@"~actionForAutoTypeNBA"];
    [aButton setUserInfo:text forKey:@"~textForTypeForAutoTypeNBA"];
    return action;
}

// "<seconds> <low|medium|high> [good NONE ]<name>".
- (id)processAutoRecordNBAWithData:(id)aData button:(id)aButton
{
    NSString *string = [NSString hyperStringWithASCIIData:aData];
    id action = [HSAutoRecordAction action];
    NSArray *parts = [string componentsSeparatedByString:@" "];
    if ([parts count] < 3)
        return action;
    id attributes = [action queryHyperInterface:@protocol(HSAutoRecordActionAttributes)];
    [attributes setRecordTime:[[parts objectAtIndex:0] doubleValue]];
    NSString *level = [parts objectAtIndex:1];
    NSInteger sensitivity = 0;
    if ([level isEqualToString:@"low"])
        sensitivity = 0;
    else if ([level isEqualToString:@"medium"])
        sensitivity = 1;
    else if ([level isEqualToString:@"high"])
        sensitivity = 2;
    [attributes setSensitivityLevel:sensitivity];
    NSString *name = [[parts subarrayWithRange:NSMakeRange(2, [parts count] - 2)] componentsJoinedByString:@" "];
    if ([name hasPrefix:@"good NONE "])
        name = [name substringFromIndex:[@"good NONE " length]];
    [attributes setRecordName:name];
    return action;
}

- (id)processMovieControllerNBAWithData:(id)aData button:(id)aButton
{
    NSString *command = [[NSString hyperStringWithASCIIData:aData] uppercaseString];
    id action = [HSMovieControllerAction action];
    id attributes = [action queryHyperInterface:@protocol(HSMovieControllerActionAttributes)];
    NSInteger movieCommand = 0;
    if ([command isEqualToString:@"PLAY"])
        movieCommand = 0;
    else if ([command isEqualToString:@"STOP"])
        movieCommand = 1;
    else if ([command isEqualToString:@"STEPFORWARD"])
        movieCommand = 2;
    else if ([command isEqualToString:@"STEPBACK"])
        movieCommand = 3;
    else if ([command isEqualToString:@"RESET"])
        movieCommand = 4;
    [attributes setMovieCommand:movieCommand];
    [self setUserInfoWithActionTypeForObject:aButton info:attributes key:@"~actionForMovieControllerNBA"];
    return action;
}

// A Pascal string "<options> +T<seconds> <Mac path of the pictures>", the
// options +L (loop), +X (leave the last picture) and +P (show file names).
- (id)processPictureShowNBAWithData:(id)aData button:(id)aButton
{
    unsigned char length = 0;
    if (![aData length])
        return nil;
    [aData getBytes:&length length:1];
    if ([aData length] < (NSUInteger)length + 1)
        return nil;
    NSString *string = [NSString hyperStringWithASCIIData:[aData subdataWithRange:NSMakeRange(1, length)]];
    if ([string rangeOfString:@"+T"].location == NSNotFound)
        return nil;
    NSArray *parts = [[@" " stringByAppendingString:string] componentsSeparatedByString:@"+T"];
    if ([parts count] < 2)
        return nil;
    NSString *options = [parts objectAtIndex:0];
    NSString *timing = [parts objectAtIndex:1];
    NSUInteger space = [timing rangeOfString:@" "].location;
    if (space == NSNotFound || space >= [timing length] - 1)
        return nil;
    NSString *delay = [timing substringToIndex:space];
    NSString *path = [self pathForApplePath:[timing substringFromIndex:space + 1]];
    double timeDelay = [delay doubleValue];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSArray *flags = [options componentsSeparatedByString:@" "];
    BOOL loop = NO, leavesLast = NO, showsNames = NO;
    int count = (int)[flags count];
    for (int i = 0; i < count; i++) {
        NSString *flag = [flags objectAtIndex:i];
        if ([flag isEqualToString:@"+L"])
            loop = YES;
        else if ([flag isEqualToString:@"+X"])
            leavesLast = YES;
        else if ([flag isEqualToString:@"+P"])
            showsNames = YES;
    }
    id action = [HSPictureShowAction action];
    id attributes = [action queryHyperInterface:@protocol(HSPictureShowActionAttributes)];
    [attributes setLoopPictureShow:loop];
    [attributes setLeavesLastPictureOnExit:leavesLast];
    [attributes setShowsFilenameOnPicture:showsNames];
    [attributes setTimeDelay:timeDelay];
    [attributes setURL:url];
    return action;
}

- (id)processButtonRunnerNBAWithData:(id)aData button:(id)aButton
{
    NSArray *ids = [[[NSString hyperStringWithASCIIData:aData] uppercaseString] componentsSeparatedByString:@"\r"];
    id action = [HSSequencerAction action];
    [self setUserInfoWithActionTypeForObject:aButton info:[action queryHyperInterface:@protocol(HSSequencerActionAttributes)] key:@"~actionForButtonRunnerNBA"];
    [self setUserInfoWithActionTypeForObject:aButton info:ids key:@"~itemsIdsButtonRunnerNBA"];
    return action;
}

// Binary data (with a zero byte) is a sequence of 44-byte records, each an
// item ID and its time; text is a slide show "<transition...> <speed>
// <seconds> <return> <click on exit> <loop>".
- (id)processSlideShowNBAWithData:(id)aData button:(id)aButton
{
    NSData *data = aData;
    NSInteger length = [aData length];
    BOOL binary = length <= 0;
    for (NSInteger i = 0; !binary && i < length - 1; i++) {
        char byte;
        [aData getBytes:&byte range:NSMakeRange(i, 1)];
        if (!byte)
            binary = YES;
    }
    if (binary) {
        id action = [HSSequencerAction action];
        id attributes = [action queryHyperInterface:@protocol(HSSequencerActionAttributes)];
        NSMutableDictionary *times = [NSMutableDictionary dictionary];
        NSInteger end = [aData length] - 1;
        // Fix: the original read a whole record past the end of the data.
        for (NSInteger i = 0; i < end && i + 0x2c <= (NSInteger)[aData length]; i += 0x2c) {
            unsigned char record[0x2c];
            [aData getBytes:record range:NSMakeRange(i, sizeof(record))];
            NSString *key = [NSString stringWithFormat:@"%d", OSReadBigInt16(record, 0x20)];
            float seconds = OSReadBigInt16(record, 0x28) + OSReadBigInt16(record, 0x2a) / 1000.0;
            [times setObject:[NSNumber numberWithFloat:seconds] forKey:key];
        }
        [self setUserInfoWithActionTypeForObject:aButton info:attributes key:@"~actionForSequencerNBA"];
        [self setUserInfoWithActionTypeForObject:aButton info:times key:@"~itemIdsForSequencerNBA"];
        return action;
    }
    if (length > 1) {
        char tail[2];
        [[aData subdataWithRange:NSMakeRange(length - 2, 2)] getBytes:tail length:2];
        if (tail[0] == ' ' && tail[1] == 0)
            data = [aData subdataWithRange:NSMakeRange(0, length - 2)];
    }
    NSArray *parts = [[NSString hyperStringWithASCIIData:data] componentsSeparatedByString:@" "];
    NSInteger count = [parts count];
    id action = [HSSlideShowAction action];
    id attributes = [action queryHyperInterface:@protocol(HSSlideShowActionAttributes)];
    if (count <= 4)
        return action;
    // Older ones have no loop flag at the end.
    NSString *last = [parts objectAtIndex:count - 1];
    NSInteger base = count - ([last rangeOfString:@"true"].location != NSNotFound || [last rangeOfString:@"false"].location != NSNotFound ? 5 : 6);
    NSString *name = [[parts subarrayWithRange:NSMakeRange(0, base)] componentsJoinedByString:@" "];
    NSString *speed = [parts objectAtIndex:base];
    double duration = [[parts objectAtIndex:base + 1] doubleValue];
    BOOL returns = [[parts objectAtIndex:base + 2] isEqualToString:@"true"];
    BOOL click = [[parts objectAtIndex:base + 3] isEqualToString:@"true"];
    BOOL loop = [[parts objectAtIndex:base + 4] rangeOfString:@"true"].location != NSNotFound;
    double transitionDuration;
    if ([speed isEqualToString:@"Medium"])
        transitionDuration = 1.25;
    else if ([speed isEqualToString:@"Slow"])
        transitionDuration = 2.0;
    else
        transitionDuration = 0.5;
    HSTransition *transition = [HSTransition transitionWithName:name];
    if (!transition) {
        NSInteger index = [[self transitionsOldLowCase] indexOfObject:[name lowercaseString]];
        if (index < 0 || index == NSNotFound)
            index = 0;
        transition = [HSTransition transitionWithName:[[self transitionsNew] objectAtIndex:index]];
    }
    [transition setDuration:transitionDuration];
    [attributes setSlideTransition:transition];
    [attributes setSlideDuration:duration];
    [attributes setReturnsToOriginalCard:returns];
    [attributes setLoopSlideShow:loop];
    [attributes setUseClickOnExitCard:click];
    return action;
}

// Volume 0 to 7.
- (id)processSetVolumeNBAWithData:(id)aData button:(id)aButton
{
    int volume = [[NSString hyperStringWithASCIIData:aData] intValue];
    id action = [HSSetVolumeAction action];
    [[action queryHyperInterface:@protocol(HSSetVolumeActionAttributes)] setVolumeLevel:volume / 7.0f];
    return action;
}

// Two text box names, one per line.
- (id)processTextMoveNBAWithData:(id)aData button:(id)aButton
{
    NSArray *names = [[[NSString hyperStringWithASCIIData:aData] uppercaseString] componentsSeparatedByString:@"\r"];
    if (!names || [names count] != 2)
        return nil;
    id action = [HSMoveTextAction action];
    [[action queryHyperInterface:@protocol(HSMoveTextActionAttributes)] setSourceAction:1];
    [self setUserInfoWithActionTypeForObject:aButton info:action key:@"~actionForTextMoveNBA"];
    [self setUserInfoWithActionTypeForObject:aButton info:names key:@"~textBoxNamesForTextMoveNBA"];
    return action;
}

// A big-endian name length, the name, then the compiled script, which is
// read back through a temporary file for its source.
- (id)processRunApplescriptNBAWithData:(id)aData button:(id)aButton
{
    id action = [HSRunAppleScriptAction action];
    NSUInteger length = [aData length];
    if (length <= 1)
        return action;
    unsigned short nameLength;
    [aData getBytes:&nameLength length:2];
    // Fix: the length was taken as signed, so a long name made a negative range.
    nameLength = CFSwapInt16BigToHost(nameLength);
    NSUInteger scriptOffset = nameLength + 2;
    if (scriptOffset >= length)
        return action;
    NSString *name = [NSString hyperStringWithASCIIData:[aData subdataWithRange:NSMakeRange(2, nameLength)]];
    NSData *script = [aData subdataWithRange:NSMakeRange(scriptOffset, length - scriptOffset)];
    NSString *path = [[[HSPathsProvider sharedPathsProvider] temporaryFolder] stringByAppendingPathComponent:[name lastPathComponent]];
    [script writeToFile:path atomically:YES];
    NSAppleScript *appleScript = [[[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil] autorelease];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager isDeletableFileAtPath:path])
        [manager removeItemAtPath:path error:nil];
    NSString *source = [appleScript source];
    id attributes = [action queryHyperInterface:@protocol(HSRunAppleScriptActionAttributes)];
    if (source) {
        [attributes setUseCustomAppleScriptSource:YES];
        [attributes setAppleScriptSource:source];
    }
    return action;
}

- (id)processSetCursorPositionNBAWithData:(id)aData button:(id)aButton
{
    id action = [HSSetCursorPositionAction action];
    NSArray *parts = [[NSString hyperStringWithASCIIData:aData] componentsSeparatedByString:@" "];
    if ([parts count] > 1) {
        float x = [[parts objectAtIndex:0] floatValue];
        float y = [[parts objectAtIndex:1] floatValue];
        [[action queryHyperInterface:@protocol(HSSetCursorPositionActionAttributes)] setCursorPosition:NSMakePoint(x, y)];
    }
    return action;
}

- (id)processPrintCardNBAWithData:(id)aData button:(id)aButton
{
    id action = [HSPrintCardAction action];
    id attributes = [action queryHyperInterface:@protocol(HSPrintCardActionAttributes)];
    NSString *options = [[NSString hyperStringWithASCIIData:aData] uppercaseString];
    [attributes setShowPageSetupDialog:[options rangeOfString:@"SETUP"].location != NSNotFound];
    [attributes setShowPrintDialog:[options rangeOfString:@"PRINT"].location != NSNotFound];
    [attributes setCenterPrintout:[options rangeOfString:@"CENTER"].location != NSNotFound];
    return action;
}

// "<anything>\<icon>\<message>\<button title>".
- (id)processShowMessageNBAWithData:(id)aData button:(id)aButton
{
    NSArray *parts = [[NSString hyperStringWithASCIIData:aData] componentsSeparatedByString:@"\\"];
    if ([parts count] < 4)
        return nil;
    NSString *message = [parts objectAtIndex:2];
    NSString *title = [parts objectAtIndex:3];
    NSInteger style;
    switch ([[parts objectAtIndex:1] intValue]) {
    case 0: style = 4; break;
    case 1: style = 2; break;
    case 2: style = 1; break;
    case 4: style = 3; break;
    default: style = 0; break;
    }
    id action = [HSShowMessageAction action];
    id attributes = [action queryHyperInterface:@protocol(HSShowMessageActionAttributes)];
    [attributes setMessageStyle:style];
    [attributes setMessageString:message];
    [attributes setButtonTitle:title];
    [attributes setRunAsModalDialog:YES];
    return action;
}

// Show, hide or obscure, by the first letter; anything else is left as is.
- (id)processHideCursorNBAWithData:(id)aData button:(id)aButton
{
    id action = [HSShowHideCursorAction action];
    id attributes = [action queryHyperInterface:@protocol(HSShowHideCursorActionAttributes)];
    NSString *string = [[NSString hyperStringWithASCIIData:aData] uppercaseString];
    if ([string hasPrefix:@"S"])
        [attributes setChangeCursorVisibilityAction:0];
    else if ([string hasPrefix:@"H"])
        [attributes setChangeCursorVisibilityAction:1];
    else if ([string hasPrefix:@"O"])
        [attributes setChangeCursorVisibilityAction:2];
    return action;
}

- (id)processObscureCursorNBAWithData:(id)aData button:(id)aButton
{
    id action = [HSShowHideCursorAction action];
    [[action queryHyperInterface:@protocol(HSShowHideCursorActionAttributes)] setChangeCursorVisibilityAction:2];
    return action;
}

- (id)processQuitAnotherNBAWithData:(id)aData button:(id)aButton
{
    HSQuitAnotherApplicationAction *action = [[HSQuitAnotherApplicationAction new] autorelease];
    NSString *application = [NSString hyperStringWithASCIIData:aData];
    if (application)
        [action setApplicationToQuit:application];
    return action;
}

- (id)processHomeStackNBAWithData:(id)aData button:(id)aButton
{
    return [HSMakeHomeStackAction action];
}

- (id)processCreditsScrollNBAWithData:(id)aData button:(id)aButton
{
    HSOldFormatCreditsScrollNBA *credits = [[HSOldFormatCreditsScrollNBA alloc] initWithData:aData];
    id action = [credits autoScrollAction];
    NSString *textBox = [credits targetTextBoxName];
    [credits release];
    [self setUserInfoWithActionTypeForObject:aButton info:action key:@"~actionForTextBoxScrollCreditNBA"];
    [self setUserInfoWithActionTypeForObject:aButton info:[textBox uppercaseString] key:@"~textBoxNameForScrollCreditNBA"];
    return action;
}

// The pitch and rate steps of the old speech settings (-1 to 2, -2 when
// unknown).
static NSInteger HSOldFormatRelativeSpeechStep(unsigned short aValue, unsigned short aNormal)
{
    if (aValue == aNormal + 1)
        return 1;
    if (aValue == aNormal)
        return 0;
    if (aValue == aNormal - 1)
        return -1;
    if (aValue == aNormal + 2)
        return 2;
    return -2;
}

// A 268-byte record: the text box name as a Pascal string, then the pitch,
// the rate and the voice.
- (id)processBlabberMouthNBAWithData:(id)aData button:(id)aButton
{
    if ([aData length] <= 0x10b)
        return nil;
    unsigned char record[0x10c];
    [aData getBytes:record range:NSMakeRange(0, sizeof(record))];
    unsigned short pitch = OSReadBigInt16(record, 0x100);
    unsigned short rate = OSReadBigInt16(record, 0x102);
    struct VoiceSpec voice;
    voice.creator = OSReadBigInt32(record, 0x104);
    voice.id = OSReadBigInt32(record, 0x108);
    p2cstrcpyMy(record, record);
    NSString *textBox = [NSString stringWithCString:(const char *)record encoding:NSMacOSRomanStringEncoding];
    if (!textBox)
        return nil;
    id action = [HSTextToSpeechAction action];
    id attributes = [action queryHyperInterface:@protocol(HSTextToSpeechActionAttributes)];
    [attributes setTextToSpeak:textBox];
    [attributes setRelativeSpeechPitch:HSOldFormatRelativeSpeechStep(pitch, 0x10)];
    [attributes setRelativeSpeechRate:HSOldFormatRelativeSpeechStep(rate, 10)];
    // Old voice IDs that moved.
    if (voice.id == 0xd2)
        voice.id = 200;
    else if (voice.id == 0x6e)
        voice.id = 100;
    else if (voice.id == 0)
        voice.id = 8;
    else if (voice.id == 0x140)
        voice.id = 300;
    [attributes setSpeechVoice:[[[SMKSpeechVoice alloc] initWithVoiceSpec:voice] autorelease]];
    [self setUserInfoWithActionTypeForObject:aButton info:action key:@"~actionForTextBox"];
    [self setUserInfoWithActionTypeForObject:aButton info:textBox key:@"~textBoxNameForSpeechAction"];
    return action;
}

// Seconds, one by default.
- (id)processPauseNBAWithData:(id)aData button:(id)aButton
{
    id action = [HSPauseAction action];
    id attributes = [action queryHyperInterface:@protocol(HSPauseActionAttributes)];
    NSString *string = [NSString hyperStringWithASCIIData:aData];
    double duration = 0;
    if (!string || ![[NSScanner scannerWithString:string] scanDouble:&duration])
        duration = 1.0;
    [attributes setPauseDuration:duration];
    return action;
}

- (id)processClearChangeFlagNBAWithData:(id)aData button:(id)aButton
{
    return [HSClearChangeFlagAction action];
}

- (id)processQuitNBAWithData:(id)aData button:(id)aButton
{
    return [HSQuitAction action];
}

// Only for stacks made for the legacy player: a menu command by its menu and
// item names.
- (id)processRunCommandNBAWithData:(id)aData button:(id)aButton
{
    if (![self isLegacyPlayerDetected])
        return nil;
    NSString *command = [NSString hyperStringWithASCIIData:aData];
    if (!command)
        return nil;
    id action = [HSRunCommandAction action];
    id attributes = [action queryHyperInterface:@protocol(HSRunCommandActionAttributes)];
    if ([command isEqualToString:@"File,Open Stack"])
        [attributes setRunCommandActionType:1];
    else if ([command isEqualToString:@"Apple,Feedback"])
        [attributes setRunCommandActionType:2];
    else if ([command isEqualToString:@"File,New Stack"])
        [attributes setRunCommandActionType:0];
    return action;
}

@end

@implementation SMKSpeechVoice (HSOldFormatDocumentNBARecreationAdditionalPrivate)

- (id)description
{
    return [[super description] stringByAppendingFormat:@" (name: %@)", [self name]];
}

@end
