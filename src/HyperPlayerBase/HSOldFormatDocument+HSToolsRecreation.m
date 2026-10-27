#import "HSOldFormatDocument+HSToolsRecreation.h"

static NSArray *HSOldFormatHyperLogoWords;
static NSArray *HSOldFormatTransitionsNew;
static NSArray *HSOldFormatTransitionsOld;
static NSArray *HSOldFormatTransitionsOldLowCase;

// Helpers shared by the recreation categories: names, paths, cursors, font
// traits and the current action type.
@implementation HSOldFormatDocument (HSToolsRecreation)

+ (id)recreationItemNameFromString:(id)aString
{
    return [[self stringByTrimmingWhitespacesSuffixFromString:aString] uppercaseString];
}

// Leading whitespace is kept; only trailing whitespace goes.
+ (id)stringByTrimmingWhitespacesSuffixFromString:(id)aString
{
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];
    NSUInteger first = [aString rangeOfCharacterFromSet:[whitespace invertedSet]].location;
    NSString *prefix = first == NSNotFound ? @"" : [aString substringToIndex:first];
    return [prefix stringByAppendingString:[aString stringByTrimmingCharactersInSet:whitespace]];
}

// A card with one button of each old style, for checking the button styles.
- (void)debugStackCreation
{
    [[self stack] addHyperChild:[HSCard defaultObject]];
    [self makeSystemButtonWithType:@"HSRoundedOldstyleButtonType" origin:NSMakePoint(50, 30)];
    [self makeSystemButtonWithType:@"HSRoundedDefaultOldstyleButtonType" origin:NSMakePoint(50, 70)];
    [self makeSystemButtonWithType:@"HSRectangleOldstyleButtonType" origin:NSMakePoint(50, 110)];
    [self makeSystemButtonWithType:@"HSDropShadowRectangleOldstyleButtonType" origin:NSMakePoint(50, 150)];
    [self makeShapeButtonWithType:@"HSInvisibleShapeButtonType" origin:NSMakePoint(50, 190)];
    [self makeShapeButtonWithType:@"HSFreehandAreaShapeButtonType" origin:NSMakePoint(50, 230)];
    [self makeShapeButtonWithType:@"HSExpandingAreaShapeButtonType" origin:NSMakePoint(50, 270)];
    [self makeShapeButtonWithType:@"HSLassoAreaShapeButtonType" origin:NSMakePoint(50, 310)];
}

// A 100 x 35 button at the origin, added to the last card.
- (id)HSToolsRecreation_buttonWithBackgroundStyle:(NSString *)aStyle origin:(NSPoint)aOrigin
{
    id button = [HSButtonObject defaultObject];
    [(id<HSButtonObjectAttributes>)[button queryHyperInterface:@protocol(HSButtonObjectAttributes)] setBackgroundStyle:aStyle];
    [[button queryHyperInterface:@protocol(HSBorderAttributes)] setIsBorderless:NO];
    id applier = [[button queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    [applier resizeFrameTo:NSMakeSize(100, 35) aboutRelativePoint:NSZeroPoint withLayoutGuidingContext:nil];
    [applier moveFrameBoundingRectOriginTo:aOrigin withLayoutGuidingContext:nil];
    [button setEnabled:YES];
    return button;
}

- (void)HSToolsRecreation_addToLastCard:(id)aButton
{
    [[[self stack] hyperChildAtIndex:[[self stack] hyperCount] - 1] addHyperChild:aButton];
}

- (void)makeShapeButtonWithType:(id)aType origin:(NSPoint)aOrigin
{
    id button = [self HSToolsRecreation_buttonWithBackgroundStyle:@"HSButtonObjectShapeBackgroundStyle" origin:aOrigin];
    id shape = [button queryHyperInterface:@protocol(HSButtonObjectShapeBackgroundAttributes)];
    id border = [button queryHyperInterface:@protocol(HSButtonObjectBorderAttributes)];
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect(0, 0, 100, 35)];
    [shape setShapeButtonType:aType];
    [border setBorderPath:path];
    [border setIsBorderless:YES];
    [self HSToolsRecreation_addToLastCard:button];
}

- (void)makeSystemButtonWithType:(id)aType origin:(NSPoint)aOrigin
{
    id button = [self HSToolsRecreation_buttonWithBackgroundStyle:@"HSButtonObjectSystemBackgroundStyle" origin:aOrigin];
    [[button queryHyperInterface:@protocol(HSButtonObjectSystemStyleBackgroundAttributes)] setSystemButtonType:aType];
    [self HSToolsRecreation_addToLastCard:button];
}

- (id)hyperLogoWords
{
    if (!HSOldFormatHyperLogoWords) {
        NSString *path = [[NSBundle bundleForClass:[HSOldFormatDocument class]] pathForResource:@"OldFileFormatLogoWords" ofType:@"plist"];
        HSOldFormatHyperLogoWords = [[NSArray arrayWithContentsOfFile:path] retain];
    }
    return HSOldFormatHyperLogoWords;
}

- (id)transitionsNew
{
    if (!HSOldFormatTransitionsNew) {
        NSString *path = [[NSBundle bundleForClass:[HSOldFormatDocument class]] pathForResource:@"OldFileFormatNewTransition" ofType:@"plist"];
        HSOldFormatTransitionsNew = [[NSArray arrayWithContentsOfFile:path] retain];
    }
    return HSOldFormatTransitionsNew;
}

- (id)transitionsOld
{
    if (!HSOldFormatTransitionsOld) {
        NSString *path = [[NSBundle bundleForClass:[HSOldFormatDocument class]] pathForResource:@"OldFileFormatOldTransition" ofType:@"plist"];
        HSOldFormatTransitionsOld = [[NSArray arrayWithContentsOfFile:path] retain];
    }
    return HSOldFormatTransitionsOld;
}

- (id)transitionsOldLowCase
{
    if (!HSOldFormatTransitionsOldLowCase) {
        NSMutableArray *names = [NSMutableArray arrayWithArray:[self transitionsOld]];
        NSUInteger count = [names count];
        for (NSUInteger i = 0; i < count; i++)
            [names replaceObjectAtIndex:i withObject:[[names objectAtIndex:i] lowercaseString]];
        HSOldFormatTransitionsOldLowCase = [[NSArray arrayWithArray:names] retain];
    }
    return HSOldFormatTransitionsOldLowCase;
}

// A built-in cursor comes from the bundle with its known hot spot; others
// were imported from the stack under "CursorID_<id>".
- (void)setOldCursorForObject:(id)aObject withOldCursorId:(NSInteger)aId
{
    if (!aId)
        return;
    NSString *key = [NSString stringWithFormat:@"%d", (int)aId];
    NSString *hotSpot = [[self oldCursorHotSpot] objectForKey:key];
    id cursor;
    if (hotSpot) {
        NSString *name = [NSString stringWithFormat:@"%@.tiff", key];
        NSString *path = [[NSBundle bundleForClass:[HSOldFormatDocument class]] pathForResource:name ofType:nil];
        NSImage *image = [[[NSImage alloc] initWithContentsOfFile:path] autorelease];
        cursor = [[[HSCursor alloc] initWithImage:image hotSpot:NSPointFromString(hotSpot)] autorelease];
    } else {
        cursor = [[self parser] valuesBufferObjectForKey:[NSString stringWithFormat:@"CursorID_%d", (int)aId]];
    }
    if (cursor)
        [aObject setHyperCursor:cursor];
}

- (NSUInteger)fontTraitMaskForFaceStyle:(NSUInteger)aStyle
{
    return [self fontTraitMaskForFaceStyle:aStyle applyToObject:nil];
}

// The old face style bits (bold, italic, underline, outline, shadow,
// condense, extend) as a font trait mask, applied to the object if given;
// the styles a mask cannot hold go to the values buffer.
- (NSUInteger)fontTraitMaskForFaceStyle:(NSUInteger)aStyle applyToObject:(id)aObject
{
    id traits = aObject ? [aObject queryHyperInterface:@protocol(HSSystemTextViewFontTraitsAttributes)] : nil;
    NSUInteger mask = 0;
    if (aStyle & 1) {
        [traits setHyperBold:YES];
        mask = NSBoldFontMask;
    }
    if (aStyle & 2) {
        mask |= NSItalicFontMask;
        [traits setHyperItalic:YES];
    }
    NSString *underline = @"NO";
    if (aStyle & 4) {
        [traits setHyperUnderlined:YES];
        underline = @"YES";
    }
    NSString *outline = @"NO";
    if (aStyle & 8) {
        [traits setHyperOutlineEnabled:YES];
        outline = @"YES";
    }
    NSString *shadow = @"NO";
    if (aStyle & 0x10) {
        [traits setHyperShadowEnabled:YES];
        shadow = @"YES";
    }
    if (aStyle & 0x20) {
        mask |= NSCondensedFontMask;
        [traits setHyperCondensed:YES];
    }
    if (aStyle & 0x40) {
        mask |= NSExpandedFontMask;
        [traits setHyperExpanded:YES];
    }
    [[self parser] setValuesBufferObject:[NSNumber numberWithInt:(int)mask] forKey:@"~HTextViewAttributesTraitMask"];
    [[self parser] setValuesBufferObject:underline forKey:@"~HTextViewAttributesUnderlineStyle"];
    [[self parser] setValuesBufferObject:outline forKey:@"~HTextViewAttributesOutlineStyle"];
    [[self parser] setValuesBufferObject:shadow forKey:@"~HTextViewAttributesShadowStyle"];
    return mask;
}

- (id)actionObjectPathForApplePath:(id)aPath
{
    return [self actionObjectPathForPath:[self pathForApplePath:aPath]];
}

// The file as found next to the stack, else the path as it is.
- (id)actionObjectPathForPath:(id)aPath
{
    id path = [HSNavigationController findFile:aPath base:[[self fileName] stringByDeletingLastPathComponent]];
    return path ? path : aPath;
}

// "Disk:Folder:File" becomes "/Volumes/Disk/Folder/File".
- (id)pathForApplePath:(id)aPath
{
    NSMutableArray *components = [NSMutableArray arrayWithArray:[aPath componentsSeparatedByString:@":"]];
    [components insertObject:@"Volumes" atIndex:0];
    return [@"/" stringByAppendingString:[components componentsJoinedByString:@"/"]];
}

// Mac Roman text, up to 255 bytes.
- (id)stringForImportedData:(id)aData
{
    if (!aData || ![aData length])
        return nil;
    // Fix: the original copied up to 256 bytes into a 255-byte buffer and
    // left shorter text unterminated.
    char string[256] = {0};
    [aData getBytes:string length:MIN([aData length], (NSUInteger)255)];
    return [NSString stringWithCString:string encoding:NSMacOSRomanStringEncoding];
}

- (void)addHyperAction:(id)aAction to:(id)aTo
{
    if ([aTo isKindOfClass:[NSArray class]]) {
        int count = (int)[aTo count];
        for (int i = 0; i < count; i++)
            [self addHyperActionOneItem:aAction to:[aTo objectAtIndex:i]];
    } else {
        [self addHyperActionOneItem:aAction to:aTo];
    }
}

// The event for the current "~ActionType", or nil.
- (id)HSToolsRecreation_currentActionEvent
{
    NSString *type = [[self parser] valuesBufferObjectForKey:@"~ActionType"];
    NSString *eventType;
    if ([type isEqualToString:@"clicking"])
        eventType = kHSClickActionEventType;
    else if ([type isEqualToString:@"arriving"])
        eventType = kHSArriveActionEventType;
    else if ([type isEqualToString:@"leaving"])
        eventType = kHSLeaveActionEventType;
    else
        return nil;
    return [HSActionEvent actionEventOfType:eventType];
}

- (void)addHyperActionOneItem:(id)aItem to:(id)aTo
{
    id actor = [aTo queryHyperInterface:@protocol(HSActor)];
    id event = [self HSToolsRecreation_currentActionEvent];
    if (event)
        [actor addHyperAction:aItem forEvent:event];
}

- (void)removeHyperAction:(id)aAction from:(id)aFrom
{
    id actor = [aFrom queryHyperInterface:@protocol(HSActor)];
    if (!actor && [aFrom respondsToSelector:@selector(actor)])
        actor = [aFrom actor];
    id event = [self HSToolsRecreation_currentActionEvent];
    if (event)
        [actor removeHyperAction:aAction forEvent:event];
}

// Quirk kept: neither swaps; the parser already gives native values.
- (short)shortSwapped:(short)aSwapped
{
    return aSwapped;
}

- (NSInteger)longSwapped:(NSInteger)aSwapped
{
    return aSwapped;
}

- (id)userInfoWithActionTypeForObject:(id)aObject key:(id)aKey
{
    return [aObject userInfoForKey:[self userInfoWithActionKeyForKey:aKey]];
}

- (void)setUserInfoWithActionTypeForObject:(id)aObject info:(id)aInfo key:(id)aKey
{
    [aObject setUserInfo:aInfo forKey:[self userInfoWithActionKeyForKey:aKey]];
}

- (id)userInfoWithActionKeyForKey:(id)aKey
{
    return [NSString stringWithFormat:@"%@~%@", aKey, [[self parser] valuesBufferObjectForKey:@"~ActionType"]];
}

@end
