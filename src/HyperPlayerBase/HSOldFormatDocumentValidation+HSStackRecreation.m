#import "HSOldFormatDocumentValidation+HSStackRecreation.h"

// Stack header values out of range make the file invalid.
@implementation HSOldFormatDocumentValidation (HSStackRecreation)

- (void)HSStackRecreation_invalidate:(id)aValue forKey:(NSString *)aKey
{
    [_validationErrors setObject:aValue forKey:aKey];
    _isValid = NO;
}

- (void)processBy_stackHeader_autoButtonOn_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if ((unsigned short)[aValue intValue] > 1)
        [self HSStackRecreation_invalidate:aValue forKey:@"autoButtonOn"];
}

- (void)processBy_stackHeader_locked_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if ((unsigned short)[aValue intValue] > 1)
        [self HSStackRecreation_invalidate:aValue forKey:@"locked"];
}

- (void)processBy_stackHeader_advancedUser_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if ((unsigned short)[aValue intValue] > 1)
        [self HSStackRecreation_invalidate:aValue forKey:@"advancedUser"];
}

- (void)processBy_stackHeader_autoSaveOn_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if ((unsigned short)[aValue intValue] > 1)
        [self HSStackRecreation_invalidate:aValue forKey:@"autoSaveOn"];
}

- (void)processBy_stackHeader_cardHeight_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if ((unsigned short)[aValue intValue] > 2000)
        [self HSStackRecreation_invalidate:aValue forKey:@"cardHeight"];
}

- (void)processBy_stackHeader_cardWidth_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if ((unsigned short)[aValue intValue] > 2000)
        [self HSStackRecreation_invalidate:aValue forKey:@"cardWidth"];
}

- (void)processBy_stackHeader_stackDepth_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if ((unsigned short)[aValue intValue] > 0x20)
        [self HSStackRecreation_invalidate:aValue forKey:@"stackDepth"];
}

- (void)processBy_stackHeader_offsetToBlobs_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if ([[self parser] dataLength] < [aValue intValue])
        [self HSStackRecreation_invalidate:aValue forKey:@"offsetToBlobs"];
}

- (void)processBy_stackHeader_numcards_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
}

// Only version 5 stacks are imported.
- (void)processBy_stackHeader_version_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if ([aValue intValue] != 5)
        [self HSStackRecreation_invalidate:aValue forKey:@"version"];
}

@end

@implementation HSOldFormatDocument (HSStackRecreation)

- (void)processBy_stackHeader_offsetToBlobs_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    _offsetToBlobs = [aValue intValue];
}

- (void)processBy_stackHeader_cursorID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    [self setOldCursorForObject:[self stack] withOldCursorId:[aValue intValue]];
}

// The stack's actions are found later by the action's ID.
- (void)processBy_stackHeader_backgdActionID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if ([aValue intValue])
        [[self parser] setValuesBufferObject:[self stack] forKey:[NSString stringWithFormat:@"~clickingActionObjectByID_%@_%@", @"stack", aValue]];
}

- (void)processBy_stackHeader_closeStkActionID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if ([aValue intValue])
        [[self parser] setValuesBufferObject:[self stack] forKey:[NSString stringWithFormat:@"~leavingActionObjectByID_%@_%@", @"stack", aValue]];
}

- (void)processBy_stackHeader_openStkActionID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if ([aValue intValue])
        [[self parser] setValuesBufferObject:[self stack] forKey:[NSString stringWithFormat:@"~arrivingActionObjectByID_%@_%@", @"stack", aValue]];
}

// The card size comes last in the header, so the cards are made here: a card
// whose master has a card becomes a new group card of that master's card,
// moved to the end and marked as a slave. The first half of the progress.
- (void)processBy_stackHeader_cardHeight_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    float height = [aValue floatValue];
    float width = [[[self parser] valuesBufferObjectForKey:@"stackHeader.type.cardWidth"] floatValue];
    [[self stack] setHyperCardSize:NSMakeSize(width, height)];
    [[self parser] setValuesBufferObject:NSStringFromSize(NSMakeSize(width, height)) forKey:@"~StackSize"];
    NSString *name = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"OldFileFormatImportCoverting" value:@"" table:@"ImportLocalizable"];
    [_progressDialog startOperationName:name minValue:0.0 maxValue:1.0];
    int count = [[self parser] intEvaluate:@"stackHeader.type.numcards"];
    if (count <= 0)
        return;
    double step = 0.5 / count;
    int i = 0;
    do {
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        id card = [HSCard defaultObject];
        HSOldFormatCard *oldCard = [[self cards] objectAtIndex:i];
        NSInteger master = [oldCard master];
        HSOldFormatCard *masterCard = [[self cardsById] objectForKey:[NSString stringWithFormat:@"%d", (int)master]];
        [masterCard setMaster:master];
        id recreated = [masterCard recreatedCard];
        if (recreated) {
            [masterCard setRecreatedMasterCard:recreated];
            [[self firstGroupCards] addObject:recreated];
        }
        i++;
        if (!masterCard) {
            [oldCard setRecreatedCard:card];
            [[self stack] addHyperChild:card];
        } else if (![masterCard recreatedMasterCard]) {
            [oldCard setRecreatedCard:card];
            [masterCard setRecreatedMasterCard:card];
            [[self firstGroupCards] addObject:card];
            [[self stack] addHyperChild:card];
        } else {
            id groupMaster = [masterCard recreatedMasterCard];
            [groupMaster makeNewGroupCard];
            id groupCard = [[self stack] hyperChildAtIndex:[[self stack] indexOfHyperChild:groupMaster] + 1];
            [oldCard setRecreatedCard:groupCard];
            [[self stack] moveChild:groupCard toIndex:[[self stack] hyperCount] - 1];
            [groupCard setUserInfo:@"YES" forKey:@"~SlaveCard"];
        }
        [_progressDialog setValue:i * step];
        [pool release];
    } while (i < count);
}

// The password is a Pascal string; its length byte is dropped when the
// string came back with it.
- (void)processBy_stackHeader_password_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if (![aValue length])
        return;
    NSString *password = [self stringForImportedData:aValue];
    unsigned char length;
    [aValue getBytes:&length range:NSMakeRange(0, 1)];
    if ([password length] - 1 == length)
        password = [password substringFromIndex:1];
    if (password && ![password isEqualToString:@""])
        [[self stack] setHyperPassword:password];
}

- (void)processBy_stackHeader_locked_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
}

- (void)processBy_stackHeader_presFlags_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    _presFlags = [aValue intValue] & 0xffff;
}

- (void)processBy_stackHeader_presColor_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    _presColor = [aValue intValue] & 0xffff;
}

- (void)processBy_stackHeader_presMode_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    int mode = [aValue intValue];
    if ((short)mode != 0)
        _presMode = mode & 0xffff;
}

- (void)processBy_stackHeader_autoButtonOn_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
}

- (void)processBy_stackHeader_flags_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
}

- (void)processFirstParentAppearance_stackHeader_WithParser:(id)aParser value:(id)aValue forName:(id)aName parameters:(id)aParameters
{
    _currentCardIndex = 0;
    [[self stack] removeAllChildren];
    [[self parser] setValuesBufferObject:@"clicking" forKey:@"~ActionType"];
}

@end
