#import "HSCardGroup.h"
#import "HSCursorSynchronizer.h"
#import "HSImageObjectData.h"
#import "HSMediaFileWrapper.h"
#import "HSUID.h"

@implementation HSCardGroup

- (id)copyWithZone:(NSZone *)aZone
{
    return [[[self class] objectWithExtraDictionary:[self extraDictionaryRepresentation] zone:aZone] retain];
}

- (id)nodeDataForOldVersionsSupport
{
    if (_nodeDataForOldVersionsSupport == nil)
        _nodeDataForOldVersionsSupport = [NSMutableArray new];
    return _nodeDataForOldVersionsSupport;
}

- (void)setCursor:(id)aCursor
{
    if (_cursor != aCursor) {
        [_cursor release];
        _cursor = [aCursor retain];
    }
}

- (id)cursor
{
    if (_cursor != nil && [_cursor imageMedia] == nil)
        [_cursor setImageMedia:[HSNewMedia mediaWithImage:[_cursor image]]];
    return _cursor;
}

- (void)setActor:(id)aActor
{
}

- (id)actor
{
    return nil;
}

- (id)extraDictionaryRepresentationWithCodingContext:(id)aContext
{
    // Border paths of image data are not stored with the group.
    for (id data in _groupData) {
        if ([data isKindOfClass:[HSImageObjectData class]]) {
            [data setBorderPath:nil];
            [data setRelativeBorderPath:nil];
        }
    }

    id representation = [super extraDictionaryRepresentationWithCodingContext:aContext];
    NSUInteger count;
    NSMutableDictionary *units, *roles;
    if (representation != nil && (count = [_nodeUnits count]) != 0
        && (units = [NSMutableDictionary dictionaryWithCapacity:count]) != nil
        && (roles = [NSMutableDictionary dictionaryWithCapacity:count]) != nil) {
        NSEnumerator *enumerator = [_nodeUnits keyEnumerator];
        id uid;
        while ((uid = [enumerator nextObject]) != nil) {
            NSString *key = [uid stringValue];
            if (key == nil)
                continue;
            id unitRepresentation = [[_nodeUnits objectForKey:uid] extraDictionaryRepresentationWithCodingContext:aContext];
            if (unitRepresentation != nil) {
                [units setObject:unitRepresentation forKey:key];
                [roles setObject:[_nodeUnitRoles objectForKey:uid] forKey:key];
            }
        }
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:representation];
        if (dictionary != nil) {
            [dictionary setObject:units forKey:@"nodeUnits"];
            [dictionary setObject:roles forKey:@"nodeUnitRoles"];
            representation = [[dictionary copy] autorelease];
        }
    }
    return representation;
}

- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    id representation = aRepresentation;
    id units = [aRepresentation objectForKey:@"nodeUnits"];
    if (units != nil) {
        id roles = [aRepresentation objectForKey:@"nodeUnitRoles"];
        if (roles != nil) {
            NSEnumerator *enumerator = [units keyEnumerator];
            id key;
            while ((key = [enumerator nextObject]) != nil) {
                id role = [roles objectForKey:key];
                if (role != nil) {
                    id unit = [NSObject objectWithExtraDictionary:[units objectForKey:key]];
                    if (unit != nil)
                        [self addNodeUnit:unit forRole:role];
                }
            }
            representation = [[aRepresentation mutableCopy] autorelease];
            [representation removeObjectForKey:@"nodeUnits"];
            [representation removeObjectForKey:@"nodeUnitRoles"];
        }
    }
    [super loadExtraDictionaryRepresentation:representation withCodingContext:aContext];
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray array];
    [keys addObject:@"groupUID"];
    [keys addObject:[@"groupData" extraKeyForCollection]];
    [keys addObject:@"actor"];
    [keys addObject:@"cursor"];
    return keys;
}

- (id)nodeDataWithUID:(id)aUID
{
    NSEnumerator *enumerator = [[_groupData arrayByAddingObjectsFromArray:[self nodeDataForOldVersionsSupport]] objectEnumerator];
    id data;
    while ((data = [enumerator nextObject]) != nil) {
        if ([[data nodeDataUID] isEqual:aUID])
            return data;
    }
    return nil;
}

- (void)removeData:(id)aData
{
    [_groupData removeObject:aData];
}

- (void)addData:(id)aData
{
    [_groupData addObject:aData];
}

- (id)dataEnumerator
{
    return [_groupData objectEnumerator];
}

- (void)setGroupData:(id)aData
{
    [aData retain];
    [_groupData release];
    _groupData = aData;
}

- (id)groupData
{
    return _groupData;
}

- (id)nodeUnitEnumerator
{
    return [_nodeUnits objectEnumerator];
}

- (id)nodeUnitRoleEnumerator
{
    return [_nodeUnitRoles objectEnumerator];
}

- (id)nodeUnitWithUID:(id)aUID
{
    return [_nodeUnits objectForKey:aUID];
}

- (id)roleOfNodeUnitWithUID:(id)aUID
{
    return [_nodeUnitRoles objectForKey:aUID];
}

- (void)removeNodeUnit:(id)aUnit
{
    id uid = [aUnit UID];
    [_nodeUnits removeObjectForKey:uid];
    [_nodeUnitRoles removeObjectForKey:uid];
}

- (void)addNodeUnit:(id)aUnit forRole:(id)aRole
{
    id uid = [aUnit UID];
    [_nodeUnits setObject:aUnit forKey:uid];
    [_nodeUnitRoles setObject:aRole forKey:uid];
}

- (void)setNodeUnits:(id)aUnits
{
    if (_nodeUnits != aUnits) {
        [aUnits retain];
        [_nodeUnits release];
        _nodeUnits = aUnits;
    }
}

- (id)nodeUnits
{
    return _nodeUnits;
}

- (void)setNodeUnitRoles:(id)aRoles
{
    if (_nodeUnitRoles != aRoles) {
        [aRoles retain];
        [_nodeUnitRoles release];
        _nodeUnitRoles = aRoles;
    }
}

- (id)nodeUnitRoles
{
    return _nodeUnitRoles;
}

- (void)setGroupUID:(id)aUID
{
    [aUID retain];
    [_groupUID release];
    _groupUID = aUID;
}

- (id)groupUID
{
    return _groupUID;
}

- (void)dealloc
{
    [_groupData release];
    [_nodeUnitRoles release];
    [_nodeUnits release];
    [_groupUID release];
    [_cursor release];
    [_nodeDataForOldVersionsSupport release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _groupUID = [[HSUID UID] retain];
        _nodeUnits = [NSMutableDictionary new];
        _nodeUnitRoles = [NSMutableDictionary new];
        _groupData = [NSMutableArray new];
    }
    return self;
}

@end
