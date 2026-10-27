#import "HSMoveToFrontAction.h"

// "Move to front" action: brings the source object to the top of its parent.
@implementation HSMoveToFrontAction
- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    if (![self isValid])
        return nil;
    id dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
    [dictionary setObject:[_sourceObjectUID stringValue] forKey:@"object"];
    return dictionary;
}
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}
- (BOOL)isValid
{
    id UID = [self sourceObjectUID];
    if (UID == nil)
        return NO;
    id object = [self objectWithUID:UID];
    return object != nil && [object hyperParent] != nil;
}
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    [super importFromXMLElementRepresentation:aRepresentation inContext:aContext];
    NSString *UIDString = [[aRepresentation attributeForName:@"sourceObjectUID"] stringValue];
    if (UIDString)
        [self setSourceObjectUID:[HSUID UIDWithString:UIDString]];
}
- (id)XMLElementRepresentationInContext:(id)aContext
{
    id element = [super XMLElementRepresentationInContext:aContext];
    [element addAttribute:[NSXMLNode attributeWithName:@"sourceObjectUID" stringValue:[[self sourceObjectUID] stringValue]]];
    return element;
}
- (id)XMLElementName
{
    return @"actMoveToFront";
}
- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}
- (BOOL)supportedInIPad
{
    return YES;
}
- (void)ownerDidChange
{
    [self updateSourceObjectIfNeeded];
}
- (void)ownerWillChange
{
    [self setSourceObject:nil];
}
- (void)didConnectToDocument
{
    [self updateSourceObjectIfNeeded];
}
- (void)willDisconnectFromDocument
{
    [self setSourceObject:nil];
}
- (void)setSourceObjectUID:(id)aUID
{
    if ([_sourceObjectUID isEqual:aUID])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Source Object" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setSourceObjectUID:[self sourceObjectUID]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSMoveToFrontSourceObjectUIDAttribute) ofObject:self withUserInfo:nil];
    [self setSourceObject:nil];
    [_sourceObjectUID release];
    _sourceObjectUID = [aUID retain];
    [self setSourceObject:[self objectWithUID:_sourceObjectUID]];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSMoveToFrontSourceObjectUIDAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}
- (id)sourceObjectUID
{
    return _sourceObjectUID;
}
- (void)updateSourceObjectIfNeeded
{
    if ([self sourceObject] == nil && _sourceObjectUID)
        [self setSourceObject:[self objectWithUID:_sourceObjectUID]];
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
- (id)objectWithUID:(id)aUID
{
    return [[[self stack] queryHyperInterface:@protocol(HSUserObjectUIDBasedAccess)] childInTreeWithUID:aUID];
}
- (void)startInContext:(id)aContext
{
    [self setContext:aContext];
    if ([self isValid])
        [[self sourceObject] moveToHyperEnd];
    [self setContext:nil];
    [self notifyDidFinish];
}
- (id)copyReplacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID
{
    id copy = [super copyReplacingObjectUIDs:aDs sortedByPriority:aPriority withImageObjectUID:aUID];
    if (copy && [aDs containsObject:[copy sourceObjectUID]])
        [copy setSourceObjectUID:aUID];
    return copy;
}
- (void)setContext:(id)aContext
{
    if (_context != aContext) {
        [_context release];
        _context = [aContext retain];
    }
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:@"sourceObjectUID", nil]];
}
- (void)dealloc
{
    [_sourceObject release];
    [_sourceObjectUID release];
    [super dealloc]; // Original never releases _context (it is cleared after each run).
}
@end
