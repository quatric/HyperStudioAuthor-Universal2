#import "HSHypertextLinksContainerNodeUnit.h"
#import "EXCodingContext.h"
#import "HSActionEvent.h"
#import "HSActor.h"
#import "HSExecutableResourceProvider.h"
#import "HSFunctions.h"
#import "HSProtocolIdentifier.h"

// The hypertext links of a text object, by title: each link has an actor
// holding its actions. Link actors are owned by the unit, which watches
// their actions to report link changes.
@implementation HSHypertextLinksContainerNodeUnit

- (void)linkActorDidChange:(id)aChange
{
    [self notifyChange:2 ofAttribute:@protocol(HSHypertextLinkContainerLinksAttribute) withUserInfo:nil];
}

// The unit's media and that of every link's actions.
- (id)mediaUIDs
{
    id mediaUIDs = [super mediaUIDs];
    NSEnumerator *enumerator = [_links count] != 0 ? [_links objectEnumerator] : nil;
    NSMutableSet *linksMediaUIDs = nil;
    id link;
    while ((link = [enumerator nextObject]) != nil) {
        NSSet *linkMediaUIDs = [[link queryHyperInterface:@protocol(HSActor)] mediaUIDs];
        if ([linkMediaUIDs count] == 0)
            continue;
        if (linksMediaUIDs == nil)
            linksMediaUIDs = [[linkMediaUIDs mutableCopy] autorelease];
        else
            [linksMediaUIDs unionSet:linkMediaUIDs];
    }
    if ([linksMediaUIDs count] == 0)
        return mediaUIDs;
    if ([mediaUIDs count] != 0)
        [linksMediaUIDs unionSet:mediaUIDs];
    return linksMediaUIDs;
}

- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    [super loadExtraDictionaryRepresentation:aRepresentation withCodingContext:aContext];
    [[self allLinks] makeObjectsPerformSelector:@selector(setContainer:) withObject:self];
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObject:[@"links" extraKeyForCollection]];
}

- (BOOL)supportsSharingBetweenGroupObjects
{
    return NO;
}

- (id)allSortedTitles
{
    if (_sortedTitles == nil && _links != nil)
        _sortedTitles = [[[_links allKeys] sortedArrayUsingSelector:@selector(compare:)] retain];
    return _sortedTitles;
}

- (id)allLinks
{
    return [_links allValues];
}

// Moves a link (its actor) from another container to this one.
- (void)takeLinkWithTitle:(id)aTitle fromContainer:(id)aContainer
{
    id actor = [[aContainer linkWithTitle:aTitle] actor];
    if (actor == nil)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Toggle This Field Only" value:@"" table:@"UndoManager"]];
    [aContainer removeLinkWithTitle:aTitle];
    [self addLinkWithTitle:aTitle actor:actor];
}

- (void)removeAllLinks
{
    for (id title in [_links allKeys])
        [self removeLinkWithTitle:title];
}

- (void)removeLinkWithTitle:(id)aTitle
{
    if (aTitle == nil)
        return;
    HSHypertextLink *link = [_links objectForKey:aTitle];
    if (link == nil)
        return;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSSet setWithObject:link], @"HSHypertextLinkRemovedLinks", nil];
    [self notifyChange:1 ofAttribute:@protocol(HSHypertextLinkContainerLinksAttribute) withUserInfo:userInfo];
    NSUndoManager *undoManager = [self undoManager];
    [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Remove Hypertext Link" value:@"" table:@"UndoManager"]];
    [(HSHypertextLinksContainerNodeUnit *)[undoManager prepareWithInvocationTarget:self] addLinkWithTitle:aTitle actor:[link actor]];
    id actor = [link actor];
    [actor removeObserver:self selector:@selector(linkActorDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSActionsAttribute)];
    if ([actor owner] == self)
        [actor setOwner:nil];
    [_links removeObjectForKey:aTitle];
    [_sortedTitles release];
    _sortedTitles = nil;
    [self notifyChange:2 ofAttribute:@protocol(HSHypertextLinkContainerLinksAttribute) withUserInfo:userInfo];
}

// A renamed link is a new link object with the same actor.
- (void)renameLinkWithTitle:(id)aTitle to:(id)aTo
{
    if (aTitle == nil || [aTitle isEqualToString:aTo])
        return;
    HSHypertextLink *link = [_links objectForKey:aTitle];
    if (link == nil)
        return;
    HSHypertextLink *renamed = [[HSHypertextLink alloc] initWithTitle:aTo actor:[link actor] container:self];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSSet setWithObject:link], @"HSHypertextLinkRemovedLinks",
                                                                        [NSSet setWithObject:renamed], @"HSHypertextLinkAddedLinks", nil];
    [self notifyChange:1 ofAttribute:@protocol(HSHypertextLinkContainerLinksAttribute) withUserInfo:userInfo];
    NSUndoManager *undoManager = [self undoManager];
    [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Rename Hypertext Link" value:@"" table:@"UndoManager"]];
    [(HSHypertextLinksContainerNodeUnit *)[undoManager prepareWithInvocationTarget:self] renameLinkWithTitle:aTo to:aTitle];
    [[link actor] removeObserver:self selector:@selector(linkActorDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSActionsAttribute)];
    [_links removeObjectForKey:aTitle];
    [_links setObject:renamed forKey:aTo];
    [[renamed actor] addObserver:self selector:@selector(linkActorDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSActionsAttribute) withPriority:-0.25];
    [renamed release];
    [_sortedTitles release];
    _sortedTitles = nil;
    [self notifyChange:2 ofAttribute:@protocol(HSHypertextLinkContainerLinksAttribute) withUserInfo:userInfo];
}

- (id)addLinkWithTitle:(id)aTitle
{
    return [self addLinkWithTitle:aTitle actor:[[HSActor new] autorelease]];
}

// An existing link with that title is returned as is.
- (id)addLinkWithTitle:(id)aTitle actor:(id)aActor
{
    HSHypertextLink *link = [self linkWithTitle:aTitle];
    if (link != nil)
        return link;
    link = [[HSHypertextLink alloc] initWithTitle:aTitle actor:aActor container:self];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSSet setWithObject:link], @"HSHypertextLinkAddedLinks", nil];
    [self notifyChange:1 ofAttribute:@protocol(HSHypertextLinkContainerLinksAttribute) withUserInfo:userInfo];
    NSUndoManager *undoManager = [self undoManager];
    [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Add Hypertext Link" value:@"" table:@"UndoManager"]];
    [(HSHypertextLinksContainerNodeUnit *)[undoManager prepareWithInvocationTarget:self] removeLinkWithTitle:aTitle];
    if (_links == nil)
        _links = [NSMutableDictionary new];
    [_links setObject:link forKey:aTitle];
    [[link actor] setOwner:self];
    [[link actor] addObserver:self selector:@selector(linkActorDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSActionsAttribute) withPriority:-0.25];
    [link release];
    [_sortedTitles release];
    _sortedTitles = nil;
    [self notifyChange:2 ofAttribute:@protocol(HSHypertextLinkContainerLinksAttribute) withUserInfo:userInfo];
    return link;
}

- (id)linkWithTitle:(id)aTitle
{
    return [_links objectForKey:aTitle];
}

// The host node on the current card, else any host node.
- (id)hyperObjectForActor:(id)aActor
{
    NSSet *hostNodes = [self hostNodes];
    id node = [hostNodes anyObject];
    if (node == nil)
        return nil;
    id children = [[[[node queryHyperInterface:@protocol(HSUserObjectSupport)] document] currentCard] hyperChildren];
    for (id hostNode in hostNodes) {
        if ([children containsObject:hostNode])
            return hostNode;
    }
    return node;
}

- (Class)hyperImplementationClassForHyperInterface:(id)aInterface
{
    if (HSProtocolsAreEqual(@protocol(HSHypertextLinkContainerAttributes), aInterface))
        return [HSHypertextLinkContainerAttributesImplementation class];
    return Nil;
}

- (BOOL)implementsHyperInterface:(id)aInterface
{
    return HSProtocolsAreEqual(@protocol(HSHypertextLinkContainerAttributes), aInterface);
}

- (id)implementedHyperInterfaces
{
    return [NSSet setWithObjects:[HSProtocolIdentifier identifierForProtocol:@protocol(HSHypertextLinkContainerAttributes)], nil];
}

- (id)attributes
{
    return [NSEProtocolSet protocolSetWithProtocol:@protocol(HSHypertextLinkContainerLinksAttribute)];
}

- (void)dealloc
{
    [[_links allValues] makeObjectsPerformSelector:@selector(setContainer:) withObject:nil];
    [self removeObservers];
    [_links release];
    [_sortedTitles release];
    [super dealloc];
}

- (void)removeObservers
{
    for (HSHypertextLink *link in [_links objectEnumerator])
        [[link actor] removeObserver:self selector:@selector(linkActorDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSActionsAttribute)];
}

@end

// A titled link: its actor holds the actions run when the link is clicked.
// The container is not retained.
@implementation HSHypertextLink

- (id)HTML5UnsupportedFeaturesForDocumentType:(id)aType
{
    NSMutableSet *features = nil;
    for (id action in [[self actor] hyperActions]) {
        if (![action canBeExportedToHTML5DocumentType:aType]) {
            NSString *name = [[action queryHyperInterface:@protocol(HSActionAttributes)] localizedName];
            NSString *format = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSHTML5UnsupportedFeatureAction" value:@"" table:@"Export"];
            NSString *feature = [NSString stringWithFormat:format, name];
            if (features == nil)
                features = [NSMutableSet setWithObject:feature];
            else
                [features addObject:feature];
        } else if ([action hasUnsupportedHTML5FeaturesForDocumentType:aType]) {
            NSSet *actionFeatures = [action HTML5UnsupportedFeaturesForDocumentType:aType];
            if ([actionFeatures count] == 0)
                continue;
            if (features == nil)
                features = [NSMutableSet setWithSet:actionFeatures];
            else
                [features unionSet:actionFeatures];
        }
    }
    return features;
}

- (BOOL)hasUnsupportedHTML5FeaturesForDocumentType:(id)aType
{
    for (id action in [[self actor] hyperActions]) {
        if (![action canBeExportedToHTML5DocumentType:aType] || [action hasUnsupportedHTML5FeaturesForDocumentType:aType])
            return YES;
    }
    return NO;
}

// The first action's description.
- (id)HTML5UnsupportedFunctionalityDescription
{
    for (id action in [[self actor] hyperActions]) {
        id description = [action HTML5UnsupportedFunctionalityDescription];
        if (description != nil)
            return description;
    }
    return nil;
}

- (BOOL)shouldBeExportedAsImage
{
    return NO;
}

- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    for (id action in [[self actor] hyperActions]) {
        if ([action canBeExportedToHTML5DocumentType:aType])
            return YES;
    }
    return NO;
}

// The title and the click actions; nil without actions.
- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    id actions = [[self actor] actionsHTML5RepresentationForEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType] inContext:aContext];
    if ([actions count] == 0)
        return nil;
    NSMutableDictionary *dictionary = [[NSMutableDictionary new] autorelease];
    [dictionary setObject:[self title] forKey:@"title"];
    [dictionary setObject:actions forKey:@"click"];
    return dictionary;
}

- (void)cleanupUserInfo
{
    [_userInfo release];
    _userInfo = nil;
}

- (id)userInfoForKey:(id)aKey
{
    return [_userInfo objectForKey:aKey];
}

- (void)setUserInfo:(id)aInfo forKey:(id)aKey
{
    if (_userInfo == nil)
        _userInfo = [NSMutableDictionary new];
    [_userInfo setValue:aInfo forKey:aKey];
}

- (id)uniqueNameGenerator
{
    return [[[[self container] hyperObjectForActor:_actor] queryHyperInterface:@protocol(HSUserObjectSupport)] uniqueNameGenerator];
}

- (id)document
{
    return [[[[self container] hyperObjectForActor:_actor] queryHyperInterface:@protocol(HSUserObjectSupport)] document];
}

- (id)card
{
    return [[self document] currentCard];
}

- (id)stack
{
    return [[[[self container] hyperObjectForActor:_actor] queryHyperInterface:@protocol(HSUserObjectSupport)] stack];
}

- (id)copyWithZone:(NSZone *)aZone
{
    return [[[self class] objectWithExtraDictionary:[self extraDictionaryRepresentation] zone:aZone] retain];
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObjects:@"title", @"actor", nil];
}

- (BOOL)supportsActionType:(id)aType forEvent:(id)aEvent
{
    return YES;
}

// The actor answers for itself; action, media, observing and node support
// come from the object hosting the link.
- (id)queryHyperInterface:(id)aInterface
{
    if (HSProtocolsAreEqual(aInterface, @protocol(HSActor)))
        return _actor;
    id hostObject = [[self container] hyperObjectForActor:_actor];
    if (HSProtocolsAreEqual(aInterface, @protocol(HSActionSupport))
        || HSProtocolsAreEqual(aInterface, @protocol(HSMediaCopySupport))
        || HSProtocolsAreEqual(aInterface, @protocol(HSAttributeObserving))
        || HSProtocolsAreEqual(aInterface, @protocol(HSNodeSupportAttributes)))
        return [hostObject queryHyperInterface:aInterface];
    return [super queryHyperInterface:aInterface];
}

- (void)setContainer:(id)aContainer
{
    _container = aContainer;
    [[self actor] setOwner:_container];
}

- (id)container
{
    return _container;
}

- (id)actor
{
    return _actor;
}

- (id)title
{
    return _title;
}

- (void)dealloc
{
    [_actor release];
    [_title release];
    [_userInfo release];
    [super dealloc];
}

// Needs an actor and a non-empty title.
- (id)initWithTitle:(id)aTitle actor:(id)aActor container:(id)aContainer
{
    if (aActor == nil || [aTitle length] == 0) {
        [self release];
        return nil;
    }
    self = [super init];
    if (self != nil) {
        _title = [aTitle copy];
        _container = aContainer;
        _actor = [aActor retain];
    }
    return self;
}

@end
