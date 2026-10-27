#import "HSShowHideObjectAction.h"
#import "EXCodingContext.h"
#import "HSActionExecutionContext.h"
#import "HSActionMediaPlayer.h"
#import "HSDocument.h"
#import "HSExecutableResourceProvider.h"
#import "HSFunctions.h"
#import "HSNavigationController.h"
#import "HSNavigationOperation.h"
#import "HSQTTransition.h"
#import "HSTransitionEffectProvider.h"
#import "HSUID.h"
#import "NSMutableArray+EXMutableArray.h"

// Shows, hides or toggles card objects, optionally with a transition. The map
// goes from object UID to a dictionary holding the visibility action (1 show,
// 2 hide, 3 toggle) and the show/hide transition settings.
@implementation HSShowHideObjectAction

- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    [super importFromXMLElementRepresentation:aRepresentation inContext:aContext];
    NSEnumerator *enumerator = [[aRepresentation elementsForName:@"showHideObject"] objectEnumerator];
    NSXMLElement *element;
    while ((element = [enumerator nextObject]) != nil) {
        NSString *string = [[element attributeForName:@"uid"] stringValue];
        if (string == nil)
            continue;
        HSUID *uid = [HSUID UIDWithString:string];
        if (uid == nil)
            continue;
        id showSettings = nil;
        id hideSettings = nil;
        NSXMLElement *transition = [(NSMutableArray *)[element elementsForName:@"transition"] extraFirstObject];
        if (transition != nil) {
            NSXMLElement *settings = [(NSMutableArray *)[transition elementsForName:@"showSettings"] extraFirstObject];
            if (settings != nil)
                showSettings = [self importXMLTransitionSettingsFromElement:settings];
            settings = [(NSMutableArray *)[transition elementsForName:@"hideSettings"] extraFirstObject];
            if (settings != nil)
                hideSettings = [self importXMLTransitionSettingsFromElement:settings];
        }
        NSInteger action = [self visibilityActionTypeFromString:[[element attributeForName:@"actionType"] stringValue]];
        [self addObjectUID:uid action:action showEffectSettings:showSettings hideEffectSettings:hideSettings];
    }
}

- (id)importXMLTransitionSettingsFromElement:(id)aElement
{
    NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithCapacity:2];
    if ([[aElement attributes] count] != 0) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSString *name = [[aElement attributeForName:@"name"] stringValue];
        if (name != nil)
            [settings setObject:name forKey:@"HSShowHideTransitionName"];
        NSNumber *duration = [NSNumber numberWithDouble:[[[aElement attributeForName:@"duration"] stringValue] doubleValue]];
        if (duration != nil)
            [settings setObject:duration forKey:@"HSShowHideTransitionDuration"];
        [pool release];
    }
    return [[settings copy] autorelease];
}

- (id)XMLElementRepresentationInContext:(id)aContext
{
    NSXMLElement *representation = [super XMLElementRepresentationInContext:aContext];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSDictionary *map = [self objectUIDsToActionMap];
    NSEnumerator *enumerator = [map keyEnumerator];
    HSUID *uid;
    while ((uid = [enumerator nextObject]) != nil) {
        NSXMLElement *element = [NSXMLElement elementWithName:@"showHideObject"];
        [element addAttribute:[NSXMLNode attributeWithName:@"uid" stringValue:[uid stringValue]]];
        int action = [[[map objectForKey:uid] objectForKey:@"HSVisibilityAction"] intValue];
        if (action != 0) {
            [element addAttribute:[NSXMLNode attributeWithName:@"actionType" stringValue:[self visibilityActionTypeToString:action]]];
            NSXMLElement *transition = [NSXMLElement elementWithName:@"transition"];
            NSXMLElement *settings = [self XMLTransitionElementForName:@"showSettings" WithSettings:[self showEffectSettingsWithUID:uid]];
            if ([[settings attributes] count] != 0)
                [transition addChild:settings];
            settings = [self XMLTransitionElementForName:@"hideSettings" WithSettings:[self hideEffectSettingsWithUID:uid]];
            if ([[settings attributes] count] != 0)
                [transition addChild:settings];
            if (transition != nil && [transition childCount] != 0)
                [element addChild:transition];
        }
        [representation addChild:element];
    }
    [pool release];
    return representation;
}

- (id)XMLTransitionElementForName:(id)aName WithSettings:(id)aSettings
{
    NSXMLElement *element = [NSXMLElement elementWithName:aName];
    if (aSettings != nil && [aSettings count] != 0) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSString *name = [aSettings objectForKey:@"HSShowHideTransitionName"];
        if (name != nil)
            [element addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:name]];
        NSNumber *duration = [aSettings objectForKey:@"HSShowHideTransitionDuration"];
        if (duration != nil)
            [element addAttribute:[NSXMLNode attributeWithName:@"duration" stringValue:[NSString stringWithFormat:@"%.3f", [duration doubleValue]]]];
        [pool release];
    }
    return element;
}

- (NSInteger)visibilityActionTypeFromString:(id)aString
{
    if ([aString isEqualToString:@"showEffect"])
        return 1;
    if ([aString isEqualToString:@"hideEffect"])
        return 2;
    return [aString isEqualToString:@"toggleEffect"] ? 3 : 0;
}

- (id)visibilityActionTypeToString:(NSInteger)aString
{
    switch (aString) {
    case 1:
        return @"showEffect";
    case 2:
        return @"hideEffect";
    case 3:
        return @"toggleEffect";
    default:
        return nil;
    }
}

- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}

- (id)XMLElementName
{
    return @"actShowHideObject";
}

- (BOOL)supportedInIPad
{
    return YES;
}

- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}

static NSString *HSShowHideHTML5Duration(NSDictionary *aSettings)
{
    NSNumber *duration = [aSettings objectForKey:@"HSShowHideTransitionDuration"];
    if (duration == nil)
        duration = [NSNumber numberWithDouble:0];
    return [NSString stringWithFormat:@"%@", duration];
}

static NSString *HSShowHideHTML5Effect(NSDictionary *aSettings)
{
    NSString *name = [aSettings objectForKey:@"HSShowHideTransitionName"];
    if (name == nil)
        name = @"No Transition";
    return [HSTransitionEffectProvider exportTransitionNameForTransitionName:name];
}

- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    if (![self isValid])
        return nil;
    NSMutableDictionary *representation = [super HTML5DictionaryRepresentationInContext:aContext];
    [representation setObject:@"HSHideShowAction" forKey:@"type"];
    [representation setObject:[NSString stringWithFormat:@"%i", (int)[_objectUIDsToActionMap count]] forKey:@"count"];
    NSMutableArray *objects = [NSMutableArray new];
    for (HSUID *uid in _objectUIDsToActionMap) {
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        NSDictionary *entry = [[self objectUIDsToActionMap] objectForKey:uid];
        int action = [[entry objectForKey:@"HSVisibilityAction"] intValue];
        if (action != 0) {
            NSMutableDictionary *object = [NSMutableDictionary new];
            [object setObject:[uid stringValue] forKey:@"object"];
            [object setObject:[NSString stringWithFormat:@"%i", action] forKey:@"mode"];
            NSDictionary *settings = [entry objectForKey:@"HSShowEffectSettings"];
            [object setObject:HSShowHideHTML5Effect(settings) forKey:@"showEffect"];
            [object setObject:HSShowHideHTML5Duration(settings) forKey:@"showDuration"];
            settings = [entry objectForKey:@"HSHideEffectSettings"];
            [object setObject:HSShowHideHTML5Effect(settings) forKey:@"hideEffect"];
            [object setObject:HSShowHideHTML5Duration(settings) forKey:@"hideDuration"];
            [objects addObject:object];
            [object release];
        }
        [pool release];
    }
    [representation setObject:objects forKey:@"objects"];
    [objects release];
    return representation;
}

- (id)HTML5UnsupportedFeaturesForDocumentType:(id)aType
{
    NSSet *names = nil;
    [self hasUnsupportedTransitionNames:&names];
    NSMutableSet *features = [NSMutableSet set];
    for (NSString *name in names) {
        NSString *format = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSHTML5UnsupportedFeatureTransition" value:@"" table:@"Export"];
        [features addObject:[NSString stringWithFormat:format, name]];
    }
    return features;
}

- (BOOL)hasUnsupportedHTML5FeaturesForDocumentType:(id)aType
{
    return [[self unsupportedTransitions] count] != 0;
}

// With aNames NULL this returns at the first unsupported name.
- (BOOL)isValid
{
    return [[_objectUIDsToActionMap allValues] count] != 0;
}

- (void)notifyDidFinish
{
    [_context release];
    _context = nil;
    [super notifyDidFinish];
}

- (void)HSShowHideObjectAction_stopShowHideTransitionForObject:(id)aObject
{
    id<HSMutableShowHideTransitionAttributes> attributes = [aObject queryHyperInterface:@protocol(HSMutableShowHideTransitionAttributes)];
    if (attributes != nil && [attributes transition] != nil)
        [attributes setTransition:nil];
}

- (void)stop:(id)aStop
{
    if (_runningCount == 0)
        return;
    NSArray *lists[3] = { [self objectsToShow], [self objectsToHide], [self objectsToToggle] };
    for (int i = 0; i < 3; i++) {
        NSEnumerator *enumerator = [lists[i] objectEnumerator];
        HSUID *uid;
        while ((uid = [enumerator nextObject]) != nil) {
            id object = [self objectForUID:uid];
            if (object != nil)
                [self HSShowHideObjectAction_stopShowHideTransitionForObject:object];
        }
    }
    [super stop:aStop];
}

- (BOOL)canBeStopped
{
    return YES;
}

// Action 0 removes the object from the map.
- (void)addObjectUID:(id)aUID action:(NSInteger)aAction showEffectSettings:(id)aSettings hideEffectSettings:(id)aSettings2
{
    NSMutableDictionary *entry = [[self objectUIDsToActionMap] objectForKey:aUID];
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Change Object Visibility Action" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] addObjectUID:aUID action:[self actionForObjectWithUID:aUID] showEffectSettings:[entry objectForKey:@"HSShowEffectSettings"] hideEffectSettings:[entry objectForKey:@"HSHideEffectSettings"]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSShowHideObjectsAttribute) ofObject:self withUserInfo:nil];
    if (aAction == 0) {
        [[self objectUIDsToActionMap] removeObjectForKey:aUID];
    } else {
        if (entry == nil) {
            entry = [NSMutableDictionary dictionary];
            [[self objectUIDsToActionMap] setObject:entry forKey:aUID];
        }
        [entry setObject:[NSNumber numberWithInt:(int)aAction] forKey:@"HSVisibilityAction"];
        if (aSettings != nil)
            [entry setObject:aSettings forKey:@"HSShowEffectSettings"];
        else
            [entry removeObjectForKey:@"HSShowEffectSettings"];
        if (aSettings2 != nil)
            [entry setObject:aSettings2 forKey:@"HSHideEffectSettings"];
        else
            [entry removeObjectForKey:@"HSHideEffectSettings"];
    }
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSShowHideObjectsAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}

- (id)hideEffectSettingsWithUID:(id)aUID
{
    return [[[self objectUIDsToActionMap] objectForKey:aUID] objectForKey:@"HSHideEffectSettings"];
}

- (id)showEffectSettingsWithUID:(id)aUID
{
    return [[[self objectUIDsToActionMap] objectForKey:aUID] objectForKey:@"HSShowEffectSettings"];
}

- (NSInteger)actionForObjectWithUID:(id)aUID
{
    return [[[[self objectUIDsToActionMap] objectForKey:aUID] objectForKey:@"HSVisibilityAction"] intValue];
}

- (id)objectsToToggle
{
    return [self objectsWithAction:3];
}

- (id)objectsToHide
{
    return [self objectsWithAction:2];
}

- (id)objectsToShow
{
    return [self objectsWithAction:1];
}

- (id)objectsWithAction:(NSInteger)aAction
{
    NSMutableArray *objects = [NSMutableArray array];
    NSDictionary *map = [self objectUIDsToActionMap];
    NSEnumerator *enumerator = [map keyEnumerator];
    HSUID *uid;
    while ((uid = [enumerator nextObject]) != nil) {
        if ([[[map objectForKey:uid] objectForKey:@"HSVisibilityAction"] intValue] == aAction)
            [objects addObject:uid];
    }
    return objects;
}

// Balances the retain and running count taken when the transition started.
- (void)HSShowHideObjectAction_transitionDidFinish:(id)aFinish
{
    id attributes = [[aFinish object] queryHyperInterface:@protocol(HSMutableShowHideTransitionAttributes)];
    [[attributes attributeObservingController] removeObserver:self selector:@selector(HSShowHideObjectAction_transitionDidFinish:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSShowHideTransitionAttribute)];
    if (--_runningCount == 0)
        [self notifyDidFinish];
    [self release];
}

// The original ignores aFinish; the object is hidden before the transition runs.
- (void)HSShowHideObjectAction_runShowHideTransitionForObject:(id)aObject transitionAttributes:(id)aAttributes transitionSettings:(id)aSettings hideOnFinish:(BOOL)aFinish
{
    if (aSettings == nil || aObject == nil || aAttributes == nil)
        return;
    NSString *name = [aSettings objectForKey:@"HSShowHideTransitionName"];
    if (name == nil)
        return;
    NSNumber *durationNumber = [aSettings objectForKey:@"HSShowHideTransitionDuration"];
    if (durationNumber == nil)
        return;
    double duration = [durationNumber doubleValue];
    if (duration == 0.0)
        return;
    HSTransition *transition = [HSTransition transitionWithName:name];
    if (transition == nil)
        return;
    [transition setDuration:duration];
    [aAttributes setTransition:transition];
    if ([aAttributes transition] != nil) {
        [[aAttributes attributeObservingController] addObserver:self selector:@selector(HSShowHideObjectAction_transitionDidFinish:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSShowHideTransitionAttribute) withPriority:0.25f];
        _runningCount++;
        [self retain];
    }
}

// Returns retained transition attributes with any running transition cleared.
// Effect type 0 needs show settings, 1 hide settings, -1 none.
- (id)HSShowHideObjectAction_copyShowHideTransitionAttributesForObject:(id)aObject effectType:(NSInteger)aType settings:(id *)aSettings
{
    id settings = nil;
    if (aType == 0)
        settings = [self showEffectSettingsWithUID:[aObject hyperUID]];
    else if (aType == 1)
        settings = [self hideEffectSettingsWithUID:[aObject hyperUID]];
    if (settings == nil && aType != -1)
        return nil;
    id attributes = [aObject queryHyperInterface:@protocol(HSMutableShowHideTransitionAttributes)];
    if (attributes != nil) {
        [attributes retain];
        if (aSettings != NULL)
            *aSettings = settings;
        if ([attributes transition] != nil)
            [attributes setTransition:nil];
    }
    return attributes;
}

// Stages 13 and 14 end the arrival transition.
- (void)navigationOperationStageDidChange:(id)aChange
{
    HSNavigationOperation *operation = [aChange object];
    if ([operation stage] != 13 && [operation stage] != 14)
        return;
    [self startAction];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSNavigationOperationStageDidChangeNotification" object:operation];
    [_navigationOperation release];
    _navigationOperation = nil;
}

// On arrival at this card while the navigation is still at stage 12, the
// action waits for the navigation to finish.
- (void)startInContext:(id)aContext
{
    [_context release];
    _context = [aContext retain];
    HSNavigationOperation *operation = [[aContext navigationController] currentNavigationOperation];
    if ([[[[self events] lastObject] eventType] isEqual:kHSArriveActionEventType] && [operation stage] == 12 && [operation sourceCard] == [self card]) {
        [_navigationOperation release];
        _navigationOperation = [[[aContext navigationController] currentNavigationOperation] retain];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navigationOperationStageDidChange:) name:@"HSNavigationOperationStageDidChangeNotification" object:_navigationOperation];
        return;
    }
    [self startAction];
}

- (void)startAction
{
    id settings = nil;
    NSEnumerator *enumerator = [[self objectsToShow] objectEnumerator];
    HSUID *uid;
    while ((uid = [enumerator nextObject]) != nil) {
        id object = [self objectForUID:uid];
        if (![object isHiddenInPlayer])
            continue;
        [self showCardObject:object];
        id attributes = [self HSShowHideObjectAction_copyShowHideTransitionAttributesForObject:object effectType:0 settings:&settings];
        if (attributes != nil) {
            [self HSShowHideObjectAction_runShowHideTransitionForObject:object transitionAttributes:attributes transitionSettings:settings hideOnFinish:NO];
            [attributes release];
        }
    }
    enumerator = [[self objectsToHide] objectEnumerator];
    while ((uid = [enumerator nextObject]) != nil) {
        id object = [self objectForUID:uid];
        if ([object isHiddenInPlayer])
            continue;
        [self hideCardObject:object];
        id attributes = [self HSShowHideObjectAction_copyShowHideTransitionAttributesForObject:object effectType:1 settings:&settings];
        if (attributes != nil) {
            if ([_context activeTextField] == object)
                [_context deactivateActiveTextField];
            [self HSShowHideObjectAction_runShowHideTransitionForObject:object transitionAttributes:attributes transitionSettings:settings hideOnFinish:YES];
            [attributes release];
        } else {
            // The original hides the object a second time when it has no transition.
            [self hideCardObject:object];
        }
    }
    enumerator = [[self objectsToToggle] objectEnumerator];
    while ((uid = [enumerator nextObject]) != nil) {
        id object = [self objectForUID:uid];
        id attributes = [self HSShowHideObjectAction_copyShowHideTransitionAttributesForObject:object effectType:-1 settings:NULL];
        if ([object isHiddenInPlayer]) {
            [self showCardObject:object];
            if (attributes == nil)
                continue;
            [self HSShowHideObjectAction_runShowHideTransitionForObject:object transitionAttributes:attributes transitionSettings:[self showEffectSettingsWithUID:uid] hideOnFinish:NO];
        } else {
            [self hideCardObject:object];
            if (attributes == nil)
                continue;
            if ([_context activeTextField] == object)
                [_context deactivateActiveTextField];
            [self HSShowHideObjectAction_runShowHideTransitionForObject:object transitionAttributes:attributes transitionSettings:[self hideEffectSettingsWithUID:uid] hideOnFinish:YES];
        }
        [attributes release];
    }
    if (_runningCount == 0)
        [self notifyDidFinish];
}

- (void)showCardObject:(id)aObject
{
    [aObject setHiddenInPlayer:NO];
    id movie = [aObject queryHyperInterface:@protocol(HSMovieObjectAttributes)];
    if (movie != nil && ![movie isHyperPlaying])
        [[HSActionMediaPlayer sharedActionMediaPlayer] playMovie:movie movieOwner:nil];
}

- (void)hideCardObject:(id)aObject
{
    [aObject setHiddenInPlayer:YES];
    id movie = [aObject queryHyperInterface:@protocol(HSMovieObjectAttributes)];
    if (movie != nil && [movie isHyperPlaying])
        [movie hyperStop];
}

- (id)objectForUID:(id)aUID
{
    id object = [[[self stack] queryHyperInterface:@protocol(HSUserObjectUIDBasedAccess)] childInTreeWithUID:aUID];
    return [object queryHyperInterface:@protocol(HSMutableCardObjectAttributes)];
}

// Merging another action's objects into this one, for an image that replaces
// the objects in aDs. The highest-priority show and hide of a replaced object
// become the image's own action.
- (void)mergeInShowHideObjectAction:(id)aAction replacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID
{
    NSMutableSet *showSet = [NSMutableSet setWithArray:[self objectsToShow]];
    NSMutableSet *hideSet = [NSMutableSet setWithArray:[self objectsToHide]];
    // The original builds the toggle set from objectsToHide as well.
    NSMutableSet *toggleSet = [NSMutableSet setWithArray:[self objectsToHide]];
    NSMutableSet *allObjects = [NSMutableSet setWithSet:hideSet];
    [allObjects unionSet:showSet];
    [allObjects unionSet:toggleSet];
    BOOL hasImage = [allObjects containsObject:aUID];
    [allObjects unionSet:aDs];
    NSSet *otherShow = [NSSet setWithArray:[aAction objectsToShow]];
    NSSet *otherHide = [NSSet setWithArray:[aAction objectsToHide]];
    NSSet *otherToggle = [NSSet setWithArray:[aAction objectsToToggle]];

    if (!hasImage) {
        id lastShow = nil;
        id lastHide = nil;
        for (id uid in aPriority) {
            if ([otherToggle containsObject:uid]) {
                [self addObjectUID:aUID action:3 showEffectSettings:[aAction showEffectSettingsWithUID:uid] hideEffectSettings:[aAction hideEffectSettingsWithUID:uid]];
                break;
            }
            if ([otherShow containsObject:uid]) {
                if (lastHide != nil) {
                    [self addObjectUID:aUID action:3 showEffectSettings:[aAction showEffectSettingsWithUID:uid] hideEffectSettings:[aAction hideEffectSettingsWithUID:lastHide]];
                    lastHide = nil;
                    break;
                }
                lastShow = uid;
            } else if ([otherHide containsObject:uid]) {
                if (lastShow != nil) {
                    // fixed: the original took the show settings from this
                    // hidden object and the hide settings from the (nil)
                    // previous hide.
                    [self addObjectUID:aUID action:3 showEffectSettings:[aAction showEffectSettingsWithUID:lastShow] hideEffectSettings:[aAction hideEffectSettingsWithUID:uid]];
                    lastShow = nil;
                    break;
                }
                lastHide = uid;
            }
        }
        // A toggle found above is overwritten when a show or hide preceded it.
        if (lastShow != nil)
            [self addObjectUID:aUID action:1 showEffectSettings:[aAction showEffectSettingsWithUID:lastShow] hideEffectSettings:[aAction hideEffectSettingsWithUID:lastShow]];
        else if (lastHide != nil)
            [self addObjectUID:aUID action:2 showEffectSettings:[aAction showEffectSettingsWithUID:lastHide] hideEffectSettings:[aAction hideEffectSettingsWithUID:lastHide]];
    }

    for (id uid in otherShow) {
        if ([aDs containsObject:uid] || [showSet containsObject:uid] || [toggleSet containsObject:uid])
            continue;
        if ([hideSet containsObject:uid]) {
            [self addObjectUID:uid action:3 showEffectSettings:[aAction showEffectSettingsWithUID:uid] hideEffectSettings:[self hideEffectSettingsWithUID:uid]];
            [toggleSet addObject:uid];
            [hideSet removeObject:uid];
        } else {
            [self addObjectUID:uid action:1 showEffectSettings:[aAction showEffectSettingsWithUID:uid] hideEffectSettings:[aAction hideEffectSettingsWithUID:uid]];
            [showSet addObject:uid];
        }
    }
    for (id uid in otherHide) {
        if ([aDs containsObject:uid] || [hideSet containsObject:uid] || [toggleSet containsObject:uid])
            continue;
        if ([showSet containsObject:uid]) {
            [self addObjectUID:uid action:3 showEffectSettings:[self showEffectSettingsWithUID:uid] hideEffectSettings:[aAction hideEffectSettingsWithUID:uid]];
            [toggleSet addObject:uid];
            [showSet removeObject:uid];
        } else {
            [self addObjectUID:uid action:2 showEffectSettings:[aAction showEffectSettingsWithUID:uid] hideEffectSettings:[aAction hideEffectSettingsWithUID:uid]];
            [hideSet addObject:uid];
        }
    }
    for (id uid in otherToggle) {
        if (![allObjects containsObject:uid])
            [self addObjectUID:uid action:3 showEffectSettings:[aAction showEffectSettingsWithUID:uid] hideEffectSettings:[aAction hideEffectSettingsWithUID:uid]];
    }
}

// The copy drops the replaced objects; the image takes over the
// highest-priority show and hide among them.
- (id)copyReplacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID
{
    HSShowHideObjectAction *copy = [super copyReplacingObjectUIDs:aDs sortedByPriority:aPriority withImageObjectUID:aUID];
    if (copy == nil)
        return nil;
    NSSet *showSet = [NSSet setWithArray:[copy objectsToShow]];
    NSSet *hideSet = [NSSet setWithArray:[copy objectsToHide]];
    NSSet *toggleSet = [NSSet setWithArray:[copy objectsToToggle]];
    BOOL merged = NO;
    id showShowSettings = nil;
    id showHideSettings = nil;
    id hideHideSettings = nil;
    id hideShowSettings = nil;
    for (id uid in aPriority) {
        if (!merged) {
            if ([toggleSet containsObject:uid]) {
                [copy addObjectUID:aUID action:3 showEffectSettings:[copy showEffectSettingsWithUID:uid] hideEffectSettings:[copy hideEffectSettingsWithUID:uid]];
                merged = YES;
            } else if ([showSet containsObject:uid]) {
                id settings = [copy showEffectSettingsWithUID:uid];
                if (hideHideSettings == nil) {
                    // fixed: a later show leaked the earlier one's settings.
                    [showShowSettings release];
                    [showHideSettings release];
                    showShowSettings = [settings retain];
                    showHideSettings = [[copy hideEffectSettingsWithUID:uid] retain];
                } else {
                    [copy addObjectUID:aUID action:3 showEffectSettings:settings hideEffectSettings:hideHideSettings];
                    [hideHideSettings release];
                    [hideShowSettings release];
                    hideHideSettings = nil;
                    hideShowSettings = nil;
                    merged = YES;
                }
            } else if ([hideSet containsObject:uid]) {
                id settings = [copy hideEffectSettingsWithUID:uid];
                if (showShowSettings == nil) {
                    // fixed: a later hide leaked the earlier one's settings.
                    [hideHideSettings release];
                    [hideShowSettings release];
                    hideHideSettings = [settings retain];
                    hideShowSettings = [[copy showEffectSettingsWithUID:uid] retain];
                } else {
                    [copy addObjectUID:aUID action:3 showEffectSettings:showShowSettings hideEffectSettings:settings];
                    [showShowSettings release];
                    [showHideSettings release];
                    showShowSettings = nil;
                    showHideSettings = nil;
                    merged = YES;
                }
            }
        }
        [copy addObjectUID:uid action:0 showEffectSettings:nil hideEffectSettings:nil];
    }
    if (showShowSettings != nil) {
        [copy addObjectUID:aUID action:1 showEffectSettings:showShowSettings hideEffectSettings:showHideSettings];
        [showShowSettings release];
        [showHideSettings release];
    } else if (hideHideSettings != nil) {
        [copy addObjectUID:aUID action:2 showEffectSettings:hideShowSettings hideEffectSettings:hideHideSettings];
        [hideHideSettings release];
        [hideShowSettings release];
    }
    return copy;
}

// Newer documents store the map under the new key; the old one is then ignored.
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    NSMutableDictionary *representation = [NSMutableDictionary dictionaryWithDictionary:aRepresentation];
    if ([[HSDocument currentDocumentVersion] intValue] > 0x1b2 && [representation objectForKey:HSNewKeyForExtraStoring] != nil)
        [representation removeObjectForKey:HSOldKeyForExtraStoring];
    [super loadExtraDictionaryRepresentation:representation withCodingContext:aContext];
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:HSOldKeyForExtraStoring, HSNewKeyForExtraStoring, nil]];
}

// Alternating UID representation / entry pairs. A "No Transition" setting
// gets a zero duration.
- (void)setObjectUIDsToActionsMapForSerialization:(id)aSerialization
{
    NSMutableDictionary *map = [self objectUIDsToActionMap];
    int count = (int)[aSerialization count];
    for (int i = 0; i < count; i += 2) {
        id key = [aSerialization objectAtIndex:i];
        NSMutableDictionary *entry = [[aSerialization objectAtIndex:i + 1] mutableCopy];
        NSString *settingsKeys[2] = { @"HSShowEffectSettings", @"HSHideEffectSettings" };
        for (int j = 0; j < 2; j++) {
            NSMutableDictionary *settings = [[[entry objectForKey:settingsKeys[j]] mutableCopy] autorelease];
            if ([[settings objectForKey:@"HSShowHideTransitionName"] isEqual:@"No Transition"]) {
                [settings setObject:[NSNumber numberWithInt:0] forKey:@"HSShowHideTransitionDuration"];
                [entry setObject:settings forKey:settingsKeys[j]];
            }
        }
        [map setObject:[entry autorelease] forKey:[NSObject objectWithExtraDictionary:key]];
    }
}

- (void)setUIDStringsToActionsMap:(id)aMap
{
    NSMutableDictionary *map = [self objectUIDsToActionMap];
    NSEnumerator *enumerator = [aMap keyEnumerator];
    NSString *string;
    while ((string = [enumerator nextObject]) != nil) {
        id entry = [aMap objectForKey:string];
        [map setObject:[[entry mutableCopy] autorelease] forKey:[HSUID UIDWithString:string]];
    }
}

- (id)objectUIDsToActionsMapForSerialization
{
    NSMutableArray *serialization = [NSMutableArray array];
    NSDictionary *map = [self objectUIDsToActionMap];
    NSEnumerator *enumerator = [map keyEnumerator];
    HSUID *uid;
    while ((uid = [enumerator nextObject]) != nil)
        [serialization addObjectsFromArray:[NSArray arrayWithObjects:[uid extraDictionaryRepresentation], [map objectForKey:uid], nil]];
    return serialization;
}

- (id)UIDStringsToActionsMap
{
    NSMutableDictionary *strings = [NSMutableDictionary dictionary];
    NSDictionary *map = [self objectUIDsToActionMap];
    NSEnumerator *enumerator = [map keyEnumerator];
    HSUID *uid;
    while ((uid = [enumerator nextObject]) != nil)
        [strings setObject:[map objectForKey:uid] forKey:[uid stringValue]];
    return strings;
}

- (id)objectUIDsToActionMap
{
    if (_objectUIDsToActionMap == nil)
        _objectUIDsToActionMap = [NSMutableDictionary new];
    return _objectUIDsToActionMap;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSShowHideTransitionDidFinishNotification" object:nil];
    [_objectUIDsToActionMap release];
    [_navigationOperation release];
    [_context release];
    [super dealloc];
}

- (id)init
{
    return [super init];
}

- (void)removeUnsupportedFeatures
{
    [self clearUnsupportedTransitions];
}

- (void)clearUnsupportedTransitions
{
    [_unsupportedTransitions release];
    _unsupportedTransitions = nil;
}

- (id)unsupportedTransitions
{
    if (_unsupportedTransitions == nil)
        _unsupportedTransitions = [NSMutableArray new];
    return _unsupportedTransitions;
}

- (id)HTML5UnsupportedFunctionalityDescriptionForTransitionName:(id)aName
{
    return [NSString stringWithFormat:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSHTML5UnsupportedFeatureTransition" value:@"" table:@"Export"], [[HSTransitionEffectProvider sharedTransitionEffectProvider] displayNameForTransitionEffectWithName:aName]];
}

- (id)allObjectsToPauseResume
{
    NSMutableArray *objects = [NSMutableArray array];
    for (id uids in [NSArray arrayWithObjects:[self objectsToShow], [self objectsToHide], [self objectsToToggle], nil]) {
        for (id uid in uids) {
            id object = [[self objectForUID:uid] queryHyperInterface:@protocol(HSShowHideTransitionAttributes)];
            if (object != nil && [object transition] != nil)
                [objects addObject:object];
        }
    }
    return objects;
}

- (void)pause
{
    if (_runningCount != 0)
        [[self allObjectsToPauseResume] makeObjectsPerformSelector:@selector(pauseTransition)];
}

- (void)resume
{
    if (_runningCount != 0)
        [[self allObjectsToPauseResume] makeObjectsPerformSelector:@selector(resumeTransition)];
}

// Re-keys the object to action map with the UIDs of the connected stack's objects.
- (void)didConnectToDocument
{
    if ([[self objectUIDsToActionMap] count] != 0 && [self stack] != nil) {
        NSEnumerator *enumerator = [[self stack] hyperDeepEnumerator];
        NSMutableDictionary *map = [NSMutableDictionary new];
        id object;
        while ((object = [enumerator nextObject]) != nil) {
            id action = [[self objectUIDsToActionMap] objectForKey:[object hyperUID]];
            if (action != nil)
                [map setObject:action forKey:[object hyperUID]];
        }
        [_objectUIDsToActionMap release];
        _objectUIDsToActionMap = map;
    }
}

@end
