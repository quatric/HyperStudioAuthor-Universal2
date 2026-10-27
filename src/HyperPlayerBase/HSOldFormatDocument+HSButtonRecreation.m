#import "HSOldFormatDocument+HSButtonRecreation.h"
// Old-format import: buttons and their actions. The button being rebuilt is
// kept in the parser's values buffer under "~Button" (and "~ActionableObject",
// the object actions go to); actions that refer to other objects are wired
// up once the whole stack exists, in processPostCorrectionActions.

static id HSButtonRecreationParserObject(HSOldFormatDocument *aDocument, NSString *aKey)
{
    return [[aDocument parser] valuesBufferObjectForKey:aKey];
}

static void HSButtonRecreationSetParserObject(HSOldFormatDocument *aDocument, id aObject, NSString *aKey)
{
    [[aDocument parser] setValuesBufferObject:aObject forKey:aKey];
}

static BOOL HSButtonRecreationIsYES(id aValue)
{
    return [aValue isEqualToString:@"YES"];
}

// Moves the object to the rect's origin, then sizes it to the rect.
static void HSButtonRecreationPlace(id aObject, NSRect aRect)
{
    id applier = [[aObject queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    [applier moveFrameBoundingRectOriginTo:aRect.origin withLayoutGuidingContext:nil];
    [applier resizeFrameTo:aRect.size aboutRelativePoint:NSZeroPoint withLayoutGuidingContext:nil];
}

// A geometry and a size unit placing a node at the rect.
static NSDictionary *HSButtonRecreationNodeUnits(NSRect aRect)
{
    HSGeometryNodeUnit *geometry = [HSGeometryNodeUnit new];
    [geometry setAffineTransform:CGAffineTransformMake(1, 0, 0, 1, aRect.origin.x, aRect.origin.y)];
    HSSizeNodeUnit *size = [HSSizeNodeUnit new];
    [size setSize:aRect.size];
    NSDictionary *units = [NSDictionary dictionaryWithObjectsAndKeys:geometry, @"Geometry Unit", size, @"Size Unit", nil];
    [geometry release];
    [size release];
    return units;
}

// The stack's sound for the name, by its file name or its folder's.
static id HSButtonRecreationSoundMedia(HSOldFormatDocument *aDocument, NSString *aName)
{
    id media = [[aDocument stack] userInfoForKey:[NSString stringWithFormat:@"~soundByName_%@", aName]];
    if (!media)
        media = [[aDocument stack] userInfoForKey:[NSString stringWithFormat:@"~soundByName_%@", [aName stringByDeletingLastPathComponent]]];
    return media;
}

@implementation HSOldFormatDocument (HSButtonRecreation)

// The UIDs of the stack's buttons with these names, in order (NSNull for
// names not found; a name only matches once). nil for no names.
- (id)buttonUIDsFromButtonNames:(id)aNames
{
    NSMutableArray *names = [NSMutableArray arrayWithArray:aNames];
    NSUInteger count = [names count];
    NSMutableArray *uids = [NSMutableArray arrayWithCapacity:count];
    for (NSUInteger i = 0; i < count; i++)
        [uids addObject:[NSNull null]];
    NSEnumerator *enumerator = [[self stack] hyperDeepEnumerator];
    id object;
    while ((object = [enumerator nextObject])) {
        if (![names count] || ![object implementsHyperInterface:@protocol(HSButtonObjectAttributes)])
            continue;
        NSUInteger index = [names indexOfObject:[[object queryHyperInterface:@protocol(HSObjectAttributes)] hyperName]];
        if (index != NSNotFound) {
            [uids replaceObjectAtIndex:index withObject:[object hyperUID]];
            [names replaceObjectAtIndex:index withObject:[NSNull null]];
        }
    }
    return [uids count] ? uids : nil;
}

- (void)injectGeometryNodeUnits:(id)aUnits toNode:(id)aNode
{
    if (!aUnits || !aNode)
        return;
    NSEnumerator *enumerator = [aUnits keyEnumerator];
    id role;
    while ((role = [enumerator nextObject]))
        [aNode injectUnit:[aUnits objectForKey:role] forRole:role];
}

// The transitions whose speeds were read as a Mac stack's, for
// postprocessButtonHeadersTransspeed.
- (id)transitionsProcessedAsFromMac
{
    if (!_transitionsProcessedAsFromMac)
        _transitionsProcessedAsFromMac = [NSMutableArray new];
    return _transitionsProcessedAsFromMac;
}

- (void)processPostCorrectionNoClickAndDropOff
{
    NSEnumerator *enumerator = [[self stack] hyperDeepEnumerator];
    id object;
    while ((object = [enumerator nextObject])) {
        if (HSButtonRecreationIsYES([object userInfoForKey:@"HSOldFormatDropOffKey"]))
            [[object queryHyperInterface:@protocol(HSMutableCardObjectAttributes)] setDropOffOnly:YES];
        if (HSButtonRecreationIsYES([object userInfoForKey:@"HSOldFormatNoClickKey"]))
            [[object queryHyperInterface:@protocol(HSMutableCardObjectAttributes)] setNoClick:YES];
    }
}

// Once a stack turns out to come from Windows, the Mac speeds given to its
// earlier transitions move one step slower.
- (void)postprocessButtonHeadersTransspeed
{
    if (![[[self stack] userInfoForKey:@"~importedFromPlatform"] isEqualToString:@"WinPlatform"])
        return;
    for (HSTransition *transition in [self transitionsProcessedAsFromMac]) {
        double duration = [transition duration];
        if (fabs(duration - 1.25) < 0.1)
            [transition setDuration:0.5];
        else if (fabs(duration - 2.0) < 0.1)
            [transition setDuration:1.25];
        else if (fabs(duration - 3.0) < 0.1)
            [transition setDuration:2.0];
    }
}

- (void)processPostCorrectionStackCursor
{
    [self setOldCursorForObject:[self stack] withOldCursorId:[[self parser] intEvaluate:@"stackHeader.type.cursorID"]];
}

// Speech NBAs speaking a text box get the box.
- (void)HSButtonRecreation_correctSpeechActionFor:(id)aObject card:(id)aCard
{
    NSString *name = [self userInfoWithActionTypeForObject:aObject key:@"~textBoxNameForSpeechAction"];
    if (!name)
        return;
    id textBox = [aCard userInfoForKey:[NSString stringWithFormat:@"~textBoxByName_%@", [HSOldFormatDocument recreationItemNameFromString:name]]];
    if (!textBox)
        return;
    id speech = [[self userInfoWithActionTypeForObject:aObject key:@"~actionForTextBox"] queryHyperInterface:@protocol(HSTextToSpeechActionAttributes)];
    [speech setUsesTextObject:YES];
    [speech setTextObjectUID:[textBox hyperUID]];
    [speech setTextToSpeak:@""];
}

- (void)HSButtonRecreation_correctCreditsScrollActionFor:(id)aObject card:(id)aCard
{
    NSString *name = [self userInfoWithActionTypeForObject:aObject key:@"~textBoxNameForScrollCreditNBA"];
    if (!name)
        return;
    id textBox = [aCard userInfoForKey:[NSString stringWithFormat:@"~textBoxByName_%@", [name uppercaseString]]];
    if (!textBox)
        return;
    id credits = [[self userInfoWithActionTypeForObject:aObject key:@"~actionForTextBoxScrollCreditNBA"] queryHyperInterface:@protocol(HSTextViewProcessingActionAttributes)];
    [credits setTextViewUIDs:[NSArray arrayWithObject:[textBox hyperUID]]];
}

- (void)HSButtonRecreation_correctTextMoveActionFor:(id)aObject
{
    NSArray *names = [self userInfoWithActionTypeForObject:aObject key:@"~textBoxNamesForTextMoveNBA"];
    if ([names count] < 2)
        return;
    id source = HSButtonRecreationParserObject(self, [NSString stringWithFormat:@"~textBoxByName_%@", [HSOldFormatDocument recreationItemNameFromString:[names objectAtIndex:0]]]);
    id destination = HSButtonRecreationParserObject(self, [NSString stringWithFormat:@"~textBoxByName_%@", [HSOldFormatDocument recreationItemNameFromString:[names objectAtIndex:1]]]);
    if (!source)
        return;
    id move = [[self userInfoWithActionTypeForObject:aObject key:@"~actionForTextMoveNBA"] queryHyperInterface:@protocol(HSMoveTextActionAttributes)];
    [move setSourceObjectUID:[source hyperUID]];
    [move setDestinationObjectUID:[destination hyperUID]];
}

// "<SHOW|HIDE|TOGGLE> <type> <name>" entries: the card's object of that name
// and type, or else every object matching them ("*" matches any). Links
// whose hide/show is resolved here are taken off aLinks.
- (void)HSButtonRecreation_correctMultipleHideShowActionFor:(id)aObject card:(id)aCard objects:(NSArray *)aObjects links:(NSMutableArray *)aLinks
{
    NSArray *links = [[aObject queryHyperInterface:@protocol(HSHypertextLinkContainerAttributes)] allLinks];
    NSArray *owners = [links count] ? [links arrayByAddingObject:aObject] : [NSArray arrayWithObject:aObject];
    for (id owner in owners) {
        NSArray *entries = [self userInfoWithActionTypeForObject:owner key:@"~itemNamesForMultipleHideShowNBA"];
        if (!entries)
            continue;
        id hideShow = [self userInfoWithActionTypeForObject:owner key:@"~actionForMultipleHideShowNBA"];
        NSDictionary *none = [NSDictionary dictionaryWithObjectsAndKeys:@"No Transition", @"HSShowHideTransitionName", [NSNumber numberWithInt:0], @"HSShowHideTransitionDuration", nil];
        id show = [self userInfoWithActionTypeForObject:owner key:@"~showEffectSettingsForMultipleHideShowNBA"];
        id hide = [self userInfoWithActionTypeForObject:owner key:@"~hideEffectSettingsForMultipleHideShowNBA"];
        if (!show)
            show = none;
        if (!hide)
            hide = none;
        for (NSString *entry in entries) {
            NSArray *parts = [[HSOldFormatDocument stringByTrimmingWhitespacesSuffixFromString:entry] componentsSeparatedByString:@" "];
            if ([parts count] <= 2)
                continue;
            NSString *verb = [parts objectAtIndex:0];
            NSInteger action = 0;
            if ([verb isEqualToString:@"SHOW"])
                action = 1;
            else if ([verb isEqualToString:@"HIDE"])
                action = 2;
            else if ([verb isEqualToString:@"TOGGLE"])
                action = 3;
            NSString *type = [parts objectAtIndex:1];
            NSString *name = [[parts subarrayWithRange:NSMakeRange(2, [parts count] - 2)] componentsJoinedByString:@" "];
            id target = [aCard userInfoForKey:[NSString stringWithFormat:@"~itemShortName_%@_type_%@", name, type]];
            if (target) {
                [hideShow addObjectUID:[target hyperUID] action:action showEffectSettings:show hideEffectSettings:hide];
                if ([aLinks containsObject:owner])
                    [aLinks removeObject:owner];
                continue;
            }
            for (id candidate in aObjects) {
                NSString *oldName = [candidate userInfoForKey:@"~itemNameOld"];
                NSString *oldType = [candidate userInfoForKey:@"~itemTypeOld"];
                if (![oldName isEqualToString:name] && ![name isEqualToString:@"*"])
                    continue;
                if (![oldType isEqualToString:type] && ![type isEqualToString:@"*"])
                    continue;
                [hideShow addObjectUID:[candidate hyperUID] action:action showEffectSettings:show hideEffectSettings:hide];
                if ([aLinks containsObject:owner])
                    [aLinks removeObject:owner];
            }
        }
    }
}

// Item IDs to delays: each item's click-action object.
- (void)HSButtonRecreation_correctSequencerActionFor:(id)aObject
{
    NSDictionary *delays = [self userInfoWithActionTypeForObject:aObject key:@"~itemIdsForSequencerNBA"];
    if (!delays)
        return;
    id sequencer = [self userInfoWithActionTypeForObject:aObject key:@"~actionForSequencerNBA"];
    NSMutableArray *items = [NSMutableArray array];
    for (id itemID in [delays allKeys]) {
        id item = HSButtonRecreationParserObject(self, [NSString stringWithFormat:@"~clickingActionObjectOnlyByID_%@", itemID]);
        if (!item)
            item = HSButtonRecreationParserObject(self, [NSString stringWithFormat:@"~clickingActionObjectOnlyWinByID_%@", itemID]);
        if (!item)
            continue;
        HSSequenceItem *sequenceItem = [[HSSequenceItem alloc] initWithUID:[item hyperUID] withDelay:[[delays objectForKey:itemID] floatValue]];
        [items addObject:sequenceItem];
        [sequenceItem release];
    }
    [sequencer setSequenceItems:items];
}

// The named buttons, in the order the buffer keys come.
- (void)HSButtonRecreation_correctButtonRunnerActionFor:(id)aObject keys:(NSArray *)aKeys
{
    NSArray *names = [self userInfoWithActionTypeForObject:aObject key:@"~itemsIdsButtonRunnerNBA"];
    if (!names)
        return;
    NSMutableArray *items = [NSMutableArray array];
    for (NSString *key in aKeys) {
        for (NSString *name in names) {
            NSString *buttonKey = [NSString stringWithFormat:@"~itemName_%@_type_%@", [HSOldFormatDocument recreationItemNameFromString:name], @"BUTTON"];
            if ([key rangeOfString:buttonKey].location == NSNotFound)
                continue;
            id button = HSButtonRecreationParserObject(self, key);
            if (!button)
                continue;
            HSSequenceItem *sequenceItem = [[HSSequenceItem alloc] initWithUID:[button hyperUID] withDelay:0];
            [items addObject:sequenceItem];
            [sequenceItem release];
        }
    }
    [[self userInfoWithActionTypeForObject:aObject key:@"~actionForButtonRunnerNBA"] setSequenceItems:items];
}

// The buttons to listen for: the card's, or for a link any card's.
- (void)HSButtonRecreation_correctSpeechRecognitionActionFor:(id)aObject card:(id)aCard
{
    NSArray *names = [self userInfoWithActionTypeForObject:aObject key:@"~buttonNamesForSpeechRecognitionNBA"];
    if (!names)
        return;
    id recognition = [self userInfoWithActionTypeForObject:aObject key:@"~actionForSpeechRecognitionNBA"];
    NSMutableArray *uids = [NSMutableArray array];
    for (NSString *name in names) {
        NSString *key = [NSString stringWithFormat:@"~itemShortName_%@_type_%@", [name uppercaseString], @"BUTTON"];
        NSArray *cards = [aObject implementsHyperInterface:@protocol(HSHypertextLink)] ? [[self stack] hyperChildren] : [NSArray arrayWithObject:aCard];
        for (id card in cards) {
            id button = [card userInfoForKey:key];
            if (button)
                [uids addObject:[button hyperUID]];
        }
    }
    [recognition setObjectUIDs:uids];
}

- (void)HSButtonRecreation_correctAutoTypeActionFor:(id)aObject card:(id)aCard
{
    id ghostWriter = [aObject userInfoForKey:@"~actionForAutoTypeNBA"];
    if (!ghostWriter)
        return;
    NSArray *commands = [HSOldFormatGhostWriterNBA ghostWriterActionCommandsForString:[aObject userInfoForKey:@"~textForTypeForAutoTypeNBA"] card:aCard];
    if ([commands count])
        [ghostWriter setCommands:commands];
}

// The sound named for a scanner, stepper or lister, or no sound cue.
- (void)HSButtonRecreation_setSoundNamed:(NSString *)aName forAction:(id)aAction
{
    id media = HSButtonRecreationSoundMedia(self, aName);
    if (media)
        [aAction setAudioMediaUID:[media mediaUID]];
    else
        [aAction setAudioCueType:0];
}

- (void)HSButtonRecreation_correctButtonListActionsFor:(id)aObject
{
    id scanner = [self userInfoWithActionTypeForObject:aObject key:@"~actionForButtonScannerNBAKey"];
    if (scanner)
        [self HSButtonRecreation_setSoundNamed:[self userInfoWithActionTypeForObject:aObject key:@"~soundNameForButtonScannerNBAKey"] forAction:scanner];
    id stepper = [self userInfoWithActionTypeForObject:aObject key:@"~actionForButtonStepperNBAKey"];
    if (stepper) {
        NSMutableArray *names = [[[self userInfoWithActionTypeForObject:aObject key:@"~ButtonNamesForButtonStepperNBAKey"] mutableCopy] autorelease];
        [stepper setButtonUIDs:[self buttonUIDsFromButtonNames:names]];
        NSString *sound = [self userInfoWithActionTypeForObject:aObject key:@"~soundNameForButtonStepperNBAKey"];
        if (sound)
            [self HSButtonRecreation_setSoundNamed:sound forAction:stepper];
    }
    id lister = [self userInfoWithActionTypeForObject:aObject key:@"~actionForButtonListerNBAKey"];
    if (lister) {
        NSMutableArray *names = [[[self userInfoWithActionTypeForObject:aObject key:@"~ButtonNamesForButtonListerNBAKey"] mutableCopy] autorelease];
        [lister setButtonUIDs:[self buttonUIDsFromButtonNames:names]];
        NSString *sound = [self userInfoWithActionTypeForObject:aObject key:@"~soundNameForButtonListerNBAKey"];
        if (sound)
            [self HSButtonRecreation_setSoundNamed:sound forAction:lister];
    }
}

// Runs once the stack is built: parses the actions of every object
// collected by ID, resolves go-to-card buttons, groups, text styles, and
// the NBAs that name other objects.
- (void)processPostCorrectionActions
{
    HSOldFormatParser *parser = [self parser];
    [_progressDialog finishCurrentOperation];
    NSArray *keys = [[parser valuesBuffer] allKeys];
    for (NSString *key in keys) {
        NSString *type = nil;
        if ([key rangeOfString:@"~actionObjectByID_"].location != NSNotFound)
            type = @"clicking";
        if ([key rangeOfString:@"~clickingActionObjectByID_"].location != NSNotFound)
            type = @"clicking";
        if ([key rangeOfString:@"~arrivingActionObjectByID_"].location != NSNotFound)
            type = @"arriving";
        if ([key rangeOfString:@"~leavingActionObjectByID_"].location != NSNotFound)
            type = @"leaving";
        if (!type)
            continue;
        HSButtonRecreationSetParserObject(self, type, @"~ActionType");
        id object = HSButtonRecreationParserObject(self, key);
        if ([object isKindOfClass:[HSCard class]] && [object userInfoForKey:@"~SlaveCard"])
            continue;
        if (![[object queryHyperInterface:@protocol(HSActor)] respondsToSelector:@selector(hyperActions)])
            continue;
        HSButtonRecreationSetParserObject(self, object, @"~ActionableObject");
        int itemID = [[[key componentsSeparatedByString:@"_"] objectAtIndex:2] intValue];
        int offset = [parser intEvaluate:[NSString stringWithFormat:@"~actionOffsetByID_%d", itemID]];
        if (offset <= 0)
            continue;
        id card = object;
        if (![object isKindOfClass:[HSCard class]]) {
            if ([object isKindOfClass:[HSStack class]])
                card = [[self stack] hyperChildAtIndex:0];
            else
                card = [[object hyperParent] queryHyperInterface:@protocol(HSMutableCardAttributes)];
        }
        HSButtonRecreationSetParserObject(self, card, @"~Card");
        HSButtonRecreationSetParserObject(self, @"YES", @"ButtonItems");
        [parser valueForType:@"Item_kStkItmButton" atDefinedTree:[[parser typesTree] objectForKey:@"Item_kStkItmButton"] parent:nil atOffset:offset + 0x44];
    }

    HSButtonRecreationSetParserObject(self, @"clicking", @"~ActionType");
    for (NSUInteger i = 0; i < [keys count]; i++) {
        NSString *key = [keys objectAtIndex:i];
        if ([key rangeOfString:@"~hyperlinkOffsetByID_"].location == NSNotFound)
            continue;
        int offset = [parser intEvaluate:key];
        if (offset <= 0)
            continue;
        HSButtonRecreationSetParserObject(self, @"YES", @"ButtonItems");
        [parser valueForType:@"Blob_BT_HYPERLINK" atDefinedTree:[[parser typesTree] objectForKey:@"Blob_BT_HYPERLINK"] parent:nil atOffset:offset + 0x44];
    }

    // Buttons going to a card by number: the card is known now. A button
    // that opens a stack keeps opening it, at that card.
    keys = [[parser valuesBuffer] allKeys];
    for (NSString *key in keys) {
        if ([key rangeOfString:@"~goToNumberButtonID_"].location == NSNotFound)
            continue;
        id object = HSButtonRecreationParserObject(self, key);
        NSArray *parts = [key componentsSeparatedByString:@"_"];
        if ([parts count] < 3)
            continue;
        NSString *cardID = [parts objectAtIndex:2];
        id card = HSButtonRecreationParserObject(self, [NSString stringWithFormat:@"~cardID_%@", cardID]);
        HSOtherCardAction *action = [[HSOtherCardAction new] autorelease];
        id openStack = [[object userInfoForKey:@"HSOpenStackAction"] queryHyperInterface:@protocol(HSOpenStackActionAttributes)];
        if (openStack) {
            [action setCardIdOldFileFormat:[cardID intValue]];
            [action setURL:[openStack URL]];
            [[object queryHyperInterface:@protocol(HSActor)] replaceHyperAction:openStack withAction:action forEvents:[openStack events]];
        } else {
            [action setDestinationCardUID:[card hyperUID]];
            [self addHyperAction:action to:object];
        }
        int transitionType = [HSButtonRecreationParserObject(self, @"~TransitionType") intValue];
        float speed = [HSButtonRecreationParserObject(self, @"~TransitionSpeed") floatValue];
        HSTransition *transition = [HSTransition transitionWithName:[[self transitionsNew] objectAtIndex:transitionType]];
        [transition setDuration:(float)MIN(speed, HSMaxTransitionDuration)];
        [[self transitionsProcessedAsFromMac] addObject:transition];
        [action setTransition:transition];
    }

    for (id card in [self firstGroupCards]) {
        NSArray *children = [card hyperChildren];
        for (NSInteger i = 0; i < (NSInteger)[children count]; i++) {
            id child = [children objectAtIndex:i];
            if (![child isGroupObject] && [child userInfoForKey:@"~MasterObject"])
                [child makeGroupObject];
        }
    }

    // Text boxes: their card's (or stack's) text, outlines, and condensed or
    // expanded spacing.
    NSUInteger cardCount = [[[self stack] hyperChildren] count];
    for (NSUInteger c = 0; c < cardCount; c++) {
        id card = [[self stack] hyperChildAtIndex:c];
        NSArray *children = [card hyperChildren];
        for (NSInteger i = 0; i < (NSInteger)[children count]; i++) {
            id child = [children objectAtIndex:i];
            if (![child isKindOfClass:[HSSystemTextView class]])
                continue;
            NSString *text = [[child hyperText] string];
            NSArray *parts = [text componentsSeparatedByString:@"_"];
            id replacement = [card userInfoForKey:text];
            if (!replacement)
                replacement = [[self stack] userInfoForKey:text];
            if (replacement)
                [child setHyperText:replacement];
            if ([parts count] < 2)
                continue;
            id traits = [child queryHyperInterface:@protocol(HSSystemTextViewFontTraitsAttributes)];
            int itemID = [[parts objectAtIndex:1] intValue];
            if (HSButtonRecreationIsYES(HSButtonRecreationParserObject(self, [NSString stringWithFormat:@"~TextViewOutlineByID_%d", itemID]))) {
                id color = [child hyperSolidColor];
                [traits setHyperOutlineEnabled:YES];
                [traits setHyperOutlineColor:color];
                [traits setHyperOutlineWidth:-7.0];
                [child setTextColor:[NSColor clearColor]];
            }
            BOOL condensed = HSButtonRecreationIsYES(HSButtonRecreationParserObject(self, [NSString stringWithFormat:@"~TextViewCondensedByID_%d", itemID]));
            BOOL expanded = HSButtonRecreationIsYES(HSButtonRecreationParserObject(self, [NSString stringWithFormat:@"~TextViewExpandedByID_%d", itemID]));
            if (condensed == expanded)
                continue;
            id font = [child queryHyperInterface:@protocol(HSGenericFontAttributes)];
            float spacing;
            if (font)
                spacing = (condensed ? -5.0f : 5.0f) * (float)[font hyperFontSize] / 100.0f;
            else
                spacing = condensed ? -0.6f : 0.6f;
            [traits setHyperSpaceBetweenCharacters:spacing];
        }
    }

    // NBAs naming other objects, for each object on each card, each link and
    // each action type.
    HSButtonRecreationSetParserObject(self, nil, @"~ActionableObject");
    NSArray *cards = [[self stack] hyperChildren];
    NSMutableArray *links = [[NSMutableArray alloc] init];
    id stackLinks = [[self stack] queryHyperInterface:@protocol(HSHypertextLinkContainerAttributes)];
    if (stackLinks)
        [links addObjectsFromArray:[stackLinks allLinks]];
    NSArray *actionTypes = [NSArray arrayWithObjects:@"clicking", @"arriving", @"leaving", nil];
    for (NSUInteger c = 0; c < [cards count]; c++) {
        id card = [cards objectAtIndex:c];
        NSArray *children = [card hyperChildren];
        NSMutableArray *objects = [NSMutableArray arrayWithArray:children];
        [objects addObject:[self stack]];
        [objects addObject:card];
        [objects addObjectsFromArray:links];
        for (id child in children) {
            NSArray *childLinks = [[child queryHyperInterface:@protocol(HSHypertextLinkContainerAttributes)] allLinks];
            if (childLinks)
                [objects addObjectsFromArray:childLinks];
        }
        NSInteger objectCount = [objects count];
        for (NSInteger o = 0; o < objectCount; o++) {
            for (NSString *actionType in actionTypes) {
                HSButtonRecreationSetParserObject(self, actionType, @"~ActionType");
                id object = [objects objectAtIndex:o];
                [self HSButtonRecreation_correctSpeechActionFor:object card:card];
                [self HSButtonRecreation_correctCreditsScrollActionFor:object card:card];
                [self HSButtonRecreation_correctTextMoveActionFor:object];
                [self HSButtonRecreation_correctMultipleHideShowActionFor:object card:card objects:objects links:links];
                [self HSButtonRecreation_correctSequencerActionFor:object];
                [self HSButtonRecreation_correctButtonRunnerActionFor:object keys:keys];
                if (![self userInfoWithActionTypeForObject:object key:@"~soundForButton"]) {
                    id soundAction = [self userInfoWithActionTypeForObject:object key:@"~SoundMovieAction"];
                    if (soundAction)
                        [self addHyperAction:soundAction to:object];
                }
                [self HSButtonRecreation_correctSpeechRecognitionActionFor:object card:card];
                [self HSButtonRecreation_correctAutoTypeActionFor:object card:card];
                [self HSButtonRecreation_correctButtonListActionsFor:object];
            }
        }
    }
    [links release];
    [self postprocessButtonHeadersTransspeed];
}

// A live video window at the rect.
- (void)processBy_buttonItem_BTN_VIDEO_ITEM_header_rect_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    id object = HSButtonRecreationParserObject(self, @"~ActionableObject");
    HSPlayMovieAction *action = [HSPlayMovieAction new];
    id liveObject = [HSLiveObject defaultObject];
    [self addHyperAction:action to:object];
    HSLiveVideoPlaybackItem *item = [[HSLiveVideoPlaybackItem alloc] initWithLiveObject:liveObject playMovieAction:action];
    [self injectGeometryNodeUnits:HSButtonRecreationNodeUnits(NSRectFromString(aValue)) toNode:liveObject];
    [action addLiveVideo:item];
    [item setEnabled:YES];
    [action release];
    // Fix: the item was leaked.
    [item release];
}

// The NBA's process...NBAWithData:button: method makes its action; in debug
// mode its data is also written out.
- (void)processBy_buttonNbaItem_buttonItem_NBA_ITEM_body_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    id object = HSButtonRecreationParserObject(self, @"~ActionableObject");
    int nbaID = [[self parser] intEvaluate:@"buttonItem_NBA_ITEM_header.type.itemvar1"];
    NSString *name = [[self nbaById] objectForKey:[NSString stringWithFormat:@"%d", nbaID]];
    if (name) {
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"process%@NBAWithData:button:", name]);
        if ([self respondsToSelector:selector]) {
            id action = [self performSelector:selector withObject:aValue withObject:object];
            if (action)
                [self addHyperAction:action to:object];
        }
    }
    if ([self debugFlag]) {
        id offset = [aParameters objectForKey:@"offsetParameter"];
        NSString *fileName = [[[self parser] path] lastPathComponent];
        [[NSFileManager defaultManager] createDirectoryAtPath:@"/tmp/nba" withIntermediateDirectories:NO attributes:nil error:NULL];
        [aValue writeToFile:[@"/tmp/nba/" stringByAppendingFormat:@"%@-%@-%d.txt", fileName, offset, nbaID] atomically:YES];
    }
}

// A QuickTime file: a sound-only file plays as the button's sound, a movie
// plays in the item's rect. An unreadable file still gets an (empty) movie
// action.
- (void)processBy_buttonQtDskItem_buttonItem_QT_DSK_ITEM_body_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    int flags = [[self parser] intEvaluate:@"buttonItem_QT_DSK_ITEM_header.type.qtFlags"];
    id object = HSButtonRecreationParserObject(self, @"~ActionableObject");
    NSString *path = [self actionObjectPathForApplePath:aValue];
    if (!path || ![[NSFileManager defaultManager] hyperIsReadableFileAtPath:path showAlert:NO error:nil]) {
        if (aValue) {
            HSPlayMovieAction *action = [HSPlayMovieAction new];
            [self addHyperAction:action to:object];
            [action release];
        }
        return;
    }
    id media = [HSNewMedia mediaWithPath:path];
    if ([HSMovie canInitAsSoundOnlyWithURL:[NSURL fileURLWithPath:path] error:nil]) {
        HSMovie *movie = [[HSMovie alloc] initWithURL:[NSURL fileURLWithPath:path] error:nil];
        HSSoundItem *item = [[HSSoundItem alloc] initWithMediaUID:[media mediaUID] andApplyOptionsFromSound:movie];
        HSPlaySoundAction *action = nil;
        if (item) {
            action = [HSPlaySoundAction new];
            [[action queryHyperInterface:@protocol(HSPlaySoundActionAttributes)] addSound:item];
            [object setUserInfo:action forKey:@"~SoundMovieAction"];
        }
        [movie release];
        [item release];
        [action release];
    } else if ([HSMovie canInitAsVideoWithURL:[NSURL fileURLWithPath:path] error:nil]) {
        HSPlayMovieAction *action = [HSPlayMovieAction new];
        [self addHyperAction:action to:object];
        HSMoviePlaybackItem *item = [[HSMoviePlaybackItem alloc] initWithMediaUID:[media mediaUID] playMovieAction:action];
        [item setEnabled:YES];
        [item setShowFirstFrame:(flags >> 2) & 1];
        [item setPlayOverObjects:(flags >> 4) & 1];
        [item setPlayCount:(flags >> 5) & 1];
        [item setUseMovieController:flags & 1];
        [item setEraseWhenDone:(flags >> 3) & 1];
        NSRect rect = NSRectFromString(HSButtonRecreationParserObject(self, @"buttonItem_QT_DSK_ITEM_header.type.rect"));
        [self injectGeometryNodeUnits:HSButtonRecreationNodeUnits(rect) toNode:[item movieObjectForCard:nil]];
        [action addMovie:item];
        [item release];
        [action release];
    }
}

// Plays the media as the button's sound, at the item's volume.
- (void)HSButtonRecreation_addSoundMedia:(id)aMedia to:(id)aObject flags:(int)aFlags stopsAllSounds:(BOOL)aStops
{
    NSString *path = [aMedia fullPathToMediaFileCreateIfNeeded:YES];
    if (!path)
        return;
    HSMovie *movie = [[HSMovie alloc] initWithURL:[NSURL fileURLWithPath:path] error:nil];
    HSSoundItem *item = nil;
    HSPlaySoundAction *action = nil;
    if (movie)
        item = [[HSSoundItem alloc] initWithMediaUID:[aMedia mediaUID] andApplyOptionsFromSound:movie];
    if (item) {
        int volume = [[self parser] intEvaluate:@"buttonItem_SND_RES_ITEM_header.type.soundVol"];
        [item setVolume:(float)volume / 255.0];
        [item setSynchronousSound:!((aFlags >> 1) & 1)];
        action = [HSPlaySoundAction new];
        if (aStops)
            [action setStopsAllSounds:YES];
        [action addSound:item];
        [self addHyperAction:action to:aObject];
        [aObject setUserInfo:@"YES" forKey:@"~soundForButton"];
    }
    [movie release];
    [item release];
    [action release];
}

// A sound resource the stack already holds.
- (void)processBy_buttonItem_SND_RES_ITEM_header_flags_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    int resID = [[self parser] intEvaluate:@"buttonItem_SND_RES_ITEM_header.type.resID"];
    NSString *name = [[self stack] userInfoForKey:[NSString stringWithFormat:@"~soundNameByID_%d", resID]];
    id media = [[self stack] userInfoForKey:[NSString stringWithFormat:@"~soundByID_%d", resID]];
    if (!media || !name)
        return;
    id object = HSButtonRecreationParserObject(self, @"~ActionableObject");
    if (!object)
        return;
    [self HSButtonRecreation_addSoundMedia:media to:object flags:[[self parser] intEvaluate:aValue] stopsAllSounds:[name isEqualToString:@"Stop all sounds"]];
}

// A sound file. Quirk kept: its volume and flags are read from the sound
// resource item's header.
- (void)processBy_buttonSndDskItem_buttonItem_SND_DSK_ITEM_body_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    NSString *path = [self actionObjectPathForApplePath:aValue];
    if (!path)
        return;
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    if (data) {
        id media = [HSNewMedia mediaWithData:data name:[path lastPathComponent] type:@"wav"];
        id object = HSButtonRecreationParserObject(self, @"~ActionableObject");
        if (media && object)
            [self HSButtonRecreation_addSoundMedia:media to:object flags:[[self parser] intEvaluate:@"buttonItem_SND_RES_ITEM_header.type.flags"] stopsAllSounds:NO];
    }
    [data release];
}

// Scripts (HyperLogo) aren't imported; the user is warned.
- (void)processBy_buttonScriptItem_buttonItem_SCRIPT_ITEM_body_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    _isHyperLogoWarning = YES;
}

// A web page, or with "mailto:" a mail. Addresses without a scheme or an
// "@" get "http://"; addresses lose their spaces, web pages get them escaped.
- (void)processBy_buttonConnUrlItem_buttonItem_CONN_URL_body_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if (!aValue)
        return;
    NSString *trimmed = [aValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    trimmed = [trimmed stringByTrimmingCharactersInSet:[NSCharacterSet illegalCharacterSet]];
    NSMutableString *url = [NSMutableString stringWithString:trimmed];
    NSInteger length = [url length];
    while (length > 0) {
        unichar last = [url characterAtIndex:length - 1];
        if (last != 0 && last != ' ')
            break;
        [url deleteCharactersInRange:NSMakeRange(length - 1, 1)];
        length--;
    }
    if (length > 0) {
        if ([[url lowercaseString] rangeOfString:@"http://"].location == NSNotFound && [url rangeOfString:@"@"].location == NSNotFound)
            [url insertString:@"http://" atIndex:0];
        if ([url rangeOfString:@"@"].location != NSNotFound)
            [url replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [url length])];
        if ([url rangeOfString:@"http://"].location != NSNotFound)
            [url replaceOccurrencesOfString:@" " withString:@"%20" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [url length])];
    }
    id object = HSButtonRecreationParserObject(self, @"~ActionableObject");
    HSGoToURLAction *action = [[HSGoToURLAction new] autorelease];
    id attributes = [action queryHyperInterface:@protocol(HSGoToURLActionAttributes)];
    BOOL mail = [[url lowercaseString] hasPrefix:@"mailto:"];
    [attributes setURLType:mail];
    if (mail)
        [[attributes sendMailActionAttributes] setHyperEmailAddress:[url substringFromIndex:[@"mailto:" length]]];
    else
        [[attributes openWebPageActionAttributes] setURL:[NSURL URLWithString:url]];
    [self addHyperAction:action to:object];
}

// "<document>\n<application>": opens either or both; launch flag 0x4000
// quits after launching.
- (void)processBy_buttonConnApplItem_buttonItem_CONN_APPL_ITEM_body_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    int flags = [[self parser] intEvaluate:@"buttonItem_CONN_APPL_ITEM_header.type.launchFlags"];
    NSArray *parts = [aValue componentsSeparatedByString:@"\n"];
    NSString *document = nil;
    NSString *application = nil;
    if ([parts count] == 2) {
        document = [parts objectAtIndex:0];
        application = [parts objectAtIndex:1];
    }
    BOOL opensDocument = document && ![document isEqualToString:@""];
    BOOL opensApplication = application && ![application isEqualToString:@""];
    if (!opensDocument && !opensApplication)
        return;
    id object = HSButtonRecreationParserObject(self, @"~ActionableObject");
    HSOpenLocationAction *action = [[HSOpenLocationAction new] autorelease];
    id attributes = [action queryHyperInterface:@protocol(HSOpenLocationActionAttributes)];
    if (opensDocument) {
        NSString *path = [self actionObjectPathForApplePath:document];
        if (path) {
            [action setURL:[NSURL fileURLWithPath:path]];
            [attributes setOpensDocument:YES];
        }
    }
    if (opensApplication) {
        NSString *path = [self actionObjectPathForApplePath:application];
        if (path) {
            [action setApplicationName:path];
            [attributes setOpensApplication:YES];
        }
    }
    [attributes setQuitAfterLaunch:(flags >> 14) & 1];
    [self addHyperAction:action to:object];
}

// Another stack, looked for next to this one (as a .stack, then by its own
// name); a missing one is warned about and kept by its old path.
- (void)processBy_buttonConnStkItem_buttonItem_CONN_STK_ITEM_body_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    NSString *path = [self pathForApplePath:aValue];
    if (!path)
        return;
    id object = HSButtonRecreationParserObject(self, @"~ActionableObject");
    HSOpenStackAction *action = [[HSOpenStackAction new] autorelease];
    NSString *name = [path lastPathComponent];
    if ([name pathExtension])
        name = [name stringByDeletingPathExtension];
    NSString *folder = [[self fileName] stringByDeletingLastPathComponent];
    NSString *found = [HSNavigationController findFile:[name stringByAppendingPathExtension:@"stack"] base:folder];
    if (!found)
        found = [HSNavigationController findFile:[path lastPathComponent] base:[[self fileName] stringByDeletingLastPathComponent]];
    if (!found) {
        [self addFilesForWarnings1:[path lastPathComponent]];
        [self addFilesForWarnings2:[path lastPathComponent]];
        found = path;
    }
    [action setURL:[NSURL fileURLWithPath:found]];
    int transitionType = [HSButtonRecreationParserObject(self, @"~TransitionType") intValue];
    float speed = [HSButtonRecreationParserObject(self, @"~TransitionSpeed") floatValue];
    HSTransition *transition = [HSTransition transitionWithName:[[self transitionsNew] objectAtIndex:transitionType]];
    [transition setDuration:(float)MIN(speed, HSMaxTransitionDuration)];
    [[self transitionsProcessedAsFromMac] addObject:transition];
    [action setTransition:transition];
    if (![object isKindOfClass:[NSArray class]])
        [object setUserInfo:action forKey:@"HSOpenStackAction"];
    [self addHyperAction:action to:object];
}

// A region button's 1-bit mask becomes its border path.
- (void)processBy_buttonNewRgnItem_buttonItem_BTN_NEW_RGN_ITEM_body_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    id object = HSButtonRecreationParserObject(self, @"~ActionableObject");
    if (![object isKindOfClass:[HSButtonObject class]])
        return;
    int width = [[self parser] intEvaluate:@"buttonItem_BTN_NEW_RGN_ITEM_header.type.width"];
    int height = [[self parser] intEvaluate:@"buttonItem_BTN_NEW_RGN_ITEM_header.type.height"];
    int xOffset = [[self parser] intEvaluate:@"buttonItem_BTN_NEW_RGN_ITEM_header.type.xOff"];
    int yOffset = [[self parser] intEvaluate:@"buttonItem_BTN_NEW_RGN_ITEM_header.type.yOff"];
    void *mask = malloc([aValue length]);
    NSInteger bytesPerRow = ((width + 31) / 32) * 4;
    [aValue getBytes:mask length:[aValue length]];
    NSBezierPath *path = [NSBezierPath hyperBezierPathFromOneBitMask:mask width:width height:height bytesPerRow:bytesPerRow pathColor:1];
    BOOL hasPath = path && ![path isEmpty];
    if (hasPath)
        HSButtonRecreationSetParserObject(self, path, @"~RegionButtonBezierPathKey");
    if (mask)
        free(mask);
    if (hasPath)
        [[object queryHyperInterface:@protocol(HSButtonObjectBorderAttributes)] setBorderPath:path];
    [[[object queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier] moveFrameBoundingRectOriginTo:NSMakePoint(xOffset, yOffset) withLayoutGuidingContext:nil];
}

// A QuickTime transition effect replaces the go action's effect.
- (void)processBy_itemButtonHeader_effectID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    unsigned int effectID = [aValue unsignedIntValue];
    if (!effectID)
        return;
    id data = HSButtonRecreationParserObject(self, [NSString stringWithFormat:@"HSTransitionEffect_%d", effectID]);
    HSQTTransitionEffect *effect = [[HSQTTransitionEffect alloc] initWithAtomContainerData:data];
    [[HSButtonRecreationParserObject(self, @"~GoAction") transition] setEffect:effect];
    [effect release];
}

// The header's last field: sets up automatic actions, the button's style
// (kinds 0-3 system, 4-7 shape), colours and font. Remembers the button as
// the click-action object of its ID.
- (void)processBy_itemButtonHeader_textFace_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    HSOldFormatParser *parser = [self parser];
    int kind = [parser intEvaluate:@"itemButtonHeader.type.kind"];
    id object = HSButtonRecreationParserObject(self, @"~ActionableObject");
    int automatic = [parser intEvaluate:@"itemButtonHeader.type.autoactflag"];
    if (automatic > 0) {
        int delayTime = [parser intEvaluate:@"itemButtonHeader.type.delaytime"];
        double delay = delayTime < 0x1000 ? (double)delayTime : (double)(delayTime & 0xfff) / 10.0;
        id timer = [[object queryHyperInterface:@protocol(HSActor)] automaticTimerForActionEvent:[HSActionEvent actionEventOfType:kHSDefaultActionEventType]];
        [timer setRunActionsAutomatically:YES];
        [timer setDelayBeforeRunActionsAutomatically:delay];
        if (automatic == 2)
            [timer setDelayBetweenRepeatingActions:delay];
    }
    id cardObject = [object queryHyperInterface:@protocol(HSMutableCardObjectAttributes)];
    if (cardObject && !_isMasterCardIdExists && _isSharedItem && ![cardObject isGroupObject])
        [cardObject makeGroupObject];
    id<HSButtonObjectAttributes> button = (id<HSButtonObjectAttributes>)[object queryHyperInterface:@protocol(HSButtonObjectAttributes)];
    if (!button)
        return;
    id systemStyle = [object queryHyperInterface:@protocol(HSButtonObjectSystemStyleBackgroundAttributes)];
    NSRect rect = NSRectFromString(HSButtonRecreationParserObject(self, @"itemButtonHeader.type.rect"));
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect(0, 0, rect.size.width, rect.size.height)];
    [systemStyle setSystemButtonType:@"HSRoundedOldstyleButtonType"];
    switch ((unsigned short)kind) {
    case 0:
        [systemStyle setSystemButtonType:@"HSRoundedOldstyleButtonType"];
        break;
    case 1:
        [systemStyle setSystemButtonType:@"HSRoundedDefaultOldstyleButtonType"];
        break;
    case 2:
        [systemStyle setSystemButtonType:@"HSRectangleSystemButtonType"];
        break;
    case 3:
        [systemStyle setSystemButtonType:@"HSDropShadowRectangleOldstyleButtonType"];
        break;
    case 4:
    case 5:
    case 6:
    case 7: {
        static NSString *const shapeTypes[] = { @"HSInvisibleShapeButtonType", @"HSFreehandAreaShapeButtonType", @"HSExpandingAreaShapeButtonType", @"HSLassoAreaShapeButtonType" };
        [button setBackgroundStyle:@"HSButtonObjectShapeBackgroundStyle"];
        [[object queryHyperInterface:@protocol(HSButtonObjectShapeBackgroundAttributes)] setShapeButtonType:shapeTypes[kind - 4]];
        [[object queryHyperInterface:@protocol(HSButtonObjectBorderAttributes)] setBorderPath:path];
        int flags = [parser intEvaluate:@"itemButtonHeader.type.flags"];
        [button setTitleVisible:(flags >> 3) & 1];
        [button setHasHighlight:!((flags >> 2) & 1)];
        HSButtonRecreationPlace(object, rect);
        break;
    }
    default:
        break;
    }
    NSColor *textColor = HSButtonRecreationParserObject(self, @"~ButtonTextColor");
    if (!textColor)
        textColor = [NSColor blackColor];
    NSColor *backColor = HSButtonRecreationParserObject(self, @"~ButtonBackColor");
    if (!backColor)
        backColor = [NSColor whiteColor];
    int fontID = [parser intEvaluate:@"itemButtonHeader.type.textFont"];
    short size = (short)[parser intEvaluate:@"itemButtonHeader.type.textSize"];
    int face = [parser intEvaluate:aValue];
    [button setTitleColor:textColor];
    if (systemStyle) {
        [systemStyle setTintColor:backColor];
        [systemStyle setIgnoreTintColor:NO];
    }
    NSString *fontName = HSButtonRecreationParserObject(self, [NSString stringWithFormat:@"~fontByID_%d", (short)fontID]);
    NSFont *font = nil;
    if (fontName && ![fontName isEqualToString:@""])
        font = [NSFont fontWithName:fontName size:size];
    if (!font) {
        [self setFontWarning:YES];
        font = [NSFont fontWithName:@"Charcoal" size:size < 1 ? 12 : size];
    }
    if (!font) {
        [self setFontWarning:YES];
        font = [[NSFontManager sharedFontManager] convertFont:[button titleFont] toSize:size < 1 ? 12 : size];
    }
    if (font)
        [button setTitleFont:font];
    [self fontTraitMaskForFaceStyle:(short)face applyToObject:object];
    id itemID = HSButtonRecreationParserObject(self, @"itemButtonHeader.type.id");
    HSButtonRecreationSetParserObject(self, object, [NSString stringWithFormat:@"~clickingActionObjectOnlyByID_%@", itemID]);
}

// The cursor; a testing-function button (1-3) also gets that action.
- (void)processBy_itemButtonHeader_cursorID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    [self setOldCursorForObject:HSButtonRecreationParserObject(self, @"~Button") withOldCursorId:[aValue intValue]];
    int testFunction = [[self parser] intEvaluate:@"itemButtonHeader.type.testfun"];
    if (!testFunction)
        return;
    HSTestingFunctionsAction *action = [[HSTestingFunctionsAction new] autorelease];
    if (testFunction >= 1 && testFunction <= 3)
        [action setTestingFunctionType:testFunction];
    [self addHyperAction:action to:HSButtonRecreationParserObject(self, @"~ActionableObject")];
}

- (void)processBy_itemButtonHeader_iconID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    int iconID = [aValue intValue];
    if (!iconID)
        return;
    id icon = HSButtonRecreationParserObject(self, [NSString stringWithFormat:@"IconID_%d", iconID]);
    id button = HSButtonRecreationParserObject(self, @"~Button");
    if (![button isKindOfClass:[HSButtonObject class]])
        return;
    [button setIconVisible:YES];
    [button setIcon:icon];
    [button setIconPosition:5];
}

// The colours are palette indexes, kept for textFace.
- (void)HSButtonRecreation_setColorIndex:(id)aValue forKey:(NSString *)aKey
{
    if (![HSButtonRecreationParserObject(self, @"~ActionableObject") isKindOfClass:[HSButtonObject class]])
        return;
    HSButtonRecreationSetParserObject(self, [[self graphicsImport] backgroundColorAtIndex:[[self parser] intEvaluate:aValue]], aKey);
}

- (void)processBy_itemButtonHeader_framecolor_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    [self HSButtonRecreation_setColorIndex:aValue forKey:@"~ButtonFrameColor"];
}

- (void)processBy_itemButtonHeader_backcolor_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    [self HSButtonRecreation_setColorIndex:aValue forKey:@"~ButtonBackColor"];
}

- (void)processBy_itemButtonHeader_textcolor_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    [self HSButtonRecreation_setColorIndex:aValue forKey:@"~ButtonTextColor"];
}

// Flags 0x4 no highlight, 0x8 show name, 0x10 show icon, 0x20 hidden.
- (void)processBy_itemButtonHeader_flags_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if ([HSButtonRecreationParserObject(self, @"itemButtonHeader.type.type") shortValue] != 0x30)
        return;
    id button = HSButtonRecreationParserObject(self, @"~Button");
    if (_isSharedItem)
        [button setUserInfo:@"YES" forKey:@"~MasterObject"];
    unsigned short flags = [aValue unsignedShortValue];
    id<HSButtonObjectAttributes> attributes = (id<HSButtonObjectAttributes>)[button queryHyperInterface:@protocol(HSButtonObjectAttributes)];
    [attributes setTitleVisible:(flags & 8) != 0];
    HSButtonRecreationPlace(button, NSRectFromString(HSButtonRecreationParserObject(self, @"itemButtonHeader.type.rect")));
    [attributes setHasHighlight:(flags & 4) == 0];
    HSButtonRecreationSetParserObject(self, (flags & 8) ? @"YES" : @"NO", @"~ButtonAttributesTextShow");
    HSButtonRecreationSetParserObject(self, (flags & 0x10) ? @"YES" : @"NO", @"~ButtonAttributesIconShow");
    HSButtonRecreationSetParserObject(self, (flags & 0x20) ? @"YES" : @"NO", @"~ButtonAttributesHidden");
}

- (void)processBy_itemButtonHeader_testfun_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
}

// The button's title and name; it's registered under its name for the NBAs
// that name buttons (on its card, the first of that name).
- (void)processBy_itemButtonHeader_name_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if ([HSButtonRecreationParserObject(self, @"itemButtonHeader.type.type") shortValue] != 0x30)
        return;
    NSString *title = [aValue isKindOfClass:[NSData class]] ? [self stringForImportedData:aValue] : aValue;
    HSButtonObject *button = HSButtonRecreationParserObject(self, @"~Button");
    NSSize size = [button size];
    [button setTitle:title];
    [button setSize:size];
    NSString *name = [HSOldFormatDocument recreationItemNameFromString:title];
    HSButtonRecreationSetParserObject(self, button, [NSString stringWithFormat:@"~itemName_%@_type_%@_%@", name, @"BUTTON", [self uniqueImportedIndexString]]);
    NSString *shortNameKey = [NSString stringWithFormat:@"~itemShortName_%@_type_%@", name, @"BUTTON"];
    id card = HSButtonRecreationParserObject(self, @"~Card");
    if (![card userInfoForKey:shortNameKey])
        [card setUserInfo:button forKey:shortNameKey];
    [button setUserInfo:button forKey:shortNameKey];
    [button setUserInfo:name forKey:@"~itemNameOld"];
    [button setUserInfo:@"BUTTON" forKey:@"~itemTypeOld"];
    [button setHyperName:title];
    HSButtonRecreationSetParserObject(self, title, @"~ButtonName");
}

- (void)processBy_itemButtonHeader_itemstatflags_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    unsigned short flags = [aValue unsignedShortValue];
    id button = HSButtonRecreationParserObject(self, @"~Button");
    if (flags & 0x100)
        [button setUserInfo:@"YES" forKey:@"HSOldFormatDropOffKey"];
    if (flags & 0x80)
        [button setUserInfo:@"YES" forKey:@"HSOldFormatNoClickKey"];
}

// Speeds 0 / 8 / 16 / 32 (fast to slow). Speed 32 only exists on Windows,
// so it marks the stack as such; Mac speeds are remembered so they can be
// corrected if that turns out later.
- (void)processBy_itemButtonHeader_transspeed_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    id goAction = HSButtonRecreationParserObject(self, @"~GoAction");
    HSTransition *transition = [goAction transition];
    long speed = lroundf([aValue floatValue]);
    if (transition) {
        BOOL windows = [[[self stack] userInfoForKey:@"~importedFromPlatform"] isEqualToString:@"WinPlatform"];
        double duration;
        switch (speed) {
        case 0:
            duration = 0.5;
            break;
        case 8:
            if (windows) {
                duration = 0.5;
            } else {
                [[self transitionsProcessedAsFromMac] addObject:transition];
                duration = 1.25;
            }
            break;
        case 0x10:
            if (windows) {
                duration = 1.25;
            } else {
                [[self transitionsProcessedAsFromMac] addObject:transition];
                duration = 2.0;
            }
            break;
        case 0x20:
            [[self stack] setUserInfo:@"WinPlatform" forKey:@"~importedFromPlatform"];
            duration = 2.0;
            break;
        default:
            duration = 0;
            break;
        }
        [transition setDuration:duration];
        [goAction setTransition:transition];
    }
    if (HSButtonRecreationParserObject(self, @"~goToNumberButtonKey")) {
        NSNumber *storedSpeed = nil;
        switch (speed) {
        case 0:
            storedSpeed = [NSNumber numberWithFloat:0.5];
            break;
        case 8:
            storedSpeed = [NSNumber numberWithFloat:1.25];
            break;
        case 0x10:
            storedSpeed = [NSNumber numberWithFloat:2.0];
            break;
        case 0x20:
            storedSpeed = [NSNumber numberWithFloat:3.0];
            break;
        }
        HSButtonRecreationSetParserObject(self, storedSpeed, @"~TransitionSpeed");
    }
}

// Transitions 0 and 3 mean none.
- (void)processBy_itemButtonHeader_transition_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    int number = [[self parser] intEvaluate:@"itemButtonHeader.type.transition"];
    id goAction = HSButtonRecreationParserObject(self, @"~GoAction");
    HSTransition *transition = [HSTransition transitionWithName:@"No Transition"];
    [transition setDuration:0];
    int index = number >= 0 ? number % 0x1c : 0;
    if (index != 0 && index != 3) {
        transition = [HSTransition transitionWithName:[[self transitionsNew] objectAtIndex:index]];
        [transition setDuration:0.5];
    }
    [goAction setTransition:transition];
    if (HSButtonRecreationParserObject(self, @"~goToNumberButtonKey"))
        HSButtonRecreationSetParserObject(self, [NSNumber numberWithInt:index], @"~TransitionType");
}

// 1-0xefff go to that card (resolved later); 0xfffa-0xffff the first,
// last marked, back, home stack, previous and next card.
- (void)processBy_itemButtonHeader_linktocard_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    id object = HSButtonRecreationParserObject(self, @"~ActionableObject");
    unsigned short link = [aValue unsignedShortValue];
    id action = nil;
    if (link >= 1 && link <= 0xefff) {
        NSString *key = [NSString stringWithFormat:@"~goToNumberButtonID_%@_%@", HSButtonRecreationParserObject(self, @"itemButtonHeader.type.id"), aValue];
        HSButtonRecreationSetParserObject(self, object, key);
        HSButtonRecreationSetParserObject(self, key, @"~goToNumberButtonKey");
    } else {
        NSString *key = nil;
        switch (link) {
        case 0xfffa:
            action = [HSOtherCardAction action];
            [action setDestinationCardUID:[[[self stack] hyperChildAtIndex:0] hyperUID]];
            key = [NSString stringWithFormat:@"~goToNumberButtonID_%@_%@", HSButtonRecreationParserObject(self, @"itemButtonHeader.type.id"), aValue];
            break;
        case 0xfffb:
            action = [HSGoToLastMarkedCardAction action];
            break;
        case 0xfffc:
            action = [HSBackAction action];
            break;
        case 0xfffd:
            action = [HSGoToHomeStackAction action];
            break;
        case 0xfffe:
            action = [HSPreviousCardAction action];
            break;
        case 0xffff:
            action = [HSNextCardAction action];
            break;
        }
        HSButtonRecreationSetParserObject(self, key, @"~goToNumberButtonKey");
        if (action)
            [self addHyperAction:action to:object];
    }
    HSButtonRecreationSetParserObject(self, action, @"~GoAction");
}

- (void)processBy_itemButtonHeader_rect_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if ([HSButtonRecreationParserObject(self, @"itemButtonHeader.type.type") shortValue] != 0x30)
        return;
    HSButtonRecreationPlace(HSButtonRecreationParserObject(self, @"~Button"), NSRectFromString(aValue));
}

- (void)processBy_itemButtonHeader_id_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
}

// A button item starts a new rectangle button on the current card.
- (void)processBy_itemButtonHeader_type_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if ([aValue shortValue] != 0x30)
        return;
    id button = [HSButtonObject defaultObject];
    [(id<HSButtonObjectAttributes>)[button queryHyperInterface:@protocol(HSButtonObjectAttributes)] setBackgroundStyle:@"HSButtonObjectSystemBackgroundStyle"];
    [[button queryHyperInterface:@protocol(HSButtonObjectSystemStyleBackgroundAttributes)] setSystemButtonType:@"HSRectangleSystemButtonType"];
    [button setEnabled:YES];
    [button setTitle:@""];
    [button setTransparent:NO];
    [button setHidden:_isHiddenItem];
    [button setLocked:_isLocked];
    [button setImagePosition:5];
    [HSButtonRecreationParserObject(self, @"~Card") addHyperChild:button];
    HSButtonRecreationSetParserObject(self, button, @"~Button");
    HSButtonRecreationSetParserObject(self, button, @"~ActionableObject");
}

- (void)processFirstParentAppearance_itemButtonHeader_WithParser:(id)aParser value:(id)aValue forName:(id)aName parameters:(id)aParameters
{
}

@end
