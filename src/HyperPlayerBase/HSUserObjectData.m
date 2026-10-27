#import "HSUserObjectData.h"
#import "HSActor.h"
#import "HSCursorSynchronizer.h"
#import "HSMediaFileWrapper.h"
#import "HSUID.h"

@implementation HSUserObjectData

- (id)copyWithZone:(NSZone *)aZone
{
    id copy = [super copyWithZone:aZone];
    [copy setUID:[HSUID UID]];
    return copy;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraStoringWithCodingContext:aContext]];
    if ([[aContext codingOperation] isEqualToString:@"HSObjectStyleCodingOperation"]) {
        [keys removeAllObjects];
    } else {
        [keys addObject:@"UID"];
        [keys addObject:@"actor"];
        [keys addObject:@"cursor"];
        [keys addObject:HSUserObjectNameSerializationKey];
        [keys addObject:@"usingTemplateName"];
        [keys addObject:@"comments"];
    }
    return keys;
}

- (id)enumeratorForGenerator:(id)aGenerator
{
    if ([[[self owner] objectsWithNodeDataUID:[self nodeDataUID]] count] == 0)
        return nil;
    // Names are unique within the stack, else the card, else the object itself.
    id scope = [[[self owner] anyOwningObjectForNodeData:self] stack];
    if (scope == nil)
        scope = [[[self owner] anyOwningObjectForNodeData:self] card];
    if (scope == nil)
        scope = [[self owner] anyOwningObjectForNodeData:self];
    return [scope enumeratorForGenerator:aGenerator];
}

- (id)otherActorsFromGroup:(id)aGroup
{
    if (![[self owner] respondsToSelector:@selector(otherActorsFromGroup:)])
        return nil;
    return [[self owner] otherActorsFromGroup:aGroup];
}

- (id)hyperObjectForActor:(id)aActor
{
    if (![self hasOwner])
        return nil;
    return [[self owner] anyOwningObjectForNodeData:self];
}

- (void)willRemoveOwningObjectFromDocument:(id)aDocument
{
}

- (void)didAddOwningObjectToDocument:(id)aDocument
{
}

- (void)setComments:(id)aComments
{
    if (_comments != aComments) {
        [_comments release];
        _comments = [aComments retain];
    }
}

- (id)comments
{
    return _comments ? _comments : [NSString string];
}

- (void)setAttributeToNotificationMap:(id)aMap
{
    [aMap retain];
    [_attributeToNotificationMap release];
    _attributeToNotificationMap = aMap;
}

- (id)attributeToNotificationMap
{
    return _attributeToNotificationMap;
}

- (void)setPreferredNameTemplate:(id)aTemplate
{
    [aTemplate retain];
    [_preferredNameTemplate release];
    _preferredNameTemplate = aTemplate;
}

- (id)preferredNameTemplate
{
    return _preferredNameTemplate;
}

- (void)setNameGenerator:(id)aGenerator
{
    [aGenerator retain];
    [_nameGenerator release];
    _nameGenerator = aGenerator;
}

- (id)nameGenerator
{
    return _nameGenerator;
}

- (void)setUsingTemplateName:(BOOL)aName
{
    _usingTemplateName = aName;
}

- (BOOL)usingTemplateName
{
    return _usingTemplateName;
}

- (void)setName:(id)aName
{
    [aName retain];
    [_name release];
    _name = aName;
}

- (id)name
{
    return _name;
}

- (void)setCursor:(id)aCursor
{
    [aCursor retain];
    [_cursor release];
    _cursor = aCursor;
}

- (id)cursor
{
    // Older cursors carry only an image; wrap it in a media object on demand.
    if (_cursor != nil && [_cursor imageMedia] == nil)
        [_cursor setImageMedia:[HSNewMedia mediaWithImage:[_cursor image]]];
    return _cursor;
}

- (void)setActor:(id)aActor
{
    [_actor setOwner:nil];
    [aActor retain];
    [_actor release];
    _actor = aActor;
    [aActor setOwner:self];
}

- (id)actor
{
    return _actor;
}

- (void)setUID:(id)aUID
{
    [aUID retain];
    [_UID release];
    _UID = aUID;
}

- (id)UID
{
    return _UID;
}

- (void)dealloc
{
    [_attributeToNotificationMap release];
    [_preferredNameTemplate release];
    [_nameGenerator release];
    [_name release];
    [_cursor release];
    [_actor setOwner:nil];
    [_actor release];
    [_UID release];
    [_comments release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _UID = [[HSUID UID] retain];
        _actor = [HSActor new];
        [_actor setOwner:self];
        _usingTemplateName = NO;
    }
    return self;
}

@end
