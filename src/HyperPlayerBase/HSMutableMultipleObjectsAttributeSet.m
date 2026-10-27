#import "HSMutableMultipleObjectsAttributeSet.h"
#import "HSPointer.h"
#import "NSEMutableProtocolSet.h"
#import "SMKApplicationKitData.h"

typedef HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetImplementation HSMOASImplementation;
typedef HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetObservingSession HSMOASObservingSession;
typedef HSMultipleObjectsAttributeSet_HSObjectAttributes HSMOASObjectAttributes;

@interface NSObject (HSMutableMultipleObjectsAttributeSet)
- (BOOL)isMutable;
- (NSUInteger)hyperIdentifier;
- (BOOL)isEqualToMultipleObjectsAttributeSetImplementation:(id)aImplementation;
- (void)backwardRelease;
- (id)backwardRetain;
@end

@implementation HSMultipleObjectsAttributeSet

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges
{
    [(HSMOASImplementation *)_implementation removeObserver:aObserver selector:aSelector ofChanges:aChanges];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges withPriority:(CGFloat)aPriority
{
    [(HSMOASImplementation *)_implementation addObserver:aObserver selector:aSelector ofChanges:aChanges withPriority:aPriority];
}

- (id)sharedObservingSessionForChanges:(NSUInteger)aChanges withPriority:(CGFloat)aPriority
{
    return [(HSMOASImplementation *)_implementation sharedObservingSessionForChanges:aChanges withPriority:aPriority];
}

- (NSUInteger)hash
{
    return [_implementation hash];
}

- (BOOL)isEqual:(id)aEqual
{
    if (aEqual == self)
        return YES;
    if (![aEqual isKindOfClass:[HSMultipleObjectsAttributeSet class]])
        return NO;
    Class selfClass = [self class];
    if ([aEqual isKindOfClass:selfClass] && ![aEqual isMemberOfClass:selfClass])
        return [aEqual isEqual:self];
    return [self isEqualToMultipleObjectsAttributeSet:aEqual];
}

- (BOOL)isEqualToMultipleObjectsAttributeSet:(id)aSet
{
    if (self == aSet)
        return YES;
    if (_implementation != nil) {
        id otherImplementation = [aSet HSMultipleObjectsAttributeSet_protected_implementation];
        if (otherImplementation != nil)
            return [_implementation isEqualToMultipleObjectsAttributeSetImplementation:otherImplementation];
    }
    return [(HSMultipleObjectsAttributeSet *)aSet objectCount] == 0;
}

- (id)allObjects
{
    if (_implementation == nil)
        return [NSArray array];
    return [_implementation allObjects];
}

- (id)attributesForObject:(id)aObject
{
    return [(HSMOASImplementation *)_implementation attributesForObject:aObject];
}

- (id)objectEnumerator
{
    if (_implementation == nil)
        return [[[HSMultipleObjectsAttributeSet_HSEmptyObjectEnumerator alloc] init] autorelease];
    return [_implementation objectEnumerator];
}

- (BOOL)excludesAttributeSet:(id)aSet forObject:(id)aObject
{
    if (_implementation == nil)
        return YES;
    return [(HSMOASImplementation *)_implementation excludesAttributeSet:aSet forObject:aObject];
}

- (BOOL)intersectsAttributeSet:(id)aSet forObject:(id)aObject
{
    return [(HSMOASImplementation *)_implementation intersectsAttributeSet:aSet forObject:aObject];
}

- (BOOL)includesAttribute:(id)aAttribute forObject:(id)aObject
{
    return [(HSMOASImplementation *)_implementation includesAttribute:aAttribute forObject:aObject];
}

- (BOOL)containsAttribute:(id)aAttribute forObject:(id)aObject
{
    return [(HSMOASImplementation *)_implementation containsAttribute:aAttribute forObject:aObject];
}

- (NSUInteger)attributeCountForObject:(id)aObject
{
    return [(HSMOASImplementation *)_implementation attributeCountForObject:aObject];
}

- (NSUInteger)objectCount
{
    return [(HSMOASImplementation *)_implementation objectCount];
}

- (id)description
{
    id mapDescription = (_implementation == nil) ? @" " : [(HSMOASImplementation *)_implementation objectToAttributesMapDescription];
    // The original used 0x%x for the pointer.
    return [NSString stringWithFormat:@"<%@: %p>{%@}", NSStringFromClass([self class]), self, mapDescription];
}

- (id)mutableCopyWithZone:(NSZone *)aZone
{
    return [[HSMutableMultipleObjectsAttributeSet allocWithZone:aZone] initWithMultipleObjectsAttributeSet:self];
}

- (id)copyWithZone:(NSZone *)aZone
{
    return [self retain];
}

- (void)dealloc
{
    [_implementation release];
    [super dealloc];
}

- (id)initWithMultipleObjectsAttributeSet:(id)aSet
{
    self = [self init];
    if (self != nil)
        _implementation = [[aSet HSMultipleObjectsAttributeSet_protected_implementation] retain];
    return self;
}

- (void)HSMultipleObjectsAttributeSet_protected_removeAllAttributes
{
    if ([_implementation isMutable]) {
        [(HSMOASImplementation *)_implementation removeAllAttributes];
    } else {
        [_implementation release];
        _implementation = nil;
    }
}

- (void)HSMultipleObjectsAttributeSet_protected_setImplementation:(id)aImplementation
{
    if (_implementation != aImplementation) {
        [aImplementation retain];
        [_implementation release];
        _implementation = aImplementation;
    }
}

- (id)HSMultipleObjectsAttributeSet_protected_mutableImplementationForExpanding:(BOOL)aExpanding
{
    if (_implementation == nil) {
        if (aExpanding)
            _implementation = [[HSMOASImplementation allocWithZone:[self zone]] init];
    } else if (![_implementation isMutable]) {
        id copy = [_implementation copyWithZone:[self zone]];
        [_implementation release];
        _implementation = copy;
    }
    return _implementation;
}

- (id)HSMultipleObjectsAttributeSet_protected_implementation
{
    return _implementation;
}

@end

@implementation HSMutableMultipleObjectsAttributeSet

- (void)setMultipleObjectsAttributeSet:(id)aSet
{
    [self HSMultipleObjectsAttributeSet_protected_setImplementation:[aSet HSMultipleObjectsAttributeSet_protected_implementation]];
}

- (void)unionMultipleObjectsAttributeSet:(id)aSet
{
    HSMOASImplementation *otherImplementation = [aSet HSMultipleObjectsAttributeSet_protected_implementation];
    if ([otherImplementation objectCount] == 0)
        return;
    if ([(HSMOASImplementation *)[self HSMultipleObjectsAttributeSet_protected_implementation] objectCount] != 0)
        [[self HSMultipleObjectsAttributeSet_protected_mutableImplementationForExpanding:YES] unionMultipleObjectsAttributeSetImplementation:otherImplementation];
    else
        [self HSMultipleObjectsAttributeSet_protected_setImplementation:otherImplementation];
}

- (void)minusMultipleObjectsAttributeSet:(id)aSet
{
    HSMOASImplementation *otherImplementation = [aSet HSMultipleObjectsAttributeSet_protected_implementation];
    if ([otherImplementation objectCount] != 0)
        [[self HSMultipleObjectsAttributeSet_protected_mutableImplementationForExpanding:NO] minusMultipleObjectsAttributeSetImplementation:otherImplementation];
}

- (void)intersectMultipleObjectsAttributeSet:(id)aSet
{
    HSMOASImplementation *otherImplementation = [aSet HSMultipleObjectsAttributeSet_protected_implementation];
    if ([otherImplementation objectCount] != 0)
        [[self HSMultipleObjectsAttributeSet_protected_mutableImplementationForExpanding:NO] intersectMultipleObjectsAttributeSetImplementation:otherImplementation];
    else
        [self HSMultipleObjectsAttributeSet_protected_removeAllAttributes];
}

- (void)removeAllAttributes
{
    [self HSMultipleObjectsAttributeSet_protected_removeAllAttributes];
}

- (void)removeAttributesForObject:(id)aObject
{
    [[self HSMultipleObjectsAttributeSet_protected_mutableImplementationForExpanding:NO] removeAttributesForObject:aObject];
}

- (void)removeAttributes:(id)aAttributes forObject:(id)aObject
{
    [[self HSMultipleObjectsAttributeSet_protected_mutableImplementationForExpanding:NO] removeAttributes:aAttributes forObject:aObject];
}

- (void)removeAttribute:(id)aAttribute forObject:(id)aObject
{
    [[self HSMultipleObjectsAttributeSet_protected_mutableImplementationForExpanding:NO] removeAttribute:aAttribute forObject:aObject];
}

- (void)addAttributes:(id)aAttributes forObject:(id)aObject
{
    [[self HSMultipleObjectsAttributeSet_protected_mutableImplementationForExpanding:YES] addAttributes:aAttributes forObject:aObject];
}

- (void)addAttribute:(id)aAttribute forObject:(id)aObject
{
    [[self HSMultipleObjectsAttributeSet_protected_mutableImplementationForExpanding:YES] addAttribute:aAttribute forObject:aObject];
}

- (id)copyWithZone:(NSZone *)aZone
{
    return [[HSMultipleObjectsAttributeSet allocWithZone:aZone] initWithMultipleObjectsAttributeSet:self];
}

@end

// Observing sessions are keyed by priority and changes packed into one integer.
static CFStringRef HSMOASSessionKeyCopyDescription(const void *aKey)
{
    uintptr_t key = (uintptr_t)aKey;
    return CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("<%f %u>"), (double)(uint32_t)(key >> 16) * 0.0001 - 1.0, (unsigned int)(key & 0xffff));
}

static const void *HSMOASSessionRetain(CFAllocatorRef aAllocator, const void *aValue)
{
    return [(id)aValue backwardRetain];
}

static void HSMOASSessionRelease(CFAllocatorRef aAllocator, const void *aValue)
{
    [(id)aValue backwardRelease];
}

static CFStringRef HSMOASSessionCopyDescription(const void *aValue)
{
    return (CFStringRef)[[(id)aValue description] retain];
}

@implementation HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetImplementation

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges
{
    NSMapTable *map = [_objectToAttributesMapPointer pointer];
    if (map == NULL)
        return;
    NSMapEnumerator enumerator = NSEnumerateMapTable(map);
    HSMOASObjectAttributes *value = nil;
    while (NSNextMapEnumeratorPair(&enumerator, NULL, (void **)&value)) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        id controller = [[[value object] queryHyperInterface:@protocol(HSAttributes)] attributeObservingController];
        Protocol **protocols = [[value attributes] allProtocols];
        if (protocols != NULL)
            [controller removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:(id *)protocols];
        [pool release];
    }
    NSEndMapTableEnumeration(&enumerator);
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges withPriority:(CGFloat)aPriority
{
    NSMapTable *map = [_objectToAttributesMapPointer pointer];
    if (map == NULL)
        return;
    NSMapEnumerator enumerator = NSEnumerateMapTable(map);
    HSMOASObjectAttributes *value = nil;
    while (NSNextMapEnumeratorPair(&enumerator, NULL, (void **)&value)) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        id controller = [[[value object] queryHyperInterface:@protocol(HSAttributes)] attributeObservingController];
        Protocol **protocols = [[value attributes] allProtocols];
        if (protocols != NULL)
            [controller addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:(id *)protocols withPriority:aPriority];
        [pool release];
    }
    NSEndMapTableEnumeration(&enumerator);
}

- (id)sharedObservingSessionForChanges:(NSUInteger)aChanges withPriority:(CGFloat)aPriority
{
    uintptr_t key = ((uint32_t)lroundf((float)aPriority * 10000.0f) * 0x10000u + 0x27100000u) | (uint32_t)aChanges;
    if (_observingSessions == NULL) {
        CFDictionaryKeyCallBacks keyCallBacks = { 0, NULL, NULL, HSMOASSessionKeyCopyDescription, NULL, NULL };
        CFDictionaryValueCallBacks valueCallBacks = { 0, HSMOASSessionRetain, HSMOASSessionRelease, HSMOASSessionCopyDescription, NULL };
        _observingSessions = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &keyCallBacks, &valueCallBacks);
        if (_observingSessions == NULL)
            return nil;
    } else {
        id session = (id)CFDictionaryGetValue(_observingSessions, (const void *)key);
        if (session != nil)
            return session;
    }
    id session = [[HSMOASObservingSession alloc] initWithMultipleObjectsAttributeSetImplementation:self changesToObserve:aChanges withPriority:aPriority];
    if (session != nil) {
        CFDictionaryAddValue(_observingSessions, (const void *)key, session);
        [session release];
    }
    return session;
}

- (void)unionMultipleObjectsAttributeSetImplementation:(id)aImplementation
{
    NSMapTable *otherMap = [aImplementation HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetImplementation_objectToAttributesMap];
    if (otherMap == NULL)
        return;
    NSMapEnumerator enumerator = NSEnumerateMapTable(otherMap);
    HSMOASObjectAttributes *value = nil;
    while (NSNextMapEnumeratorPair(&enumerator, NULL, (void **)&value))
        [self HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetImplementation_mutableAttributeSetForObject:[value object] addingAttributes:[value attributes]];
    NSEndMapTableEnumeration(&enumerator);
}

- (void)minusMultipleObjectsAttributeSetImplementation:(id)aImplementation
{
    NSMapTable *map = [_objectToAttributesMapPointer pointer];
    if (map == NULL)
        return;
    NSMapTable *otherMap = [aImplementation HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetImplementation_objectToAttributesMap];
    if (otherMap == NULL)
        return;
    NSMapEnumerator enumerator = NSEnumerateMapTable(otherMap);
    void *key = NULL;
    HSMOASObjectAttributes *value = nil;
    while (NSNextMapEnumeratorPair(&enumerator, &key, (void **)&value)) {
        NSEMutableProtocolSet *attributes = [(HSMOASObjectAttributes *)NSMapGet(map, key) attributes];
        if (attributes != nil) {
            [attributes minusProtocolSet:[value attributes]];
            if ([attributes count] == 0)
                NSMapRemove(map, key);
        }
    }
    NSEndMapTableEnumeration(&enumerator);
}

- (void)intersectMultipleObjectsAttributeSetImplementation:(id)aImplementation
{
    NSMapTable *map = [_objectToAttributesMapPointer pointer];
    if (map == NULL)
        return;
    NSMapTable *otherMap = [aImplementation HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetImplementation_objectToAttributesMap];
    if (otherMap == NULL || NSCountMapTable(otherMap) == 0) {
        NSResetMapTable(map);
        return;
    }
    id keysToRemove = nil;
    NSMapEnumerator enumerator = NSEnumerateMapTable(map);
    void *key = NULL;
    HSMOASObjectAttributes *value = nil;
    while (NSNextMapEnumeratorPair(&enumerator, &key, (void **)&value)) {
        NSEMutableProtocolSet *otherAttributes = [(HSMOASObjectAttributes *)NSMapGet(otherMap, key) attributes];
        if (otherAttributes != nil) {
            NSEMutableProtocolSet *attributes = [value attributes];
            [attributes intersectProtocolSet:otherAttributes];
            if ([attributes count] != 0)
                continue;
        }
        [self HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetImplementation_addObjectIdentifier:(NSUInteger)key toDataArray:&keysToRemove];
    }
    NSEndMapTableEnumeration(&enumerator);
    if (keysToRemove != nil) {
        const NSUInteger *identifier = [keysToRemove bytes];
        const NSUInteger *end = (const NSUInteger *)((const char *)[keysToRemove bytes] + [keysToRemove length]);
        for (; identifier < end; identifier++)
            NSMapRemove(map, (const void *)*identifier);
    }
}

- (void)HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetImplementation_addObjectIdentifier:(NSUInteger)aIdentifier toDataArray:(id *)aArray
{
    // The original stored 4-byte identifiers.
    if (*aArray == nil)
        *aArray = [NSMutableData dataWithBytes:&aIdentifier length:sizeof(aIdentifier)];
    else
        [*aArray appendBytes:&aIdentifier length:sizeof(aIdentifier)];
}

- (void)removeAllAttributes
{
    NSMapTable *map = [_objectToAttributesMapPointer pointer];
    if (map != NULL)
        NSResetMapTable(map);
}

- (void)removeAttributesForObject:(id)aObject
{
    NSMapTable *map = [_objectToAttributesMapPointer pointer];
    if (map != NULL)
        NSMapRemove(map, (const void *)[aObject hyperIdentifier]);
}

- (void)removeAttributes:(id)aAttributes forObject:(id)aObject
{
    NSMapTable *map = [_objectToAttributesMapPointer pointer];
    if (map == NULL)
        return;
    const void *key = (const void *)[aObject hyperIdentifier];
    NSEMutableProtocolSet *attributes = [(HSMOASObjectAttributes *)NSMapGet(map, key) attributes];
    if (attributes != nil) {
        [attributes minusProtocolSet:aAttributes];
        if ([attributes count] == 0)
            NSMapRemove(map, key);
    }
}

- (void)removeAttribute:(id)aAttribute forObject:(id)aObject
{
    NSMapTable *map = [_objectToAttributesMapPointer pointer];
    if (map == NULL)
        return;
    const void *key = (const void *)[aObject hyperIdentifier];
    NSEMutableProtocolSet *attributes = [(HSMOASObjectAttributes *)NSMapGet(map, key) attributes];
    if (attributes == nil)
        return;
    NSUInteger count = [attributes count];
    if (count == 1) {
        if ([attributes containsProtocol:aAttribute])
            NSMapRemove(map, key);
    } else if (count != 0) {
        [attributes removeProtocol:aAttribute];
    }
}

- (void)addAttributes:(id)aAttributes forObject:(id)aObject
{
    [self HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetImplementation_mutableAttributeSetForObject:aObject addingAttributes:aAttributes];
}

- (void)addAttribute:(id)aAttribute forObject:(id)aObject
{
    [[self HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetImplementation_mutableAttributeSetForObject:aObject addingAttributes:nil] addProtocol:aAttribute];
}

- (id)HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetImplementation_mutableAttributeSetForObject:(id)aObject addingAttributes:(id)aAttributes
{
    NSMapTable *map = [self HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetImplementation_mutableObjectToAttributesMap];
    if (map == NULL)
        return nil;
    const void *key = (const void *)[aObject hyperIdentifier];
    NSEMutableProtocolSet *attributes = [(HSMOASObjectAttributes *)NSMapGet(map, key) attributes];
    if (attributes == nil) {
        HSMOASObjectAttributes *value = [[HSMOASObjectAttributes allocWithZone:[self zone]] initWithObject:aObject attributes:aAttributes];
        if (value != nil) {
            NSMapInsert(map, key, value);
            [value release];
            attributes = [value attributes];
        }
    } else if (aAttributes != nil) {
        [attributes unionProtocolSet:aAttributes];
    }
    return attributes;
}

- (id)HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetImplementation_mutableObjectToAttributesMap
{
    NSMapTable *map = [_objectToAttributesMapPointer pointer];
    if (map == NULL) {
        NSZone *zone = [self zone];
        map = NSCreateMapTableWithZone(NSIntegerMapKeyCallBacks, NSObjectMapValueCallBacks, 0, zone);
        if (map != NULL) {
            [_objectToAttributesMapPointer release];
            _objectToAttributesMapPointer = [[HSPointer allocWithZone:zone] initWithPointer:map disposer:(void *)NSFreeMapTable];
            if (_objectToAttributesMapPointer == nil) {
                NSFreeMapTable(map);
                map = NULL;
            }
        }
    }
    return (id)map;
}

- (id)allObjects
{
    NSMapTable *map = [_objectToAttributesMapPointer pointer];
    if (map == NULL || NSCountMapTable(map) == 0)
        return [NSArray array];
    NSMutableArray *objects = [NSMutableArray array];
    NSMapEnumerator enumerator = NSEnumerateMapTable(map);
    HSMOASObjectAttributes *value = nil;
    while (NSNextMapEnumeratorPair(&enumerator, NULL, (void **)&value))
        [objects addObject:[value object]];
    NSEndMapTableEnumeration(&enumerator);
    return [[objects copy] autorelease];
}

- (id)attributesForObject:(id)aObject
{
    return [[[self HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetImplementation_attributeSetForObject:aObject] copy] autorelease];
}

- (id)objectEnumerator
{
    if (_objectToAttributesMapPointer == nil)
        return [[[HSMultipleObjectsAttributeSet_HSEmptyObjectEnumerator alloc] init] autorelease];
    return [[[HSMultipleObjectsAttributeSet_HSObjectEnumerator alloc] initWithObjectToAttributesMapPointer:_objectToAttributesMapPointer] autorelease];
}

- (BOOL)excludesAttributeSet:(id)aSet forObject:(id)aObject
{
    if ([(NSEProtocolSet *)aSet count] == 0)
        return YES;
    NSEMutableProtocolSet *attributes = [self HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetImplementation_attributeSetForObject:aObject];
    if (attributes == nil)
        return YES;
    id adoptedProtocols = [aSet copyAdoptedProtocols];
    if (adoptedProtocols == nil)
        return YES;
    BOOL excludes = YES;
    for (Protocol *protocol in adoptedProtocols) {
        if ([attributes containsProtocol:protocol]) {
            excludes = NO;
            break;
        }
    }
    [adoptedProtocols release];
    return excludes;
}

- (BOOL)intersectsAttributeSet:(id)aSet forObject:(id)aObject
{
    if ([(NSEProtocolSet *)aSet count] == 0)
        return NO;
    return [[self HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetImplementation_attributeSetForObject:aObject] intersectsProtocolSet:aSet];
}

- (BOOL)includesAttribute:(id)aAttribute forObject:(id)aObject
{
    NSEMutableProtocolSet *attributes = [self HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetImplementation_attributeSetForObject:aObject];
    if (attributes == nil)
        return NO;
    NSEProtocolSet *adoptedProtocols = [[NSEProtocolSet alloc] initWithProtocolsAdoptedByProtocol:aAttribute];
    if (adoptedProtocols == nil)
        return NO;
    BOOL includes = NO;
    for (Protocol *protocol in adoptedProtocols) {
        if ([attributes containsProtocol:protocol]) {
            includes = YES;
            break;
        }
    }
    [adoptedProtocols release];
    return includes;
}

- (BOOL)containsAttribute:(id)aAttribute forObject:(id)aObject
{
    return [[self HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetImplementation_attributeSetForObject:aObject] containsProtocol:aAttribute];
}

- (NSUInteger)attributeCountForObject:(id)aObject
{
    return [[self HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetImplementation_attributeSetForObject:aObject] count];
}

- (NSUInteger)objectCount
{
    NSMapTable *map = [_objectToAttributesMapPointer pointer];
    return map == NULL ? 0 : NSCountMapTable(map);
}

- (BOOL)isMutable
{
    // Shared implementations are copied on write; only a sole owner without
    // observing sessions may modify in place.
    return _observingSessions == NULL && [self retainCount] == 1;
}

- (id)HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetImplementation_attributeSetForObject:(id)aObject
{
    NSMapTable *map = [_objectToAttributesMapPointer pointer];
    if (map == NULL)
        return nil;
    return [(HSMOASObjectAttributes *)NSMapGet(map, (const void *)[aObject hyperIdentifier]) attributes];
}

- (id)description
{
    // The original used 0x%x for the pointer.
    return [NSString stringWithFormat:@"<%@: %p>{%@}", NSStringFromClass([self class]), self, [self objectToAttributesMapDescription]];
}

- (id)objectToAttributesMapDescription
{
    NSMapTable *map = [_objectToAttributesMapPointer pointer];
    if (map == NULL)
        return @" ";
    NSMutableString *description = nil;
    NSMapEnumerator enumerator = NSEnumerateMapTable(map);
    HSMOASObjectAttributes *value = nil;
    while (NSNextMapEnumeratorPair(&enumerator, NULL, (void **)&value)) {
        id object = [value object];
        id attributesDescription = [self HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetImplementation_descriptionForAttributes:[value attributes]];
        // The original used 0x%x for the pointer.
        if (description == nil)
            description = [NSMutableString stringWithFormat:@"\n<%@: %p>: {%@}", NSStringFromClass([object class]), object, attributesDescription];
        else
            [description appendFormat:@",\n<%@: %p>: {%@}", NSStringFromClass([object class]), object, attributesDescription];
    }
    NSEndMapTableEnumeration(&enumerator);
    if (description == nil)
        return @" ";
    [description appendString:@"\n"];
    return description;
}

- (id)HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetImplementation_descriptionForAttributes:(id)aAttributes
{
    if ([(NSEProtocolSet *)aAttributes count] == 0)
        return @" ";
    NSMutableString *description = nil;
    for (Protocol *protocol in (NSEProtocolSet *)aAttributes) {
        // The original fell back to -name before Mac OS X 10.5.
        if (description == nil) {
            description = [NSMutableString stringWithFormat:@"%s", protocol_getName(protocol)];
            if (description == nil)
                return nil;
        } else {
            [description appendFormat:@", %s", protocol_getName(protocol)];
        }
    }
    return description;
}

- (NSUInteger)hash
{
    return [self objectCount];
}

- (BOOL)isEqual:(id)aEqual
{
    if (aEqual == self)
        return YES;
    if (![aEqual isKindOfClass:[HSMOASImplementation class]])
        return NO;
    Class selfClass = [self class];
    if ([aEqual isKindOfClass:selfClass] && ![aEqual isMemberOfClass:selfClass])
        return [aEqual isEqual:self];
    return [self isEqualToMultipleObjectsAttributeSetImplementation:aEqual];
}

- (BOOL)isEqualToMultipleObjectsAttributeSetImplementation:(id)aImplementation
{
    if (self == aImplementation)
        return YES;
    NSMapTable *map = [_objectToAttributesMapPointer pointer];
    if (map == NULL)
        return [(HSMOASImplementation *)aImplementation objectCount] == 0;
    NSMapTable *otherMap = [aImplementation HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetImplementation_objectToAttributesMap];
    if (otherMap == NULL)
        return NSCountMapTable(map) == 0;
    if (NSCountMapTable(otherMap) != NSCountMapTable(map))
        return NO;
    NSMapEnumerator enumerator = NSEnumerateMapTable(otherMap);
    void *key = NULL;
    HSMOASObjectAttributes *value = nil;
    BOOL equal = YES;
    while (NSNextMapEnumeratorPair(&enumerator, &key, (void **)&value)) {
        if (![[(HSMOASObjectAttributes *)NSMapGet(map, key) attributes] isEqualToProtocolSet:[value attributes]]) {
            equal = NO;
            break;
        }
    }
    NSEndMapTableEnumeration(&enumerator);
    return equal;
}

- (id)HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetImplementation_objectToAttributesMap
{
    return [_objectToAttributesMapPointer pointer];
}

- (id)copyWithZone:(NSZone *)aZone
{
    return [[HSMOASImplementation allocWithZone:aZone] initWithObjectToAttributesMap:[_objectToAttributesMapPointer pointer]];
}

- (oneway void)release
{
    // Sessions retain their implementation back; break the cycle on the last release.
    if ([self retainCount] == 1 && _observingSessions != NULL) {
        CFRelease(_observingSessions);
        _observingSessions = NULL;
    }
    [super release];
}

- (void)dealloc
{
    [_objectToAttributesMapPointer release];
    [super dealloc];
}

- (id)initWithObjectToAttributesMap:(id)aMap
{
    self = [super init];
    if (self == nil)
        return nil;
    NSMapTable *sourceMap = (NSMapTable *)aMap;
    if (sourceMap == NULL || NSCountMapTable(sourceMap) == 0)
        return self;
    NSZone *zone = [super zone];
    NSMapTable *map = NSCopyMapTableWithZone(sourceMap, zone);
    if (map != NULL) {
        _objectToAttributesMapPointer = [[HSPointer allocWithZone:zone] initWithPointer:map disposer:(void *)NSFreeMapTable];
        if (_objectToAttributesMapPointer == nil) {
            NSFreeMapTable(map);
        } else {
            // Each entry gets its own attribute set so the copy can be mutated.
            NSMapEnumerator enumerator = NSEnumerateMapTable(sourceMap);
            void *key = NULL;
            HSMOASObjectAttributes *value = nil;
            while (NSNextMapEnumeratorPair(&enumerator, &key, (void **)&value)) {
                id copy = [value copyWithZone:zone];
                if (copy == nil) {
                    NSEndMapTableEnumeration(&enumerator);
                    [self release];
                    return nil;
                }
                NSMapInsert(map, key, copy);
                [copy release];
            }
            NSEndMapTableEnumeration(&enumerator);
            return self;
        }
    }
    [self release];
    return nil;
}

- (id)init
{
    return [self initWithObjectToAttributesMap:nil];
}

@end

@implementation HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetObservingSession

- (void)forwardAttributeChangeNotification:(id)aNotification
{
    if (_observerToSelectorsMap == NULL)
        return;
    CFIndex observerCount = CFDictionaryGetCount(_observerToSelectorsMap);
    if (observerCount == 0)
        return;
    // Observers may unregister while being notified, so work on snapshots.
    CFAllocatorRef allocator = kCFAllocatorDefault;
    const void **observers = CFAllocatorAllocate(allocator, observerCount * sizeof(void *), 0);
    if (observers == NULL)
        return;
    CFDictionaryGetKeysAndValues(_observerToSelectorsMap, observers, NULL);
    for (const void **observer = observers; observer < observers + observerCount; observer++) {
        CFMutableSetRef selectors = (CFMutableSetRef)CFDictionaryGetValue(_observerToSelectorsMap, *observer);
        if (selectors == NULL)
            continue;
        CFIndex selectorCount = CFSetGetCount(selectors);
        const void **selectorList = CFAllocatorAllocate(allocator, selectorCount * sizeof(void *), 0);
        if (selectorList == NULL)
            break;
        CFSetGetValues(selectors, selectorList);
        for (const void **selector = selectorList; selector < selectorList + selectorCount; selector++) {
            if (CFSetContainsValue(selectors, *selector))
                [(id)*observer performSelector:(SEL)*selector withObject:aNotification];
        }
        CFAllocatorDeallocate(allocator, selectorList);
    }
    CFAllocatorDeallocate(allocator, observers);
}

- (void)removeAllObservers
{
    if (_observerToSelectorsMap != NULL)
        CFDictionaryRemoveAllValues(_observerToSelectorsMap);
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector
{
    if (_observerToSelectorsMap == NULL)
        return;
    CFMutableSetRef selectors = (CFMutableSetRef)CFDictionaryGetValue(_observerToSelectorsMap, aObserver);
    if (selectors == NULL)
        return;
    if (CFSetGetCount(selectors) == 1) {
        if (CFSetContainsValue(selectors, aSelector))
            CFDictionaryRemoveValue(_observerToSelectorsMap, aObserver);
    } else {
        CFSetRemoveValue(selectors, aSelector);
    }
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector
{
    CFMutableSetRef selectors = NULL;
    if (_observerToSelectorsMap == NULL) {
        _observerToSelectorsMap = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFEWeakObjectPointerDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        if (_observerToSelectorsMap == NULL)
            return;
    } else {
        selectors = (CFMutableSetRef)CFDictionaryGetValue(_observerToSelectorsMap, aObserver);
    }
    if (selectors == NULL) {
        selectors = CFSetCreateMutable(kCFAllocatorDefault, 0, &NSESelectorSetCallBacks);
        if (selectors == NULL)
            return;
        CFDictionaryAddValue(_observerToSelectorsMap, aObserver, selectors);
        CFRelease(selectors);
    }
    CFSetAddValue(selectors, aSelector);
}

- (id)description
{
    id observers = nil;
    if (_observerToSelectorsMap != NULL)
        observers = [(id)CFCopyDescription(_observerToSelectorsMap) autorelease];
    // The original used 0x%x for the pointer.
    return [NSString stringWithFormat:@"<%@: %p>{observers = %@}", NSStringFromClass([self class]), self, observers];
}

- (void)backwardRelease
{
    _backwardRetainCount--;
    if ([self retainCount] == 1) {
        [_multipleObjectsAttributeSetImplementation removeObserver:self selector:@selector(forwardAttributeChangeNotification:) ofChanges:_observedAttributeChanges];
        _multipleObjectsAttributeSetImplementation = nil;
    }
    [super release];
}

- (id)backwardRetain
{
    _backwardRetainCount++;
    return [super retain];
}

// Only references from outside the implementation's session table keep the
// implementation alive; the table's own (backward) references do not.
- (oneway void)release
{
    [super release];
    if ([self retainCount] == _backwardRetainCount)
        [_multipleObjectsAttributeSetImplementation release];
}

- (id)retain
{
    if ([self retainCount] == _backwardRetainCount)
        [_multipleObjectsAttributeSetImplementation retain];
    return [super retain];
}

- (void)dealloc
{
    if (_observerToSelectorsMap != NULL)
        CFRelease(_observerToSelectorsMap);
    [super dealloc];
}

- (id)initWithMultipleObjectsAttributeSetImplementation:(id)aImplementation changesToObserve:(NSUInteger)aObserve withPriority:(CGFloat)aPriority
{
    self = [super init];
    if (self != nil) {
        _multipleObjectsAttributeSetImplementation = [aImplementation retain];
        _observedAttributeChanges = (unsigned int)aObserve;
        [_multipleObjectsAttributeSetImplementation addObserver:self selector:@selector(forwardAttributeChangeNotification:) ofChanges:aObserve withPriority:aPriority];
    }
    return self;
}

- (id)init
{
    [self release];
    return nil;
}

@end

@implementation HSMultipleObjectsAttributeSet_HSObjectEnumerator

- (id)allObjects
{
    if (_objectToAttributesMapPointer == nil)
        return [NSArray array];
    NSMutableArray *objects = [NSMutableArray array];
    HSMOASObjectAttributes *value = nil;
    while (NSNextMapEnumeratorPair(&_objectToAttributesMapEnumerator, NULL, (void **)&value))
        [objects addObject:[value object]];
    NSEndMapTableEnumeration(&_objectToAttributesMapEnumerator);
    [_objectToAttributesMapPointer release];
    _objectToAttributesMapPointer = nil;
    return [[objects copy] autorelease];
}

- (id)nextObject
{
    if (_objectToAttributesMapPointer == nil)
        return nil;
    HSMOASObjectAttributes *value = nil;
    if (NSNextMapEnumeratorPair(&_objectToAttributesMapEnumerator, NULL, (void **)&value))
        return [value object];
    NSEndMapTableEnumeration(&_objectToAttributesMapEnumerator);
    [_objectToAttributesMapPointer release];
    _objectToAttributesMapPointer = nil;
    return nil;
}

- (void)dealloc
{
    if (_objectToAttributesMapPointer != nil) {
        NSEndMapTableEnumeration(&_objectToAttributesMapEnumerator);
        [_objectToAttributesMapPointer release];
    }
    [super dealloc];
}

- (id)initWithObjectToAttributesMapPointer:(id)aPointer
{
    self = [super init];
    if (self != nil) {
        NSMapTable *map = [(HSPointer *)aPointer pointer];
        if (map != NULL) {
            _objectToAttributesMapEnumerator = NSEnumerateMapTable(map);
            _objectToAttributesMapPointer = [aPointer retain];
        }
    }
    return self;
}

- (id)init
{
    return [self initWithObjectToAttributesMapPointer:nil];
}

@end

@implementation HSMultipleObjectsAttributeSet_HSEmptyObjectEnumerator

- (id)allObjects
{
    return [NSArray array];
}

- (id)nextObject
{
    return nil;
}

@end

@implementation HSMultipleObjectsAttributeSet_HSObjectAttributes

- (id)attributes
{
    return _attributes;
}

- (id)object
{
    return _object;
}

- (id)copyWithZone:(NSZone *)aZone
{
    return [[[self class] allocWithZone:aZone] initWithObject:_object attributes:_attributes];
}

- (void)dealloc
{
    [_attributes release];
    [_object release];
    [super dealloc];
}

- (id)initWithObject:(id)aObject attributes:(id)aAttributes
{
    self = [super init];
    if (self == nil)
        return nil;
    NSZone *zone = [super zone];
    if (aAttributes == nil)
        _attributes = [[NSEMutableProtocolSet allocWithZone:zone] init];
    else
        _attributes = [aAttributes mutableCopyWithZone:zone];
    if (_attributes == nil) {
        [self release];
        return nil;
    }
    _object = [aObject retain];
    return self;
}

- (id)init
{
    [self release];
    return nil;
}

@end
