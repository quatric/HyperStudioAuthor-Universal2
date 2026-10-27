#import "HSScriptAction.h"
#import "HSActionEvent.h"
#import "HSAttributeNotificationCenter.h"
#import "HSAutoTypeAction.h"
#import "HSGhostWriterAction.h"
#import "HSUID.h"

// The base of the actions: an owner (an object, a card or a group of actions)
// runs it on its events. Attribute observers are kept by the shared attribute
// notification center.
@implementation HSAction

+ (id)tooltip
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:[self actionType] value:@"" table:@"ActionTooltips"];
}

+ (id)localizedNameInInspector
{
    NSString *name = [self localizedName];
    if ([[self actionsNamedWithEllipsis] containsObject:[self actionType]])
        name = [name hyperStringByAddingEllipsis];
    return name;
}

+ (id)actionsNamedWithEllipsis
{
    static NSArray *actionsNamedWithEllipsis = nil;
    if (!actionsNamedWithEllipsis)
        actionsNamedWithEllipsis = [[NSArray alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"ActionsNamedWithEllipsis" ofType:@"plist"]];
    return actionsNamedWithEllipsis;
}

+ (id)localizedName
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:[self actionType] value:@"" table:@"ActionNames"];
}

+ (id)action
{
    return [[self new] autorelease];
}

+ (id)actionOfType:(id)aType
{
    return [NSClassFromString(aType) action];
}

+ (id)actionType
{
    return NSStringFromClass([self class]);
}

+ (BOOL)accessInstanceVariablesDirectly
{
    return NO;
}

- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    NSString *eventType = [[aRepresentation attributeForName:@"eventType"] stringValue];
    NSString *type = kHSClickActionEventType;
    if ([eventType isEqualToString:@"arrive"])
        type = kHSArriveActionEventType;
    else if ([eventType isEqualToString:@"leave"])
        type = kHSLeaveActionEventType;
    [self addActionEvent:[HSActionEvent actionEventOfType:type]];
}

- (id)XMLElementName
{
    return @"action";
}

- (BOOL)canBeStoredAsXMLElement
{
    return NO;
}

- (id)XMLElementRepresentationInContext:(id)aContext
{
    NSXMLElement *element = [NSXMLElement elementWithName:[self XMLElementName]];
    [element addAttribute:[NSXMLNode attributeWithName:@"uid" stringValue:[[HSUID UID] stringValue]]];
    NSString *eventType = [[[self events] extraFirstObject] eventType];
    NSString *name = @"click";
    if ([eventType isEqualToString:kHSArriveActionEventType])
        name = @"arrive";
    else if ([eventType isEqualToString:kHSLeaveActionEventType])
        name = @"leave";
    [element addAttribute:[NSXMLNode attributeWithName:@"eventType" stringValue:name]];
    return element;
}

- (id)HTML5UnsupportedFeaturesForDocumentType:(id)aType
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL)hasUnsupportedHTML5FeaturesForDocumentType:(id)aType
{
    return NO;
}

- (id)HTML5UnsupportedFunctionalityDescription
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL)shouldBeExportedAsImage
{
    return NO;
}

- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    if (![self isValid])
        return nil;
    return [NSMutableDictionary dictionaryWithObject:[[self class] actionType] forKey:@"type"];
}

- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return NO;
}

- (void)updateActionValidationStatus
{
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}

- (BOOL)isAbleToStartInInvalidState
{
    return NO;
}

- (BOOL)isValid
{
    return YES;
}

- (BOOL)wantsSaveAfterRemove
{
    return YES;
}

- (id)attributesChangedTemporary
{
    return [NSEProtocolSet protocolSet];
}

- (id)attributesBeingChangedContinuously
{
    return [NSEProtocolSet protocolSet];
}

- (void)endContinuousChangeOfAttributeSet:(id)aSet
{
    [[self attributeNotificationCenter] notifyChange:0x80 ofAttributeSet:aSet ofObject:self withUserInfo:nil];
}

- (void)beginContinuousChangeOfAttributeSet:(id)aSet
{
    [[self attributeNotificationCenter] notifyChange:0x40 ofAttributeSet:aSet ofObject:self withUserInfo:nil];
}

- (void)endContinuousChangeOfAttribute:(id)aAttribute
{
    [[self attributeNotificationCenter] notifyChange:0x80 ofAttribute:aAttribute ofObject:self withUserInfo:nil];
}

- (void)beginContinuousChangeOfAttribute:(id)aAttribute
{
    [[self attributeNotificationCenter] notifyChange:0x40 ofAttribute:aAttribute ofObject:self withUserInfo:nil];
}

- (void)removeAttributeObserver:(id)aObserver
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:NULL ofChanges:HSAllAttributeChanges ofAttribute:nil ofObject:self];
}

- (void)removeAttributeObserver:(id)aObserver selector:(SEL)aSelector
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:HSAllAttributeChanges ofAttribute:nil ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterfaces:aInterfaces ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterface:aInterface ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesFromSet:aSet ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:aAttributes ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttribute:aAttribute ofObject:self];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterfaces:aInterfaces ofObject:self withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterface:aInterface ofObject:self withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesFromSet:aSet ofObject:self withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:aAttributes ofObject:self withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttribute:aAttribute ofObject:self withPriority:aPriority];
}

- (id)attributeObservingController
{
    return self;
}

- (id)attributeNotificationCenter
{
    return [HSAttributeNotificationCenter defaultCenter];
}

// The synchronous flag is not loaded from the stored dictionary.
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    NSMutableDictionary *representation = [aRepresentation mutableCopy];
    [representation removeObjectForKey:@"_synchronous"];
    [super loadExtraDictionaryRepresentation:representation withCodingContext:aContext];
    [representation release];
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObjects:[@"events" extraKeyForCollection], nil];
}

- (BOOL)canChangeSynchronousFlag
{
    return YES;
}

- (void)setSynchronous:(BOOL)aSynchronous
{
    if ([self isSynchronous] == aSynchronous)
        return;
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionSynchronousAttribute) ofObject:self withUserInfo:nil];
    _synchronous = aSynchronous;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionSynchronousAttribute) ofObject:self withUserInfo:nil];
}

- (BOOL)isSynchronous
{
    return _synchronous;
}

- (id)undoManager
{
    return [[(id<HSNodeSupportAttributes>)[[self hyperObject] queryHyperInterface:@protocol(HSNodeSupportAttributes)] support] undoManager];
}

- (void)convertOldVersionAttributesIfNeeded
{
}

- (void)willDisconnectFromDocument
{
}

- (void)didConnectToDocument
{
}

- (void)willRemoveFromDocument
{
}

- (void)didAddToDocument
{
}

- (void)performPrimarySetupOnCard:(id)aCard actionExecutionContext:(id)aContext
{
}

- (void)notifyDidFinish
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSHyperActionDidFinish" object:self];
}

- (void)stop:(id)aStop
{
    [self notifyDidFinish];
}

- (BOOL)canBeStopped
{
    return NO;
}

- (BOOL)canRunInContext:(id)aContext
{
    return YES;
}

- (void)startInContext:(id)aContext
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)removeActionEvent:(id)aEvent
{
    NSMutableArray *events = [[self events] mutableCopy];
    [events removeObject:aEvent];
    [self setEvents:events];
    [events release];
}

- (void)addActionEvent:(id)aEvent
{
    NSArray *events = [self events];
    if (!events)
        events = [NSArray array];
    [self setEvents:[events arrayByAddingObject:aEvent]];
}

- (void)setEvents:(id)aEvents
{
    if ([aEvents isEqual:_events])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Action Events" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setEvents:[self events]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionEventsAttribute) ofObject:self withUserInfo:nil];
    [_events release];
    _events = [aEvents retain];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionEventsAttribute) ofObject:self withUserInfo:nil];
}

- (id)events
{
    if (!_events)
        _events = [NSArray new];
    return _events;
}

- (BOOL)runsWithActionEvent:(id)aEvent
{
    return [[self events] containsObject:aEvent];
}

- (BOOL)supportedInIPad
{
    return NO;
}

- (BOOL)supportedInStackToGo
{
    return YES;
}

- (BOOL)supportedInWebPlayer
{
    return YES;
}

- (id)copyReplacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID
{
    return [self copy];
}

- (BOOL)isKindOfType:(id)aType
{
    return [NSClassFromString([[self class] actionType]) isSubclassOfClass:NSClassFromString(aType)];
}

- (id)card
{
    return [(id<HSActionSupport>)[[self hyperObject] queryHyperInterface:@protocol(HSActionSupport)] cardForAction:self];
}

- (id)stack
{
    return [(id<HSActionSupport>)[[self hyperObject] queryHyperInterface:@protocol(HSActionSupport)] stackForAction:self];
}

- (id)localizedNameInInspector
{
    return [[self class] localizedNameInInspector];
}

- (id)localizedName
{
    return [[self class] localizedName];
}

- (id)document
{
    return [(id<HSUserObjectSupport>)[[self hyperObject] queryHyperInterface:@protocol(HSUserObjectSupport)] document];
}

// No action validates a run script action; the copy supports are answered
// only by the actions adopting them.
- (id)queryHyperInterface:(id)aInterface
{
    if (protocol_conformsToProtocol(aInterface, @protocol(HSRunScriptActionValidation)))
        return nil;
    if (HSProtocolsAreEqual(aInterface, @protocol(HSMediaCopySupport)))
        return [self conformsToProtocol:@protocol(HSMediaCopySupport)] ? self : nil;
    if (HSProtocolsAreEqual(aInterface, @protocol(HSActionCopySupport)))
        return [self conformsToProtocol:@protocol(HSActionCopySupport)] ? self : nil;
    return [super queryHyperInterface:aInterface];
}

- (id)hyperObject
{
    return [[self owner] hyperObjectForAction:self];
}

- (void)ownerDidChange
{
}

- (void)ownerWillChange
{
}

- (void)setOwner:(id)aOwner
{
    [self ownerWillChange];
    _owner = aOwner;
    [self ownerDidChange];
}

- (id)owner
{
    return _owner;
}

- (void)dealloc
{
    [_events release];
    [super dealloc];
}

// A copy through the stored representation, which leaves out the synchronous
// flag.
- (id)copyWithZone:(NSZone *)aZone
{
    HSAction *copy = [[[self class] objectWithExtraDictionary:[self extraDictionaryRepresentation] zone:aZone] retain];
    if ([self canChangeSynchronousFlag])
        [copy setSynchronous:[self isSynchronous]];
    return copy;
}

- (void)pause
{
}

- (void)resume
{
}

- (void)removeUnsupportedFeatures
{
}

- (BOOL)shouldBeRemoved
{
    return _shouldBeRemoved;
}

- (void)setShouldBeRemoved:(BOOL)aRemoved
{
    _shouldBeRemoved = aRemoved;
}

@end

@implementation HSToDoAction
@end

@implementation HSScriptAction
@end

@implementation HSNBAAction

// Auto type actions are loaded as ghost writer actions.
- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext
{
    self = [super initWithExtraDictionary:aDictionary codingContext:aContext];
    if ([self isKindOfClass:[HSAutoTypeAction class]]) {
        id action = [HSGhostWriterAction ghostWriterActionFromAutoTypeAction:self];
        [self autorelease];
        self = [action retain];
    }
    return self;
}

@end

@implementation HSToGoAction

- (BOOL)supportedInIPad
{
    return YES;
}

- (BOOL)canChangeSynchronousFlag
{
    return NO;
}

- (BOOL)isSynchronous
{
    return YES;
}

@end
