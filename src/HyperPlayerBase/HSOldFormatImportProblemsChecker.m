#import "HSOldFormatImportProblemsChecker.h"
// Parses an old-format stack before import and collects what won't import
// faithfully (old cursors, missing fonts, unsupported NBAs, ...). The
// user can then cancel, import anyway, or import and send a report. Parser
// values are dispatched to processBy... methods (implemented in categories)
// the same way the old-format document does it.

static void HSOldFormatImportProblemsCheckerInvoke(id target, SEL selector, id *arguments, NSUInteger count)
{
    if (![target respondsToSelector:selector])
        return;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:selector]];
    [invocation setTarget:target];
    [invocation setSelector:selector];
    for (NSUInteger i = 0; i < count; i++)
        [invocation setArgument:&arguments[i] atIndex:i + 2];
    [invocation invoke];
    [pool release];
}

@implementation HSOldFormatImportProblemsChecker

// A font trait mask as a list, each entry followed by ", ".
- (id)descriptionForFontTraitMask:(NSInteger)aMask
{
    static const struct { NSInteger trait; NSString *name; } traits[] = {
        { NSItalicFontMask, @"I, " },
        { NSBoldFontMask, @"B, " },
        { NSUnboldFontMask, @"/B, " },
        { NSNonStandardCharacterSetFontMask, @"Non standard, " },
        { NSNarrowFontMask, @"Narrow, " },
        { NSExpandedFontMask, @"Expanded, " },
        { NSCondensedFontMask, @"Condensed, " },
        { NSSmallCapsFontMask, @"Small Caps, " },
        { NSPosterFontMask, @"Poster, " },
        { NSCompressedFontMask, @"Compressed, " },
        { NSFixedPitchFontMask, @"Fixed Pitch, " },
        { NSUnitalicFontMask, @"/I, " },
    };
    NSMutableString *description = [NSMutableString string];
    for (size_t i = 0; i < sizeof(traits) / sizeof(traits[0]); i++) {
        if ((aMask & traits[i].trait) != 0)
            [description appendString:traits[i].name];
    }
    return description;
}

// NBA names by ID, from OFFINbaNames.plist.
- (id)nbaNameById:(NSInteger)aId
{
    static NSDictionary *names = nil;
    if (!names)
        names = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle bundleForClass:[HSOldFormatImportProblemsChecker class]] pathForResource:@"OFFINbaNames" ofType:@"plist"]] retain];
    return [names objectForKey:[NSString stringWithFormat:@"%d", (int)aId]];
}

// The last parent name seen is shared by all checkers, as in the original.
- (void)oldFormatParser:(id)aParser didDeriveSimpleValue:(id)aValue forName:(id)aName parentName:(id)aName2 parameters:(id)aParameters
{
    static NSString *lastParentName = nil;
    if (![aName2 isEqualToString:lastParentName]) {
        [lastParentName release];
        lastParentName = [aName2 retain];
        id firstArguments[] = { aParser, aValue, aName, aParameters };
        HSOldFormatImportProblemsCheckerInvoke(self,
            NSSelectorFromString([NSString stringWithFormat:
                @"processFirstParentAppearance_%@_WithParser:value:forName:parameters:", aName2]),
            firstArguments, 4);
        id allArguments[] = { aParser, aValue, aName, aName2, aParameters };
        HSOldFormatImportProblemsCheckerInvoke(self,
            NSSelectorFromString(@"processFirstParentAppearanceWithParser:value:forName:parentName:parameters:"),
            allArguments, 5);
    }
    id parentArguments[] = { aParser, aValue, aName, aParameters };
    HSOldFormatImportProblemsCheckerInvoke(self,
        NSSelectorFromString([NSString stringWithFormat:@"processByParent_%@_WithParser:value:forName:parameters:", aName2]),
        parentArguments, 4);
    id nameArguments[] = { aParser, aValue, aParameters };
    HSOldFormatImportProblemsCheckerInvoke(self,
        NSSelectorFromString([NSString stringWithFormat:@"processBy_%@_%@_WithParser:value:parameters:", aName2, aName]),
        nameArguments, 3);
}

// Old animated and color cursors become standard ones.
- (void)addCursorImportingProblemIfNeededForOldCursorID:(NSInteger)aID
{
    if (aID != 0)
        [self addImportingProblemForCode:20013 point:@"001" info:@"(old cursors)"];
}

- (void)addImportingProblemForCode:(NSInteger)aCode point:(id)aPoint info:(id)aInfo
{
    [_problems addImportingProblemForCode:aCode point:aPoint info:aInfo];
}

- (BOOL)isLegacyPlayerDetected
{
    return _isLegacyPlayerDetected;
}

- (void)setParser:(id)aParser
{
    if (_parser != aParser) {
        [_parser release];
        _parser = [aParser retain];
    }
}

- (id)parser
{
    return _parser;
}

// The alert's second button cancels; the third imports and sends the
// problem report.
- (BOOL)shouldImportStack
{
    NSInteger result = [_problems runUserConfirmationAlert];
    if (result == NSAlertThirdButtonReturn)
        [self submitRequestWithString:[_problems reportTextWithFilename:[_oldFormatDocument fileName]]];
    return result != NSAlertSecondButtonReturn;
}

- (void)submitRequestWithString:(id)aString
{
    [[HSSubmitRequest sharedInstance] submitInformation:aString];
}

- (id)oldFormatDocument
{
    return _oldFormatDocument;
}

- (void)setOldFormatDocument:(id)aDocument
{
    if (_oldFormatDocument != aDocument) {
        [_oldFormatDocument autorelease];
        _oldFormatDocument = [aDocument retain];
    }
}

- (void)dealloc
{
    [_parser release];
    [_problems release];
    [_oldFormatDocument release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self)
        _problems = [HSImportProblems new];
    return self;
}

@end
