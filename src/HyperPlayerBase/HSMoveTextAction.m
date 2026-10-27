#import "HSMoveTextAction.h"
#import "HSActionExecutionContext.h"
#import "HSUID.h"

// Moves or copies text from a text object (or comments of an object, card
// or stack) into a destination text object, replacing, appending to or
// inserting into its text. Source action 2 only clears the source.
@implementation HSMoveTextAction

+ (NSInteger)moveTextDestinationActionFromStringForXMLStoring:(id)aStoring
{
    if ([aStoring isEqualToString:@"append"])
        return 1;
    return [aStoring isEqualToString:@"insert"] ? 2 : 0;
}

+ (id)stringForXMLStoringFromMoveTextDestinationAction:(NSInteger)aAction
{
    if (aAction == 2)
        return @"insert";
    if (aAction == 1)
        return @"append";
    return @"replace";
}

+ (NSInteger)moveTextSourceActionFromStringForXMLStoring:(id)aStoring
{
    return [aStoring isEqualToString:@"copy"] ? 1 : 0;
}

+ (id)stringForXMLStoringFromMoveTextSourceAction:(NSInteger)aAction
{
    return aAction == 1 ? @"copy" : @"move";
}

+ (NSInteger)moveTextSourceDataTypeFromStringForXMLStoring:(id)aStoring
{
    if ([aStoring isEqualToString:@"objectsComments"])
        return 1;
    if ([aStoring isEqualToString:@"cardsComments"])
        return 2;
    if ([aStoring isEqualToString:@"stacksComments"])
        return 3;
    return [aStoring isEqualToString:@"commentsOnCard"] ? 4 : 0;
}

+ (id)stringForXMLStoringFromMoveTextSourceDataType:(NSInteger)aType
{
    switch (aType) {
    case 1:
        return @"objectsComments";
    case 2:
        return @"cardsComments";
    case 3:
        return @"stacksComments";
    case 4:
        return @"commentsOnCard";
    default:
        return @"textObject";
    }
}

- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    if (![self isValid])
        return nil;
    NSMutableDictionary *representation = [super HTML5DictionaryRepresentationInContext:aContext];
    [representation setObject:[NSString stringWithFormat:@"%d", _sourceDataType] forKey:@"sourceDataType"];
    [representation setObject:[NSString stringWithFormat:@"%d", _sourceAction] forKey:@"sourceAction"];
    [representation setObject:[NSString stringWithFormat:@"%d", _destinationAction] forKey:@"destinationAction"];
    if (_sourceObjectUID != nil)
        [representation setObject:[_sourceObjectUID stringValue] forKey:@"src"];
    if (_destinationObjectUID != nil)
        [representation setObject:[_destinationObjectUID stringValue] forKey:@"dest"];
    return representation;
}

- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}

// A source object must be in the stack tree; without one the source is
// comments. Unless the source is only cleared, the destination must exist too.
- (BOOL)isValid
{
    BOOL valid;
    id uid = [self sourceObjectUID];
    if (uid == nil) {
        valid = [self sourceDataType] != 0;
    } else {
        id object = [self objectWithUID:uid];
        valid = object != nil && [object hyperParent] != nil;
    }
    if (_sourceAction != 2) {
        uid = [self destinationObjectUID];
        valid = valid && uid != nil;
        if (valid) {
            id object = [self objectWithUID:uid];
            valid = object != nil && [object hyperParent] != nil;
        }
    }
    return valid;
}

- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    [super importFromXMLElementRepresentation:aRepresentation inContext:aContext];
    [self setSourceObjectUID:[HSUID UIDWithString:[[aRepresentation attributeForName:@"sourceObjectUID"] stringValue]]];
    [self setDestinationObjectUID:[HSUID UIDWithString:[[aRepresentation attributeForName:@"destinationObjectUID"] stringValue]]];
    [self setSourceDataType:[[self class] moveTextSourceDataTypeFromStringForXMLStoring:[[aRepresentation attributeForName:@"sourceDataType"] stringValue]]];
    [self setSourceAction:[[self class] moveTextSourceActionFromStringForXMLStoring:[[aRepresentation attributeForName:@"sourceAction"] stringValue]]];
    [self setDestinationAction:[[self class] moveTextDestinationActionFromStringForXMLStoring:[[aRepresentation attributeForName:@"destinationAction"] stringValue]]];
}

- (id)XMLElementRepresentationInContext:(id)aContext
{
    NSXMLElement *representation = [super XMLElementRepresentationInContext:aContext];
    [representation addAttribute:[NSXMLNode attributeWithName:@"sourceObjectUID" stringValue:[[self sourceObjectUID] stringValue]]];
    [representation addAttribute:[NSXMLNode attributeWithName:@"destinationObjectUID" stringValue:[[self destinationObjectUID] stringValue]]];
    [representation addAttribute:[NSXMLNode attributeWithName:@"sourceDataType" stringValue:[[self class] stringForXMLStoringFromMoveTextSourceDataType:[self sourceDataType]]]];
    [representation addAttribute:[NSXMLNode attributeWithName:@"sourceAction" stringValue:[[self class] stringForXMLStoringFromMoveTextSourceAction:[self sourceAction]]]];
    [representation addAttribute:[NSXMLNode attributeWithName:@"destinationAction" stringValue:[[self class] stringForXMLStoringFromMoveTextDestinationAction:[self destinationAction]]]];
    return representation;
}

- (id)XMLElementName
{
    return @"actMoveText";
}

- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}

- (BOOL)supportedInIPad
{
    return YES;
}

// Legacy flags; they only apply while the action is replace/append (or move/copy).
- (void)setDoAppend:(BOOL)aAppend
{
    if ([self destinationAction] == 1 || [self destinationAction] == 0)
        [self setDestinationAction:aAppend ? 1 : 0];
}

- (BOOL)doAppend
{
    return [self destinationAction] == 1;
}

- (void)setDoCopy:(BOOL)aCopy
{
    if ([self sourceAction] == 1 || [self sourceAction] == 0)
        [self setSourceAction:aCopy ? 1 : 0];
}

- (BOOL)doCopy
{
    return [self sourceAction] == 1;
}

- (void)ownerDidChange
{
    [self updateDestinationObjectIfNeeded];
    [self updateSourceObjectIfNeeded];
}

- (void)ownerWillChange
{
    [self setDestinationObject:nil];
    [self setSourceObject:nil];
}

- (void)didConnectToDocument
{
    [self updateDestinationObjectIfNeeded];
    [self updateSourceObjectIfNeeded];
}

- (void)willDisconnectFromDocument
{
    [self setDestinationObject:nil];
    [self setSourceObject:nil];
}

- (void)setDestinationAction:(NSInteger)aAction
{
    if (_destinationAction == aAction)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Destination Object Actions" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setDestinationAction:[self destinationAction]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSMoveTextDestinationActionAttribute) ofObject:self withUserInfo:nil];
    _destinationAction = (int)aAction;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSMoveTextDestinationActionAttribute) ofObject:self withUserInfo:nil];
}

- (NSInteger)destinationAction
{
    return _destinationAction;
}

- (void)setSourceAction:(NSInteger)aAction
{
    if (_sourceAction == aAction)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Source Object Actions" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setSourceAction:[self sourceAction]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSMoveTextSourceActionAttribute) ofObject:self withUserInfo:nil];
    _sourceAction = (int)aAction;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSMoveTextSourceActionAttribute) ofObject:self withUserInfo:nil];
}

- (NSInteger)sourceAction
{
    return _sourceAction;
}

// The original notifies the source action attribute for data type changes.
- (void)setSourceDataType:(NSInteger)aType
{
    if (_sourceDataType == aType)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Source Object Data Types" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setSourceDataType:[self sourceDataType]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSMoveTextSourceActionAttribute) ofObject:self withUserInfo:nil];
    _sourceDataType = (int)aType;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSMoveTextSourceActionAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}

- (NSInteger)sourceDataType
{
    return _sourceDataType;
}

- (void)setDestinationObjectUID:(id)aUID
{
    if ([_destinationObjectUID isEqual:aUID])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Destination Object" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setDestinationObjectUID:[self destinationObjectUID]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSMoveTextDestinationObjectUIDAttribute) ofObject:self withUserInfo:nil];
    [self setDestinationObject:nil];
    [_destinationObjectUID release];
    _destinationObjectUID = [aUID retain];
    [self setDestinationObject:[self objectWithUID:_destinationObjectUID]];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSMoveTextDestinationObjectUIDAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}

- (id)destinationObjectUID
{
    return _destinationObjectUID;
}

- (void)setSourceObjectUID:(id)aUID
{
    if ([_sourceObjectUID isEqual:aUID])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Source Object" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setSourceObjectUID:[self sourceObjectUID]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSMoveTextSourceObjectUIDAttribute) ofObject:self withUserInfo:nil];
    [self setSourceObject:nil];
    [_sourceObjectUID release];
    _sourceObjectUID = [aUID retain];
    [self setSourceObject:[self objectWithUID:_sourceObjectUID]];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSMoveTextSourceObjectUIDAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}

- (id)sourceObjectUID
{
    return _sourceObjectUID;
}

- (void)setDestinationObjectValue:(id)aValue
{
    [[[self destinationObject] queryHyperInterface:@protocol(HSStringContentAttributes)] setHyperAttributedStringValue:aValue];
}

- (id)destinationObjectValue
{
    id content = [[self destinationObject] queryHyperInterface:@protocol(HSStringContentAttributes)];
    if (content == nil)
        return nil;
    return [[[content hyperAttributedStringValue] copy] autorelease];
}

// Comments can't be changed, so only a text object source is cleared.
- (void)setSourceObjectValue:(id)aValue
{
    if ([self sourceDataType] == 0)
        [[[self sourceObject] queryHyperInterface:@protocol(HSStringContentAttributes)] setHyperAttributedStringValue:aValue];
}

// The text of the source object, or the comments of the action's object,
// the current card or stack, or every object on the current card.
- (id)sourceObjectValue
{
    id commented = nil;
    switch ([self sourceDataType]) {
    case 0: {
        id content = [[self sourceObject] queryHyperInterface:@protocol(HSStringContentAttributes)];
        if (content == nil)
            return nil;
        return [[[content hyperAttributedStringValue] copy] autorelease];
    }
    case 1:
        commented = [[self owner] hyperObjectForAction:self];
        break;
    case 2:
        commented = [_context card];
        break;
    case 3:
        commented = [_context stack];
        break;
    case 4: {
        id comments = [[_context card] queryHyperInterface:@protocol(HSCommentsAttributes)];
        if (comments == nil)
            return nil;
        return [[[NSAttributedString alloc] initWithString:[comments deepComments]] autorelease];
    }
    default:
        return nil;
    }
    id comments = [commented queryHyperInterface:@protocol(HSCommentsAttributes)];
    if (comments == nil)
        return nil;
    return [[[NSAttributedString alloc] initWithString:[comments hyperComments]] autorelease];
}

- (void)updateDestinationObjectIfNeeded
{
    if ([self destinationObject] == nil && _destinationObjectUID != nil)
        [self setDestinationObject:[self objectWithUID:_destinationObjectUID]];
}

- (void)updateSourceObjectIfNeeded
{
    if ([self sourceObject] == nil && _sourceObjectUID != nil)
        [self setSourceObject:[self objectWithUID:_sourceObjectUID]];
}

- (void)setDestinationObject:(id)aObject
{
    if (_destinationObject != aObject) {
        [_destinationObject release];
        _destinationObject = [aObject retain];
    }
}

- (id)destinationObject
{
    return _destinationObject;
}

- (void)setSourceObject:(id)aObject
{
    if (_sourceObject != aObject) {
        [_sourceObject release];
        _sourceObject = [aObject retain];
    }
}

- (id)sourceObject
{
    return _sourceObject;
}

- (id)objectOnCardWithUID:(id)aUID
{
    id container = [[self card] queryHyperInterface:@protocol(HSNodeContainer)];
    if (container == nil)
        return nil;
    NSEnumerator *enumerator = [[container hyperChildren] objectEnumerator];
    id child;
    while ((child = [enumerator nextObject]) != nil) {
        if ([[[child queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID] isEqual:aUID])
            return child;
    }
    return nil;
}

- (id)objectWithUID:(id)aUID
{
    return [[[self stack] queryHyperInterface:@protocol(HSUserObjectUIDBasedAccess)] childInTreeWithUID:aUID];
}

// No copy when the source or destination object is replaced.
- (id)copyReplacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID
{
    if ([aDs containsObject:[self sourceObjectUID]] || [aDs containsObject:[self destinationObjectUID]])
        return nil;
    return [super copyReplacingObjectUIDs:aDs sortedByPriority:aPriority withImageObjectUID:aUID];
}

// Destination action 0 replaces, 1 appends, 2 inserts at the insertion point.
// A move (source action 0) then empties the source unless it is also the
// destination; source action 2 only empties it.
- (void)startInContext:(id)aContext
{
    [self setContext:aContext];
    if ([self isValid]) {
        if (_sourceAction != 2) {
            NSAttributedString *source = [self sourceObjectValue];
            NSAttributedString *destination = [self destinationObjectValue];
            NSMutableAttributedString *value = nil;
            if (_destinationAction == 0) {
                value = [[NSMutableAttributedString alloc] initWithAttributedString:source];
            } else if (_destinationAction == 1) {
                value = [[NSMutableAttributedString alloc] initWithAttributedString:destination];
                [value appendAttributedString:source];
            } else if (_destinationAction == 2) {
                [aContext insertText:[source string] toNode:[[self destinationObject] queryHyperInterface:@protocol(HSNodeAttributes)]];
            }
            if (value != nil) {
                [self setDestinationObjectValue:value];
                [value release];
            }
        }
        if (_sourceAction == 2 || (_sourceAction == 0 && ![_destinationObjectUID isEqual:_sourceObjectUID]))
            [self setSourceObjectValue:[[[NSAttributedString alloc] initWithString:@""] autorelease]];
    }
    [self notifyDidFinish];
    [self setContext:nil];
}

- (id)init
{
    self = [super init];
    if (self != nil)
        _sourceAction = 1;
    return self;
}

- (void)setContext:(id)aContext
{
    if (_context != aContext) {
        [_context release];
        _context = [aContext retain];
    }
}

// Storing drops the destination when the source is only cleared, so loading
// adds those keys back.
- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    NSArray *keys = [super keysForExtraLoadingWithCodingContext:aContext];
    if (_sourceAction == 2)
        keys = [keys arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:@"destinationObjectUID", @"destinationAction", nil]];
    return keys;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithObjects:@"sourceObjectUID", @"doCopy", @"doAppend", @"sourceDataType", @"sourceAction", nil];
    if (_sourceAction != 2) {
        [keys addObject:@"destinationObjectUID"];
        [keys addObject:@"destinationAction"];
    }
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:keys];
}

- (void)dealloc
{
    [_sourceObject release];
    [_destinationObject release];
    [_sourceObjectUID release];
    [_destinationObjectUID release];
    [_context release];
    [super dealloc];
}

- (BOOL)isTextObjectRotationAngleZero:(id)aObject
{
    id adapter = [aObject queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)];
    float angle = [[[adapter queryGeometryBehaviorApplier] mutableGeometryAttributes] rotationAngle];
    if (angle >= -0.01f && angle <= 0.01f)
        return YES;
    return angle >= 6.2731853f && angle <= 6.2931857f;
}

@end
