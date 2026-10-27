#import "HSStack.h"
#import "HSActionEvent.h"
#import "HSCard.h"
#import "HSCardGroup.h"
#import "HSCardGroupController.h"
#import "HSClearChangeFlagAction.h"
#import "HSExecutableResourceProvider.h"
#import "HSGridSettings.h"
#import "HSInteractiveFlatObject.h"
#import "HSNewMediaAccessor.h"
#import "HSScriptAction.h"
#import "HSSmartGuidelinesSettings.h"
#import "HSSoundsInUseProvider.h"
#import "HSTestingFunctionsManager.h"
#import "HSUID.h"
#import "HSUserObjectDefaultAttributesProvider.h"
#import "HSiPadExporterHelper.h"
#import "NSImage+HSImageSize.h"
#import "NSObject+HSBackgroundAttributesContainer.h"

// The card size new stacks start with (zero: the default card size).
static NSSize HSNewStackCardSize;

@implementation HSStack

+ (void)setNewStackCardSize:(NSSize)aSize
{
    HSNewStackCardSize = aSize;
}

+ (NSSize)newStackCardSize
{
    return HSNewStackCardSize;
}

+ (id)defaultUnitClassNames
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"HSHypertextLinksContainerNodeUnit", @"HypertextLinks Container Unit", nil];
}

- (void)setObjectName:(id)aName
{
}

- (id)objectName
{
    return nil;
}

- (void)importLocalPropertiesFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    [super importLocalPropertiesFromXMLElementRepresentation:aRepresentation inContext:aContext];
    [self setHyperName:[[[aRepresentation elementsForName:HSXMLStoringNameString] extraFirstObject] stringValue]];
    [self setHyperComments:[[[aRepresentation elementsForName:HSXMLStoringCommentString] extraFirstObject] stringValue]];
    NSString *size = [[[[[aRepresentation elementsForName:@"cardref"] extraFirstObject] elementsForName:@"size"] extraFirstObject] stringValue];
    NSArray *components = [size componentsSeparatedByString:@","];
    if ([components count] > 1)
        [self setHyperCardSize:NSMakeSize([[components objectAtIndex:0] floatValue], [[components objectAtIndex:1] floatValue])];
}

- (void)storeLocalPropertiesInXMLElementRepresentation:(id)aRepresentation context:(id)aContext
{
    [super storeLocalPropertiesInXMLElementRepresentation:aRepresentation context:aContext];
    [aRepresentation addAttribute:[NSXMLNode attributeWithName:@"protected" stringValue:[self isStackProtected] ? HSXMLStoring1String : HSXMLStoring0String]];
    [aRepresentation addChild:[NSXMLElement elementWithName:HSXMLStoringNameString stringValue:[self name]]];
    [aRepresentation addChild:[NSXMLElement elementWithName:HSXMLStoringCommentString stringValue:[self hyperComments]]];
    [aRepresentation addChild:[NSXMLElement elementWithName:HSXMLStoringTitleString stringValue:[[self document] displayName]]];
    NSXMLElement *playerStyle = [NSXMLElement elementWithName:@"playerstyle"];
    [playerStyle addAttribute:[NSXMLNode attributeWithName:@"presentationCoveringDesktopMode" stringValue:[self isPresentationCoveringDesktopMode] ? HSXMLStoring1String : HSXMLStoring0String]];
    [playerStyle addAttribute:[NSXMLNode attributeWithName:@"presentationMenuVisible" stringValue:[self isPresentationMenuVisible] ? HSXMLStoring1String : HSXMLStoring0String]];
    [playerStyle addAttribute:[NSXMLNode attributeWithName:@"shouldPlayInFullScreen" stringValue:[self shouldPlayInFullScreen] ? HSXMLStoring1String : HSXMLStoring0String]];
    [aRepresentation addChild:playerStyle];
    for (id card in [self hyperChildren]) {
        if ([aContext shouldTerminateExport])
            return;
        [aRepresentation addChild:[self XMLCardRefElementForCard:card]];
    }
}

- (id)XMLCardRefElementForCard:(id)aCard
{
    NSXMLElement *element = [NSXMLElement elementWithName:@"cardref"];
    [element addAttribute:[NSXMLNode attributeWithName:@"refId" stringValue:[[aCard hyperUID] stringValue]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"target" stringValue:[HSiPadExporterHelper filenameForCard:aCard]]];
    [element addChild:[NSXMLElement elementWithName:HSXMLStoringTitleString stringValue:[aCard hyperTitle]]];
    NSSize size = [self hyperCardSize];
    [element addChild:[NSXMLElement elementWithName:@"size" stringValue:[NSString stringWithFormat:@"%.0f,%.0f", (double)size.width, (double)size.height]]];
    return element;
}

- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}

- (id)XMLElementName
{
    return @"stack";
}

// The default player view is a window with the menu bar; anything else
// can't be exported.
- (BOOL)HSStack_hasDefaultPlayerViewSettings
{
    return ![self isPresentationCoveringDesktopMode] && ![self isPresentationPlaysWithoutTitleBar] && [self isPresentationMenuVisible] && ![self shouldPlayInFullScreen];
}

- (id)HTML5UnsupportedFeaturesForDocumentType:(id)aType
{
    NSMutableSet *features = [NSMutableSet setWithSet:[super HTML5UnsupportedFeaturesForDocumentType:aType]];
    for (id link in [[self queryHyperInterface:@protocol(HSHypertextLinkContainerAttributes)] allLinks]) {
        if (![link hasUnsupportedHTML5FeaturesForDocumentType:aType])
            continue;
        NSSet *linkFeatures = [link HTML5UnsupportedFeaturesForDocumentType:aType];
        if ([linkFeatures count] != 0)
            [features unionSet:linkFeatures];
    }
    HSExecutableResourceProvider *provider;
    if (![self HSStack_hasDefaultPlayerViewSettings]) {
        provider = [HSExecutableResourceProvider sharedInstance];
        [features addObject:[provider localizedStringForKey:@"HSHTML5UnsupportedFeaturePlayerViewSettings" value:@"" table:@"Export"]];
    }
    // the stack's own click, arrive and leave actions
    for (id action in [[self queryHyperInterface:@protocol(HSActor)] hyperActions]) {
        for (id event in [action events]) {
            NSString *type = [event eventType];
            NSString *key;
            if ([type isEqualToString:kHSClickActionEventType])
                key = @"HSHTML5UnsupportedFeatureClickingStack";
            else if ([type isEqualToString:kHSArriveActionEventType])
                key = @"HSHTML5UnsupportedFeatureArrivingStack";
            else if ([type isEqualToString:kHSLeaveActionEventType])
                key = @"HSHTML5UnsupportedFeatureLeavingStack";
            else
                continue;
            provider = [HSExecutableResourceProvider sharedInstance];
            [features addObject:[provider localizedStringForKey:key value:@"" table:@"Export"]];
        }
    }
    return features;
}

// Only a lone clear-change-flag action on leaving (which every new stack
// has) is supported.
- (BOOL)hasUnsupportedHTML5FeaturesForDocumentType:(id)aType
{
    if ([super hasUnsupportedHTML5FeaturesForDocumentType:aType])
        return YES;
    for (id link in [[self queryHyperInterface:@protocol(HSHypertextLinkContainerAttributes)] allLinks]) {
        if ([link hasUnsupportedHTML5FeaturesForDocumentType:aType])
            return YES;
    }
    if (![self HSStack_hasDefaultPlayerViewSettings])
        return YES;
    id actor = [self queryHyperInterface:@protocol(HSActor)];
    NSArray *actions = [actor hyperActions];
    NSUInteger count = [actions count];
    if (count == 1) {
        id leaveEvent = [HSActionEvent actionEventOfType:kHSLeaveActionEventType];
        return [actions extraFirstObject] != [actor hyperActionOfType:[HSClearChangeFlagAction actionType] forEvent:leaveEvent];
    }
    return count != 0;
}

- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}

// The cards, the stack's links and the links of every card object (with
// the objects their actions need).
- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    id dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
    [dictionary setValue:[[self document] displayName] forKey:@"name"];
    [dictionary setValue:[NSString stringWithFormat:@"%u", (unsigned int)[self hyperCount]] forKey:@"count"];
    NSSize size = [self hyperCardSize];
    [dictionary setValue:[NSString stringWithFormat:@"%.0f", (double)size.width] forKey:@"xSize"];
    [dictionary setValue:[NSString stringWithFormat:@"%.0f", (double)[self hyperCardSize].height] forKey:@"ySize"];
    NSMutableArray *cards = [NSMutableArray new];
    NSArray *children = [self hyperChildren];
    for (id card in children) {
        if ([aContext shouldTerminateExport])
            break;
        [cards addObject:[card HTML5DictionaryRepresentationInContext:aContext]];
    }
    [dictionary setObject:cards forKey:@"cards"];
    [cards release];

    NSMutableArray *actionObjects = [NSMutableArray new];
    NSMutableArray *links = [NSMutableArray new];
    NSArray *stackLinks = [[self queryHyperInterface:@protocol(HSHypertextLinkContainerAttributes)] allLinks];
    if ([stackLinks count] != 0) {
        for (id link in stackLinks) {
            if ([aContext shouldTerminateExport])
                break;
            id representation = [link HTML5DictionaryRepresentationInContext:aContext];
            if (representation != nil) {
                [links addObject:representation];
                [actionObjects addObjectsFromArray:[[link actor] nonCardObjectRepsInContext:aContext]];
            }
        }
    }
    for (id card in children) {
        for (id object in [card hyperChildren]) {
            NSArray *objectLinks = [[object queryHyperInterface:@protocol(HSHypertextLinkContainerAttributes)] allLinks];
            if ([objectLinks count] == 0)
                continue;
            NSString *objectUID = [[[object queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID] stringValue];
            if (objectUID == nil)
                continue;
            for (id link in objectLinks) {
                id representation = [link HTML5DictionaryRepresentationInContext:aContext];
                if (representation == nil)
                    continue;
                [representation setObject:objectUID forKey:@"object"];
                [links addObject:representation];
                [actionObjects addObjectsFromArray:[[link actor] nonCardObjectRepsInContext:aContext]];
            }
        }
    }
    [dictionary setObject:links forKey:@"links"];
    if ([actionObjects count] != 0)
        [dictionary setObject:actionObjects forKey:@"linksActionObjects"];
    [links release];
    [actionObjects release];
    return dictionary;
}

- (BOOL)containsWebCams
{
    return _containsWebCams;
}

// Starts the next comment on a new line.
static NSString *HSStackCommentsSeparator(NSString *aComments)
{
    if ([aComments length] == 0 || [aComments hasSuffix:@"\n"])
        return [NSString string];
    return @"\n";
}

// The stack's comments and its cards', as one formatted text.
- (id)deepComments
{
    NSMutableString *result = [NSMutableString string];
    NSMutableString *comments = [NSMutableString string];
    [comments appendString:[self hyperComments]];
    NSString *childrenComments = [self childrenComments];
    [comments appendFormat:@"%@%@", HSStackCommentsSeparator(comments), childrenComments];
    if ([comments length] != 0) {
        NSString *format = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"HSStackCommentsFormat" value:@"" table:@"HyperPlayerBase"];
        [result appendFormat:format, comments];
    }
    return result;
}

- (id)childrenComments
{
    NSMutableString *result = [NSMutableString string];
    NSEnumerator *enumerator = [[self queryHyperInterface:@protocol(HSNodeContainer)] hyperEnumerator];
    id child;
    while ((child = [enumerator nextObject]) != nil) {
        id comments = [child queryHyperInterface:@protocol(HSCommentsAttributes)];
        if ([[comments hyperComments] length] == 0)
            continue;
        [result appendFormat:@"%@%@", HSStackCommentsSeparator(result), [comments hyperComments]];
    }
    return result;
}

- (id)soundMediaForPath:(id)aPath
{
    if (aPath == nil)
        return nil;
    NSEnumerator *enumerator = [[HSSoundsInUseProvider soundsInUseForStack:self] objectEnumerator];
    id sound;
    while ((sound = [enumerator nextObject]) != nil) {
        id media = [[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:[sound mediaUID]];
        if ([[media fullPathToMediaFileCreateIfNeeded:NO] isEqualToString:aPath])
            return media;
    }
    return nil;
}

- (BOOL)stackContainsSoundMediaWithName:(id)aName
{
    if (aName == nil)
        return NO;
    NSEnumerator *enumerator = [[HSSoundsInUseProvider soundsInUseForStack:self] objectEnumerator];
    id sound;
    while ((sound = [enumerator nextObject]) != nil) {
        id media = [[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:[sound mediaUID]];
        if ([[media mediaName] isEqualToString:aName])
            return YES;
    }
    return NO;
}

- (void)flushPresentationNotifications
{
    _arePresentationNotificationsSuspended = NO;
    [self notifyChange:1 ofAttribute:@protocol(HSStackPresentationModeAttributes) withUserInfo:nil];
    [self notifyChange:2 ofAttribute:@protocol(HSStackPresentationModeAttributes) withUserInfo:nil];
}

- (void)suspendPresentationNotifications
{
    _arePresentationNotificationsSuspended = YES;
}

- (BOOL)arePresentationNotificationsSuspended
{
    return _arePresentationNotificationsSuspended;
}

- (void)HSStack_preparePresentationModeUndo
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Player View Settings" value:@"" table:@"UndoManager"]];
}

- (void)setPresentationMenuVisible:(BOOL)aVisible
{
    if ((aVisible != NO) == _presentationFlags.menuVisible)
        return;
    [self notifyChange:1 ofAttribute:@protocol(HSStackPresentationModeAttributes) withUserInfo:nil];
    [self HSStack_preparePresentationModeUndo];
    [[[self undoManager] prepareWithInvocationTarget:self] setPresentationMenuVisible:_presentationFlags.menuVisible];
    _presentationFlags.menuVisible = aVisible != NO;
    [self notifyChange:2 ofAttribute:@protocol(HSStackPresentationModeAttributes) withUserInfo:nil];
}

- (BOOL)isPresentationMenuVisible
{
    return _presentationFlags.menuVisible;
}

- (void)setShouldPlayInFullScreen:(BOOL)aScreen
{
    if ((aScreen != NO) == _presentationFlags.shouldPlayInFullScreen)
        return;
    [self notifyChange:1 ofAttribute:@protocol(HSStackPresentationModeAttributes) withUserInfo:nil];
    [self HSStack_preparePresentationModeUndo];
    [[[self undoManager] prepareWithInvocationTarget:self] setShouldPlayInFullScreen:_presentationFlags.shouldPlayInFullScreen];
    _presentationFlags.shouldPlayInFullScreen = aScreen != NO;
    [self notifyChange:2 ofAttribute:@protocol(HSStackPresentationModeAttributes) withUserInfo:nil];
}

- (BOOL)shouldPlayInFullScreen
{
    return _presentationFlags.shouldPlayInFullScreen;
}

// The old name for playing without a title bar.
- (void)setPresentationPlaysInFullScreen:(BOOL)aScreen
{
    [self setPresentationPlaysWithoutTitleBar:aScreen];
}

- (BOOL)isPresentationPlaysInFullScreen
{
    return [self isPresentationPlaysWithoutTitleBar];
}

- (void)setPresentationPlaysWithoutTitleBar:(BOOL)aBar
{
    if ((aBar != NO) == _presentationFlags.withoutTitleBar)
        return;
    [self notifyChange:1 ofAttribute:@protocol(HSStackPresentationModeAttributes) withUserInfo:nil];
    [self HSStack_preparePresentationModeUndo];
    [[[self undoManager] prepareWithInvocationTarget:self] setPresentationPlaysWithoutTitleBar:_presentationFlags.withoutTitleBar];
    _presentationFlags.withoutTitleBar = aBar != NO;
    [self notifyChange:2 ofAttribute:@protocol(HSStackPresentationModeAttributes) withUserInfo:nil];
}

- (BOOL)isPresentationPlaysWithoutTitleBar
{
    return _presentationFlags.withoutTitleBar;
}

// Always a basic window now.
- (void)setPresentationBasicWindowMode:(BOOL)aMode
{
}

- (BOOL)isPresentationBasicWindowMode
{
    return YES;
}

- (void)setPresentationCoveringDesktopMode:(BOOL)aMode
{
    if ((aMode != NO) == _presentationFlags.coveringDesktopMode)
        return;
    [self notifyChange:1 ofAttribute:@protocol(HSStackPresentationModeAttributes) withUserInfo:nil];
    [self HSStack_preparePresentationModeUndo];
    [[[self undoManager] prepareWithInvocationTarget:self] setPresentationCoveringDesktopMode:_presentationFlags.coveringDesktopMode];
    _presentationFlags.coveringDesktopMode = aMode != NO;
    [self notifyChange:2 ofAttribute:@protocol(HSStackPresentationModeAttributes) withUserInfo:nil];
}

- (BOOL)isPresentationCoveringDesktopMode
{
    return _presentationFlags.coveringDesktopMode;
}

- (void)setHyperBackgroundGraphics:(id)aGraphics copyObject:(BOOL)aObject
{
    [self setBackgroundGraphics:aGraphics copyObject:aObject];
}

- (NSRect)backgroundBounds
{
    return NSZeroRect;
}

- (void)setBackgroundThumbnail:(id)aThumbnail
{
}

- (id)backgroundThumbnail
{
    return nil;
}

- (void)_setBackgroundGraphics:(id)aGraphics
{
    if (_background == aGraphics)
        return;
    [_background willRemoveFromDocument];
    [_background setHyperOwner:nil];
    [_background release];
    _background = [aGraphics retain];
    [_background setHyperOwner:self];
    [_background didAddToDocument];
}

- (id)backgroundGraphics
{
    return _background;
}

- (id)valuesForMDAttribute:(id)aAttribute
{
    id values = [super valuesForMDAttribute:aAttribute];
    if ([aAttribute isEqualToString:(NSString *)kMDItemNumberOfPages])
        values = [values arrayByAddingObject:[NSNumber numberWithInt:(int)[self hyperCount]]];
    return values;
}

- (id)supportedMDAttributes
{
    return [[super supportedMDAttributes] arrayByAddingObject:(NSString *)kMDItemNumberOfPages];
}

- (void)dropMovieObjectsCurrentTime
{
    [_playedInPlayerMovieObjects release];
    _playedInPlayerMovieObjects = nil;
}

// Puts the movies played in the player back to where they were; the ones
// not playing anymore are forgotten.
- (void)restoreMovieObjectsCurrentTime
{
    NSArray *UIDs = [[_playedInPlayerMovieObjects allKeys] copy];
    for (id UID in UIDs) {
        float time = [[_playedInPlayerMovieObjects objectForKey:UID] floatValue];
        id movie = [[self childInTreeWithUID:UID] queryHyperInterface:@protocol(HSPlayableObjectAttributes)];
        [movie setHyperCurrentTime:time];
        if (![movie isHyperPlaying])
            [_playedInPlayerMovieObjects removeObjectForKey:UID];
    }
    [UIDs release];
    if ([[_playedInPlayerMovieObjects allKeys] count] == 0) {
        [_playedInPlayerMovieObjects release];
        _playedInPlayerMovieObjects = nil;
    }
}

// Remembers a movie's time when first played in the player.
- (void)addCurrentTime:(double)aTime forMovieObject:(id)aObject
{
    if (_playedInPlayerMovieObjects == nil)
        _playedInPlayerMovieObjects = [NSMutableDictionary new];
    id UID = [[aObject queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID];
    if (![[_playedInPlayerMovieObjects allKeys] containsObject:UID])
        [_playedInPlayerMovieObjects setObject:[NSNumber numberWithFloat:(float)aTime] forKey:UID];
}

- (void)restoreObjectsVisibility
{
    if (_cardObjectsVisibility == 2)
        return;
    NSArray *objects = [_hiddenInPlayerObjects copy];
    NSEnumerator *enumerator = [objects objectEnumerator];
    id object;
    while ((object = [enumerator nextObject]) != nil)
        [[object queryHyperInterface:@protocol(HSMutableCardObjectAttributes)] setHiddenInPlayer:[object isHidden]];
    [objects release];
    [_hiddenInPlayerObjects release];
    _hiddenInPlayerObjects = nil;
}

- (void)addHiddenInPlayerObject:(id)aObject
{
    if (_hiddenInPlayerObjects == nil)
        _hiddenInPlayerObjects = [NSMutableArray new];
    [_hiddenInPlayerObjects addObject:aObject];
}

- (void)removeAllTemporaryObjects
{
    NSSet *objects = [[self temporaryObjects] copy];
    if ([objects count] != 0) {
        NSUndoManager *undoManager = [self undoManager];
        [undoManager disableUndoRegistration];
        [objects makeObjectsPerformSelector:@selector(removeFromHyperParent)];
        [[self temporaryObjects] removeAllObjects];
        [undoManager enableUndoRegistration];
    }
    [objects release];
}

- (void)removeAllTemporaryObjectsForCard:(id)aCard
{
    NSSet *objects = [[self temporaryObjects] copy];
    NSUndoManager *undoManager = [self undoManager];
    [undoManager disableUndoRegistration];
    for (id object in objects) {
        if ([object hyperParent] != aCard)
            continue;
        [[object queryHyperInterface:@protocol(HSNodeAttributes)] removeFromHyperParent];
        [_temporaryObjects removeObject:object];
    }
    [undoManager enableUndoRegistration];
    [objects release];
}

- (void)unregisterTemporaryObject:(id)aObject
{
    [[self temporaryObjects] removeObject:aObject];
}

- (void)registerTemporaryObject:(id)aObject
{
    [[self temporaryObjects] addObject:aObject];
}

- (id)temporaryObjects
{
    if (_temporaryObjects == nil)
        _temporaryObjects = [NSMutableSet new];
    return _temporaryObjects;
}

- (void)setCardObjectsVisibility:(NSInteger)aVisibility
{
    if (_cardObjectsVisibility == aVisibility)
        return;
    [self notifyChange:1 ofAttribute:@protocol(HSStackCardObjectsVisibilityAttribute) withUserInfo:nil];
    _cardObjectsVisibility = (int)aVisibility;
    [self notifyChange:2 ofAttribute:@protocol(HSStackCardObjectsVisibilityAttribute) withUserInfo:nil];
    NSEnumerator *enumerator = [self hyperEnumerator];
    id card;
    while ((card = [enumerator nextObject]) != nil)
        [[card hyperChildren] makeObjectsPerformSelector:@selector(notifyDidChangeUserObjectHitTesterAttribute)];
}

- (NSInteger)cardObjectsVisibility
{
    return _cardObjectsVisibility;
}

- (void)cardGroupController:(id)aController removeCardsAtIndexes:(id)aIndexes
{
    [self removeHyperChildren:[self hyperChildrenAtIndexes:aIndexes]];
}

- (void)cardGroupController:(id)aController addCards:(id)aCards atIndexes:(id)aIndexes
{
    NSEnumerator *enumerator = [aCards objectEnumerator];
    NSUInteger index = [aIndexes firstIndex];
    id card;
    while ((card = [enumerator nextObject]) != nil) {
        if (index != NSNotFound)
            [self insertHyperChild:card atIndex:index];
        index = [aIndexes indexGreaterThanIndex:index];
    }
}

- (id)cardGroupController:(id)aController cardAtIndex:(NSUInteger)aIndex
{
    return [self hyperChildAtIndex:aIndex];
}

- (id)cardsForCardGroupController:(id)aController
{
    return [self hyperChildren];
}

- (id)groupsForCardGroupController:(id)aController
{
    return _cardGroups;
}

- (id)undoManagerForCardGroupController:(id)aController
{
    return [self undoManager];
}

- (id)cardGroupController
{
    return _cardGroupController;
}

- (void)setCardGroups:(id)aGroups
{
    [aGroups retain];
    [_cardGroups release];
    _cardGroups = aGroups;
    NSEnumerator *groups = [aGroups objectEnumerator];
    id group;
    while ((group = [groups nextObject]) != nil) {
        NSEnumerator *data = [group dataEnumerator];
        id item;
        while ((item = [data nextObject]) != nil)
            [item setOwner:[self cardGroupController]];
    }
}

- (id)cardGroups
{
    return _cardGroups;
}

- (id)nodeDataProvider
{
    return _cardGroupController;
}

- (id)stackForAction:(id)aAction
{
    return self;
}

- (id)cardForAction:(id)aAction
{
    return [self card];
}

// No mouse-over or drop-off actions, and no going to another stack on leaving.
- (BOOL)supportsActionType:(id)aType forEvent:(id)aEvent
{
    id mouseOverEvent = [HSActionEvent actionEventOfType:kHSDeprecatedMouseOverActionEventType];
    id dropOffEvent = [HSActionEvent actionEventOfType:kHSDeprecatedDropOffActionEventType];
    BOOL supports = ![aEvent isEqual:mouseOverEvent] && ![aEvent isEqual:dropOffEvent];
    if ([aEvent isEqual:[HSActionEvent actionEventOfType:kHSLeaveActionEventType]]
        && [NSClassFromString(aType) isSubclassOfClass:[HSToGoAction class]])
        supports = NO;
    return supports;
}

- (id)queryNewHyperInterface:(id)aInterface
{
    if (protocol_conformsToProtocol(aInterface, @protocol(HSTestingFunctions)))
        return [self testingFunctionsManager];
    if (HSProtocolsAreEqual(aInterface, @protocol(HSInteractivePlayerItem)))
        return [[[HSInteractiveFlatObject alloc] initWithNode:self] autorelease];
    return [super queryNewHyperInterface:aInterface];
}

// Object snapping follows the smart layout preference.
- (void)setSnapToObjectsEnabled:(BOOL)aEnabled
{
}

- (BOOL)isSnapToObjectsEnabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"HSSmartUntitledWindowLayout"];
}

- (void)setSnapToGridEnabled:(BOOL)aEnabled
{
    if (_isSnapToGridEnabled == aEnabled)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Snap to Grid Change" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setSnapToGridEnabled:_isSnapToGridEnabled];
    [self notifyChange:1 ofAttribute:@protocol(HSLayoutGridSnappingAttribute) withUserInfo:nil];
    _isSnapToGridEnabled = aEnabled;
    [self notifyChange:2 ofAttribute:@protocol(HSLayoutGridSnappingAttribute) withUserInfo:nil];
}

- (BOOL)isSnapToGridEnabled
{
    return _isSnapToGridEnabled;
}

- (id)testingFunctionsManager
{
    if (_testingFunctionsManager == nil)
        _testingFunctionsManager = [[HSTestingFunctionsManager alloc] initWithStack:self];
    return _testingFunctionsManager;
}

- (id)basename
{
    return @"Stack";
}

- (id)wrapperExtension
{
    return @"hsstack";
}

- (id)currentWindow
{
    return [[[self support] cardView] window];
}

// Without a stored hash only an empty password is correct.
- (BOOL)isPasswordCorrect:(id)aCorrect
{
    if (_stackCompression == nil) {
        if (aCorrect != nil && ![aCorrect isEqualToString:@""])
            return NO;
    } else if (![[self compressString:aCorrect] isEqualToString:_stackCompression]) {
        return NO;
    }
    [self setRecentPassword:aCorrect];
    return YES;
}

// Toggles the protection with the given password.
- (void)setHyperPassword:(id)aPassword
{
    [self notifyChange:1 ofAttribute:@protocol(HSStackPasswordAttribute) withUserInfo:nil];
    [self setStackProtected:![self isStackProtected]];
    [self setPassword:aPassword];
    [[self document] updateChangeCount:NSChangeDone];
    [self notifyChange:2 ofAttribute:@protocol(HSStackPasswordAttribute) withUserInfo:nil];
}

- (void)setPassword:(id)aPassword
{
    [_password release];
    _password = [aPassword retain];
    [self setStackCompression:[self compressString:_password]];
}

- (id)recentPassword
{
    return [self isStackProtected] ? nil : _recentPassword;
}

- (void)setRecentPassword:(id)aPassword
{
    if ([_recentPassword isEqualToString:aPassword])
        return;
    [_recentPassword release];
    _recentPassword = [aPassword copy];
}

- (BOOL)isStackProtected
{
    return _isStackProtected || [_stackCompression length] != 0;
}

- (void)setStackProtected:(BOOL)aProtected
{
    _isStackProtected = aProtected;
}

- (id)stackCompression
{
    return _stackCompression;
}

- (void)setStackCompression:(id)aCompression
{
    if (_stackCompression == aCompression)
        return;
    [_stackCompression release];
    _stackCompression = [aCompression retain];
}

// The stored password hash: ten 16-bit values (in decimal) chained from the
// character sum and the first ten characters. nil for no password.
// The original returned it retained; autoreleased here.
- (id)compressString:(id)aString
{
    NSUInteger length = [aString length];
    if (aString == nil || length == 0)
        return nil;
    NSMutableString *result = [[NSMutableString new] autorelease];
    uint32_t value = 0;
    for (NSUInteger i = 0; i < length; i++)
        value += [aString characterAtIndex:i];
    for (NSUInteger i = 0; i < 10; i++) {
        uint32_t character = i < length ? [aString characterAtIndex:i] : 0;
        int32_t next = (int32_t)((value & 0xffff) * 0x305 + 0x9cd7 + character);
        value = (uint32_t)(next % 0xffff);
        [result appendString:[NSString stringWithFormat:@"%d", (int)(value & 0xffff)]];
    }
    return result;
}

// Stores the card groups some card still uses; the unused ones are dropped
// from the stack too.
- (id)extraDictionaryRepresentationWithCodingContext:(id)aContext
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[super extraDictionaryRepresentationWithCodingContext:aContext]];
    NSMutableSet *usedGroupUIDs = nil;
    NSUInteger count = [self hyperCount];
    for (NSUInteger i = 0; i < count; i++) {
        id groupUID = [[self hyperChildAtIndex:i] cardGroupUID];
        if (groupUID == nil)
            continue;
        if (usedGroupUIDs == nil) {
            usedGroupUIDs = [[NSMutableSet alloc] init];
            if (usedGroupUIDs == nil)
                break;
        }
        [usedGroupUIDs addObject:groupUID];
    }
    if ([usedGroupUIDs count] == 0) {
        [usedGroupUIDs release];
        [_cardGroups removeAllObjects];
        return dictionary;
    }
    NSMutableArray *keptGroups = nil;
    if ([usedGroupUIDs count] == [_cardGroups count]) {
        [usedGroupUIDs release];
        usedGroupUIDs = nil;
    } else {
        keptGroups = [[NSMutableArray alloc] init];
    }
    NSMutableArray *representations = [[[NSMutableArray alloc] initWithCapacity:[[self cardGroups] count]] autorelease];
    NSEnumerator *enumerator = [[self cardGroups] objectEnumerator];
    id group;
    while ((group = [enumerator nextObject]) != nil) {
        if (usedGroupUIDs != nil) {
            id groupUID = [group groupUID];
            if (groupUID == nil || ![usedGroupUIDs containsObject:groupUID])
                continue;
            [keptGroups addObject:group];
        }
        [representations addObject:[group extraDictionaryRepresentation]];
    }
    [usedGroupUIDs release];
    if (keptGroups != nil) {
        [_cardGroups release];
        _cardGroups = keptGroups;
    }
    [dictionary setObject:representations forKey:@"cardGroups-EXConformedCollection"];
    return dictionary;
}

// Older stacks with a background played covering the desktop.
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    _presentationFlags.shouldPlayInFullScreen = 0;
    NSMutableDictionary *representation = [NSMutableDictionary dictionaryWithDictionary:aRepresentation];
    [representation removeObjectForKey:@"cardObjectsHidden"];
    if (![[representation allKeys] containsObject:@"presentationCoveringDesktopMode"] && [[representation allKeys] containsObject:@"backgroundGraphics"])
        [representation setObject:[NSNumber numberWithBool:YES] forKey:@"presentationCoveringDesktopMode"];
    id groupRepresentations = [[representation objectForKey:@"cardGroups-EXConformedCollection"] retain];
    if (groupRepresentations == nil) {
        [super loadExtraDictionaryRepresentation:representation withCodingContext:aContext];
    } else {
        NSMutableDictionary *rest = [[representation mutableCopy] autorelease];
        [rest removeObjectForKey:@"cardGroups-EXConformedCollection"];
        [super loadExtraDictionaryRepresentation:rest withCodingContext:aContext];
        NSMutableArray *groups = [[NSMutableArray new] autorelease];
        NSEnumerator *enumerator = [groupRepresentations objectEnumerator];
        id groupRepresentation;
        while ((groupRepresentation = [enumerator nextObject]) != nil) {
            HSCardGroup *group = [[HSCardGroup new] autorelease];
            [group loadExtraDictionaryRepresentation:groupRepresentation];
            [groups addObject:group];
        }
        [self setCardGroups:groups];
    }
    [groupRepresentations release];
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    return [[super keysForExtraLoadingWithCodingContext:aContext] arrayByAddingObjectsFromArray:
        [NSArray arrayWithObjects:@"_layoutGrid", @"_isGridVisible", @"presentationCoveringDesktopMode", @"presentationBasicWindowMode", nil]];
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    id keys = [super keysForExtraStoringWithCodingContext:aContext];
    if ([[aContext codingOperation] isEqualToString:EXDefaultCodingOperation])
        keys = [keys arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:@"cardSizeAsString", @"stackCompression", @"_isStackProtected", @"_isSnapToGridEnabled",
                                                                             @"_isSnapToObjectsEnabled", @"_cardWithVisibleMenuBarUID", @"backgroundGraphics",
                                                                             @"presentationMenuVisible", @"presentationPlaysInFullScreen", @"shouldPlayInFullScreen",
                                                                             @"presentationCoveringDesktopMode", nil]];
    return keys;
}

- (void)setGuidelinesSettings:(id)aSettings
{
    if (_guidelinesSettings == aSettings)
        return;
    [_guidelinesSettings setUndoManager:nil];
    [_guidelinesSettings release];
    _guidelinesSettings = [aSettings retain];
    [_guidelinesSettings setUndoManager:[self undoManager]];
}

- (id)guidelinesSettings
{
    if (_guidelinesSettings == nil) {
        _guidelinesSettings = [[HSSmartGuidelinesSettings alloc] init];
        [_guidelinesSettings setUndoManager:[self undoManager]];
    }
    return _guidelinesSettings;
}

- (void)setGridSettings:(id)aSettings
{
    if (_gridSettings == aSettings)
        return;
    [_gridSettings setUndoManager:nil];
    [_gridSettings release];
    _gridSettings = [aSettings retain];
    [_gridSettings setUndoManager:[self undoManager]];
}

- (id)gridSettings
{
    if (_gridSettings == nil) {
        _gridSettings = [[HSGridSettings alloc] init];
        [_gridSettings setUndoManager:[self undoManager]];
    }
    return _gridSettings;
}

// The stack's actions and those of everything in it.
- (id)allActionsOfType:(id)aType
{
    if (aType == nil)
        return nil;
    NSMutableSet *actions = [NSMutableSet setWithSet:[super allActionsOfType:aType]];
    for (id node in [[self hyperDeepEnumerator] allObjects]) {
        if (node != self)
            [actions unionSet:[node allActionsOfType:aType]];
    }
    return actions;
}

- (BOOL)needsOwnUniqueNameGenerator
{
    return YES;
}

- (void)setCardSizeAsString:(id)aString
{
    NSSize size = NSSizeFromString(aString);
    _stackSize.width = roundf((float)size.width);
    _stackSize.height = roundf((float)size.height);
}

- (id)cardSizeAsString
{
    return NSStringFromSize(_stackSize);
}

// Resizes the cards and scales their objects along.
- (void)setHyperCardSize:(NSSize)aSize
{
    if (NSEqualSizes(_stackSize, aSize))
        return;
    float oldWidth = (float)_stackSize.width;
    float oldHeight = (float)_stackSize.height;
    [self HSStack_resizeCardTo:aSize];
    float horizontalScale = oldWidth != 0.0f ? (float)aSize.width / oldWidth : 1.0f;
    float verticalScale = oldHeight != 0.0f ? (float)aSize.height / oldHeight : 1.0f;
    [self HSStack_resizeCardObjectsWithScaleFactor:NSMakeSize(horizontalScale, verticalScale)];
}

// Scales the fonts and the frames (about the card origin) of every card
// object; shared node data is moved once.
- (void)HSStack_resizeCardObjectsWithScaleFactor:(NSSize)aFactor
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    float horizontalScale = (float)aFactor.width;
    float verticalScale = (float)aFactor.height;
    NSMutableArray *objects = [NSMutableArray array];
    NSEnumerator *cards = [[self hyperChildren] objectEnumerator];
    id card;
    while ((card = [cards nextObject]) != nil)
        [objects addObjectsFromArray:[card children]];
    NSMutableArray *movedData = [NSMutableArray array];
    NSEnumerator *enumerator = [objects objectEnumerator];
    id object;
    while ((object = [enumerator nextObject]) != nil) {
        id font = [object queryHyperInterface:@protocol(HSGenericFontAttributes)];
        if (font != nil) {
            float fontSize = (float)[font hyperFontSize];
            [font setHyperFontSize:roundf(fminf(horizontalScale, verticalScale) * fontSize)];
        }
        if ([movedData containsObject:[object nodeData]])
            continue;
        [movedData addObject:[object nodeData]];
        id applier = [[object queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
        id<HSMutableGeometryAttributes> geometry = [applier mutableGeometryAttributes];
        if (geometry == nil || applier == nil)
            continue;
        CGAffineTransform transform = [geometry affineTransform];
        NSSize size = [geometry size];
        float a = (float)transform.a, b = (float)transform.b, c = (float)transform.c, d = (float)transform.d;
        float width = (float)size.width, height = (float)size.height;
        float widthScale = hypotf(a * horizontalScale, b * verticalScale);
        float heightScale = hypotf(c * horizontalScale, d * verticalScale);
        [applier resizeFrameTo:NSMakeSize(width * widthScale, height * heightScale)
                    aboutRelativePoint:NSMakePoint(0.5, 0.5)
       followResizingScalingPreference:YES
                   maintainAspectRatio:2
          byAspectRatioMaintainingRule:!(horizontalScale < 1.0f || verticalScale < 1.0f)
              withLayoutGuidingContext:nil
                                 force:YES];
        float centerX = a * width * 0.5f + c * height * 0.5f + (float)transform.tx;
        float centerY = b * width * 0.5f + d * height * 0.5f + (float)transform.ty;
        [applier moveBy:NSMakeSize(centerX * (horizontalScale - 1.0f), centerY * (verticalScale - 1.0f)) withLayoutGuidingContext:nil];
    }
    [pool release];
}

- (void)HSStack_resizeCardTo:(NSSize)aTo
{
    float width = roundf((float)aTo.width);
    float height = roundf((float)aTo.height);
    [self notifyChange:1 ofAttribute:@protocol(HSStackCardSizeAttribute) withUserInfo:nil];
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Card Size" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] HSStack_resizeCardTo:_stackSize];
    _stackSize.width = width;
    _stackSize.height = height;
    NSEnumerator *enumerator = [[self children] objectEnumerator];
    id card;
    while ((card = [enumerator nextObject]) != nil)
        [(id<HSMutableSizeAttributes>)[card queryHyperInterface:@protocol(HSMutableSizeAttributes)] setSize:_stackSize];
    [self notifyChange:2 ofAttribute:@protocol(HSStackCardSizeAttribute) withUserInfo:nil];
}

- (NSSize)hyperCardSize
{
    if (NSEqualSizes(_stackSize, NSZeroSize))
        _stackSize = NSMakeSize(640.0, 480.0);
    return _stackSize;
}

- (id)childWrapperExtension
{
    return @"hscard";
}

// The document's current card, else the first.
- (id)card
{
    id card = [[self document] currentCard];
    if (card == nil && [self hyperCount] != 0)
        card = [self hyperChildAtIndex:0];
    return card;
}

- (id)stack
{
    return self;
}

- (id)posterCard
{
    return [self hyperChildAtIndex:0];
}

- (void)insertChild:(id)aChild atIndex:(NSUInteger)aIndex
{
    [(id<HSMutableSizeAttributes>)[aChild queryHyperInterface:@protocol(HSMutableSizeAttributes)] setSize:[self hyperCardSize]];
    [super insertChild:aChild atIndex:aIndex];
}

- (void)justInsertHyperChildren:(id)aChildren atIndexes:(id)aIndexes
{
    if ([aChildren count] != 0 && [aChildren count] == [aIndexes count])
        [super justInsertHyperChildren:aChildren atIndexes:aIndexes];
}

// The original did not release the background, the guidelines settings or
// the card UID; released here.
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_password release];
    [_recentPassword release];
    [_webAppIconMedia release];
    [_stackCompression release];
    [_gridSettings release];
    [_layoutGrid release];
    [_testingFunctionsManager release];
    [_cardGroups release];
    [_cardGroupController setOwner:nil];
    [_cardGroupController release];
    [_hiddenInPlayerObjects release];
    [_playedInPlayerMovieObjects release];
    [_temporaryObjects release];
    [_guidelinesSettings setUndoManager:nil];
    [_guidelinesSettings release];
    [_cardWithVisibleMenuBarUID release];
    [_background setHyperOwner:nil];
    [_background release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _stackSize = [[self class] newStackCardSize];
        if (NSEqualSizes(_stackSize, NSZeroSize))
            _stackSize = [HSUserObjectDefaultAttributesProvider defaultCardSize];
        _cardGroups = [NSMutableArray new];
        _cardGroupController = [HSCardGroupController new];
        [_cardGroupController setOwner:self];
        _presentationFlags.menuVisible = 1;
    }
    return self;
}

- (id)allActionsOfType:(id)aType shouldLoadChildren:(BOOL)aLoad
{
    if (aType == nil) {
        return nil;
    }
    id links = [[self queryHyperInterface:@protocol(HSHypertextLinkContainerAttributes)] allLinks];
    id enumerator = aLoad ? [self hyperDeepEnumerator] : [self hyperDeepLoadedNodeEnumerator];
    NSMutableArray *objects = [NSMutableArray arrayWithArray:[enumerator allObjects]];
    if ([links count] != 0) {
        [objects addObjectsFromArray:links];
    }
    NSMutableSet *result = [NSMutableSet set];
    [objects enumerateObjectsUsingBlock:^(id aObject, NSUInteger aIndex, BOOL *aStop) {
        [[[aObject queryHyperInterface:@protocol(HSActor)] hyperActions] enumerateObjectsUsingBlock:^(id aAction, NSUInteger aActionIndex, BOOL *aActionStop) {
            id action = [aAction queryHyperInterface:aType];
            if (action != nil) {
                [result addObject:action];
            }
        }];
    }];
    return result;
}

- (id)defaultWebAppIcon
{
    NSImage *image = [[[self children] extraFirstObject] imageWithVisualizationProtocol:@protocol(HSPlayerVisualization)];
    NSSize size = [image size];
    if (size.width == size.height) {
        return image;
    }
    NSPoint offset = NSZeroPoint;
    CGFloat side = size.width;
    if (size.width <= size.height) {
        offset.y = (size.height - size.width) * 0.5;
    } else {
        offset.x = (size.width - size.height) * 0.5;
        side = size.height;
    }
    NSImage *square = [[[NSImage alloc] initWithSize:NSMakeSize(side, side)] autorelease];
    [square lockFocus];
    [image drawAtPoint:NSZeroPoint fromRect:NSMakeRect(offset.x, offset.y, side, side) operation:NSCompositeSourceOver fraction:1.0];
    [square unlockFocus];
    return square;
}

- (id)ownedMediaUIDs
{
    if ([self webAppIconMediaUID] == nil) {
        return nil;
    }
    return [NSCountedSet setWithObject:[self webAppIconMediaUID]];
}

- (void)setShouldHomeStackOpenInSeparateWindow:(BOOL)aOpen
{
    if (aOpen != _shouldHomeStackOpenInSeparateWindow) {
        [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Checkbox Selection" value:@"" table:@"UndoManager"]];
        [[[self undoManager] prepareWithInvocationTarget:self] setShouldHomeStackOpenInSeparateWindow:_shouldHomeStackOpenInSeparateWindow];
        [self notifyChange:1 ofAttribute:@protocol(HSHomeStackOpenInSeparateWindowAttribute) withUserInfo:nil];
        _shouldHomeStackOpenInSeparateWindow = aOpen;
        [self notifyChange:2 ofAttribute:@protocol(HSHomeStackOpenInSeparateWindowAttribute) withUserInfo:nil];
    }
}

- (BOOL)shouldHomeStackOpenInSeparateWindow
{
    return _shouldHomeStackOpenInSeparateWindow;
}

- (void)setShouldSaveChangesMadeInBrowseMode:(BOOL)aSave
{
    if (_presentationFlags.shouldSaveChangesMadeInBrowseMode != aSave) {
        [self notifyChange:1 ofAttribute:@protocol(HSStackPresentationModeAttributes) withUserInfo:nil];
        [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Player View Settings" value:@"" table:@"UndoManager"]];
        [[[self undoManager] prepareWithInvocationTarget:self] setShouldSaveChangesMadeInBrowseMode:_presentationFlags.shouldSaveChangesMadeInBrowseMode];
        _presentationFlags.shouldSaveChangesMadeInBrowseMode = aSave;
        [self notifyChange:2 ofAttribute:@protocol(HSStackPresentationModeAttributes) withUserInfo:nil];
    }
}

- (BOOL)shouldSaveChangesMadeInBrowseMode
{
    return _presentationFlags.shouldSaveChangesMadeInBrowseMode;
}

- (void)setWebAppIcon:(id)aIcon
{
    if ([self webAppIcon] != aIcon) {
        [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Edit Web App Icon" value:@"" table:@"UndoManager"]];
        [[self undoManager] registerUndoWithTarget:self selector:@selector(setWebAppIcon:) object:[self webAppIcon]];
        [self setWebAppIconMedia:[HSNewMedia mediaWithImage:aIcon]];
    }
}

- (void)setWebAppIconMedia:(id)aMedia
{
    if (_webAppIconMedia != aMedia) {
        [_webAppIconMedia release];
        _webAppIconMedia = [aMedia retain];
    }
}

- (id)webAppIconMedia
{
    return _webAppIconMedia;
}

- (void)setWebAppIconMediaUID:(id)aUID
{
    id media = [[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:aUID];
    if ([[media imageRepresentation] image] == nil) {
        media = [HSNewMedia mediaWithImage:[[[NSImage alloc] initWithData:[media mediaData]] autorelease]];
    }
    [self setWebAppIconMedia:media];
}

- (id)webAppIconMediaUID
{
    return [[self webAppIconMedia] mediaUID];
}

- (id)webAppIcon
{
    id image = [[[self webAppIconMedia] imageRepresentation] image];
    if (image == nil) {
        image = [self defaultWebAppIcon];
    }
    return image;
}

- (void)stopPlayingTemporaryObjects
{
    for (id object in [self temporaryObjects]) {
        id playable = [object queryHyperInterface:@protocol(HSPlayableObjectAttributes)];
        if ([playable isHyperPlaying]) {
            [playable hyperStop];
        }
    }
}

- (void)verifyUnsupportedFeatures
{
    [[self undoManager] disableUndoRegistration];
    [[self queryHyperInterface:@protocol(HSActor)] setHyperActions:nil];
    [self setPresentationCoveringDesktopMode:NO];
    [self setPresentationPlaysWithoutTitleBar:NO];
    [self setPresentationMenuVisible:YES];
    [self setShouldPlayInFullScreen:NO];
    [self setShouldHomeStackOpenInSeparateWindow:NO];
    id cursorAttributes = [self queryHyperInterface:@protocol(HSCursorAttributes)];
    if ([[cursorAttributes hyperCursor] imageMedia] != nil) {
        [cursorAttributes setHyperCursor:nil];
    }
    [[self undoManager] enableUndoRegistration];
    [super verifyUnsupportedFeatures];
}

@end

@implementation HSStack (HSValueConstraint)

- (id)hyperCountMinValue
{
    return [NSNumber numberWithUnsignedInt:1];
}

- (id)hyperCountMaxValue
{
    return [NSNumber numberWithUnsignedInt:0x7fffffff];
}

@end

@implementation HSStack (HSReadyMadeCardsSupport)

// A new card with the pasted image as its background, named after the
// pasted file (or the image). Images taller than the card are fitted.
- (BOOL)insertNewCardWithBackgroundFromPasteboard:(id)aPasteboard atIndex:(NSUInteger)aIndex
{
    NSImage *image = [[NSImage alloc] initWithPasteboard:aPasteboard];
    if (image == nil)
        return NO;
    id card = [HSCard defaultObject];
    NSString *title;
    if ([aPasteboard availableTypeFromArray:[NSArray arrayWithObject:NSFilenamesPboardType]] != nil)
        title = [[[[aPasteboard propertyListForType:NSFilenamesPboardType] extraFirstObject] lastPathComponent] stringByDeletingPathExtension];
    else
        title = [image name];
    if (title != nil) {
        [[self undoManager] disableUndoRegistration];
        [card setHyperTitle:title];
        [[self undoManager] enableUndoRegistration];
    }
    [self insertHyperChild:card atIndex:aIndex];
    [card hyperRefreshTitle];
    float imageHeight = (float)[image hyperPixelsSize].height;
    float cardHeight = (float)[self hyperCardSize].height;
    [card importBackgroundFromImage:image imageScalingOption:!(imageHeight > cardHeight) ? 4 : 2 eraseBackground:YES];
    [image release];
    return YES;
}

// A new stack takes the card size of the pasted cards.
- (id)insertCardsFromPasteboard:(id)aPasteboard atIndex:(NSUInteger)aIndex
{
    NSDictionary *serialized = [aPasteboard propertyListForType:@"HSCardPasteboardType"];
    id cardDictionaries = [serialized objectForKey:@"HSSerializedCardsKey"];
    NSSet *mediaUIDs = [NSSet setWithArray:[[serialized objectForKey:@"HSSerializedCardsMediaUIDsKey"] extraArrayFromPlistRepresentation]];
    NSSet *groupObjectUIDs = [NSSet setWithArray:[[serialized objectForKey:@"HSSerializedGroupObjectsUIDsKey"] extraArrayFromPlistRepresentation]];
    NSSet *unrefreshingUIDs = [NSSet setWithArray:[[serialized objectForKey:@"HSSerializedUnrefreshingUIDs"] extraArrayFromPlistRepresentation]];
    NSMutableSet *ignoredUIDs = [NSMutableSet setWithSet:mediaUIDs];
    [ignoredUIDs unionSet:groupObjectUIDs];
    [ignoredUIDs unionSet:[self removeUIDsOfCopiedObjectsInCardsDictionaries:cardDictionaries fromUnrefreshingUIDs:unrefreshingUIDs]];
    NSDictionary *objects = [self retrieveObjectsFromCardsDictionaries:cardDictionaries UIDsToIgnore:ignoredUIDs];
    if ([[self document] isNewAndNotChanged] && [[objects objectForKey:@"cardsToAdd"] count] != 0) {
        NSSize size = [[[objects objectForKey:@"cardsToAdd"] objectAtIndex:0] imageRect].size;
        if (!NSEqualSizes(size, NSZeroSize))
            [self setHyperCardSize:size];
    }
    [self insertCards:[objects objectForKey:@"cardsToAdd"] withCardGroups:[objects objectForKey:@"cardGroupsToAdd"] atIndex:aIndex];
    return [NSArray arrayWithArray:[objects objectForKey:@"cardsToAdd"]];
}

- (id)insertCards:(id)aCards atIndex:(NSInteger)aIndex
{
    id cardDictionaries = [aCards objectForKey:@"HSSerializedCardsKey"];
    NSSet *mediaUIDs = [NSSet setWithArray:[[aCards objectForKey:@"HSSerializedCardsMediaUIDsKey"] extraArrayFromPlistRepresentation]];
    NSSet *groupObjectUIDs = [NSSet setWithArray:[[aCards objectForKey:@"HSSerializedGroupObjectsUIDsKey"] extraArrayFromPlistRepresentation]];
    NSSet *unrefreshingUIDs = [NSSet setWithArray:[[aCards objectForKey:@"HSSerializedUnrefreshingUIDs"] extraArrayFromPlistRepresentation]];
    NSMutableSet *ignoredUIDs = [NSMutableSet setWithSet:mediaUIDs];
    [ignoredUIDs unionSet:groupObjectUIDs];
    [ignoredUIDs unionSet:[self removeUIDsOfCopiedObjectsInCardsDictionaries:cardDictionaries fromUnrefreshingUIDs:unrefreshingUIDs]];
    NSDictionary *objects = [self retrieveObjectsFromCardsDictionaries:cardDictionaries UIDsToIgnore:ignoredUIDs];
    [self insertCards:[objects objectForKey:@"cardsToAdd"] withCardGroups:[objects objectForKey:@"cardGroupsToAdd"] atIndex:aIndex];
    return [NSArray arrayWithArray:[objects objectForKey:@"cardsToAdd"]];
}

// The pasted cards themselves get new UIDs.
- (id)removeUIDsOfCopiedObjectsInCardsDictionaries:(id)aDictionaries fromUnrefreshingUIDs:(id)aDs
{
    NSMutableSet *UIDs = [[aDs mutableCopy] autorelease];
    for (id dictionary in aDictionaries) {
        NSString *UIDString = [[[dictionary objectForKey:HSLocalNodeDataKey] objectForKey:@"UID"] objectForKey:@"stringValue"];
        if (UIDString != nil)
            [UIDs removeObject:[HSUID UIDWithString:UIDString]];
    }
    return UIDs;
}

// Cards of a group with a single pasted card only rejoin a group that is
// still there.
- (void)insertCards:(id)aCards withCardGroups:(id)aGroups atIndex:(NSInteger)aIndex
{
    if ([aCards count] == 0)
        return;
    NSEnumerator *enumerator = [aCards objectEnumerator];
    id delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(nodeContainerAddChildrenBeginGrouping:)])
        [delegate nodeContainerAddChildrenBeginGrouping:self];
    id card;
    while ((card = [enumerator nextObject]) != nil) {
        id groupUID = [[[card cardGroupUID] retain] autorelease];
        [card setCardGroupUID:nil];
        if (groupUID != nil) {
            if ([[aGroups objectForKey:groupUID] count] >= 2 || [[self cardGroupController] cardGroupWithUID:groupUID] != nil)
                [[self cardGroupController] makeGroupCard:card groupUID:groupUID];
        }
        [self insertHyperChild:card atIndex:aIndex];
        aIndex++;
    }
    if ([delegate respondsToSelector:@selector(nodeContainerAddChildrenEndGrouping:)])
        [delegate nodeContainerAddChildrenEndGrouping:self];
}

// The cards (with refreshed UIDs) and, per group UID, the UIDs of its cards.
- (id)retrieveObjectsFromCardsDictionaries:(id)aDictionaries UIDsToIgnore:(id)aIgnore
{
    NSEnumerator *enumerator = [aDictionaries objectEnumerator];
    NSMutableArray *cards = [NSMutableArray arrayWithCapacity:[aDictionaries count]];
    NSMutableDictionary *groups = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary *replacedUIDs = [NSMutableDictionary new];
    id cardDictionary;
    while ((cardDictionary = [enumerator nextObject]) != nil) {
        NSMutableDictionary *dictionary = [[cardDictionary mutableCopy] autorelease];
        id groupUID = nil;
        if ([dictionary objectForKey:@"cardGroupUID"] != nil)
            groupUID = [NSObject objectWithExtraDictionary:[dictionary objectForKey:@"cardGroupUID"]];
        [dictionary refreshHyperUIDsWithReplacedUIDs:replacedUIDs ignoreUIDs:aIgnore];
        id card = [HSCard nodeWithDictionary:dictionary];
        [card setCardGroupUID:groupUID];
        [cards addObject:card];
        if (groupUID != nil) {
            NSMutableArray *groupCards = [groups objectForKey:groupUID];
            if (groupCards == nil) {
                groupCards = [NSMutableArray array];
                [groups setObject:groupCards forKey:groupUID];
            }
            [groupCards addObject:[card hyperUID]];
        }
    }
    [replacedUIDs release];
    return [NSDictionary dictionaryWithObjectsAndKeys:cards, @"cardsToAdd", groups, @"cardGroupsToAdd", nil];
}

@end
