#import "HSReferenceRegistry.h"
// Named references from one object to others, kept outside the objects:
// strong ones (retained, in a dictionary per object) and weak ones (in a map
// table per object, wrapped in an HSPointer that frees it). Referencing
// objects are told to call dereferenceObject: when they die.
@implementation HSReferenceRegistry
static HSReferenceRegistry *sSharedRegistry;
+ (id)sharedRegistry
{
    if (sSharedRegistry == nil)
        sSharedRegistry = [[HSReferenceRegistry alloc] init];
    return sSharedRegistry;
}
- (void)addWeakReferenceToObject:(id)aObject forObject:(id)aObject2 key:(id)aKey
{
    [self removeStrongReferenceToObject:aObject forObject:aObject2 key:aKey];
    NSMapTable *references = NULL;
    if (_weakReferences == nil) {
        _weakReferences = NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks, NSObjectMapValueCallBacks, 0);
        if (_weakReferences == nil)
            return;
    } else
        references = [(HSPointer *)NSMapGet(_weakReferences, aObject2) pointer];
    if (references == NULL) {
        references = NSCreateMapTable(NSObjectMapKeyCallBacks, NSNonOwnedPointerMapValueCallBacks, 0);
        if (references == NULL)
            return;
        id wrapper = [HSPointer wrapperForPointer:references withDisposer:(void *)NSFreeMapTable];
        if (wrapper == nil) {
            NSFreeMapTable(references);
            return;
        }
        NSMapInsert(_weakReferences, aObject2, wrapper);
        [aObject2 registerWeakReferencer:self];
    }
    NSMapInsert(references, aKey, aObject);
}
- (void)addStrongReferenceToObject:(id)aObject forObject:(id)aObject2 key:(id)aKey
{
    [self removeWeakReferenceToObject:aObject forObject:aObject2 key:aKey];
    NSMutableDictionary *references = nil;
    if (_strongReferences == nil) {
        _strongReferences = NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks, NSObjectMapValueCallBacks, 0);
        if (_strongReferences == nil)
            return;
    } else
        references = NSMapGet(_strongReferences, aObject2);
    if (references == nil) {
        references = [NSMutableDictionary dictionary];
        if (references == nil)
            return;
        NSMapInsert(_strongReferences, aObject2, references);
        [aObject2 registerWeakReferencer:self];
    }
    [references setObject:aObject forKey:aKey];
}
- (void)removeReferenceToObject:(id)aObject forObject:(id)aObject2 key:(id)aKey
{
    if (![self removeStrongReferenceToObject:aObject forObject:aObject2 key:aKey])
        [self removeWeakReferenceToObject:aObject forObject:aObject2 key:aKey];
}
// The object's last reference takes its whole entry (and registration) along.
- (BOOL)removeWeakReferenceToObject:(id)aObject forObject:(id)aObject2 key:(id)aKey
{
    if (_weakReferences == nil)
        return NO;
    NSMapTable *references = [(HSPointer *)NSMapGet(_weakReferences, aObject2) pointer];
    if (references == NULL || NSMapGet(references, aKey) == NULL)
        return NO;
    if (NSCountMapTable(references) == 1) {
        NSMapRemove(_weakReferences, aObject2);
        [aObject2 unregisterWeakReferencer:self];
    } else
        NSMapRemove(references, aKey);
    return YES;
}
- (BOOL)removeStrongReferenceToObject:(id)aObject forObject:(id)aObject2 key:(id)aKey
{
    if (_strongReferences == nil)
        return NO;
    NSMutableDictionary *references = NSMapGet(_strongReferences, aObject2);
    if ([references objectForKey:aKey] == nil)
        return NO;
    if ([references count] == 1) {
        NSMapRemove(_strongReferences, aObject2);
        [aObject2 unregisterWeakReferencer:self];
    } else
        [references removeObjectForKey:aKey];
    return YES;
}
// Weak and strong references together, by key.
- (id)referencedObjectsForObject:(id)aObject
{
    NSMutableDictionary *result = nil;
    if (_weakReferences != nil) {
        NSMapTable *references = [(HSPointer *)NSMapGet(_weakReferences, aObject) pointer];
        if (references != NULL) {
            result = [NSMutableDictionary dictionary];
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            NSMapEnumerator enumerator = NSEnumerateMapTable(references);
            void *key, *value;
            while (NSNextMapEnumeratorPair(&enumerator, &key, &value))
                [result setObject:(id)value forKey:(id)key];
            NSEndMapTableEnumeration(&enumerator);
            [pool release];
        }
    }
    NSDictionary *strong = _strongReferences != nil ? NSMapGet(_strongReferences, aObject) : nil;
    if (strong != nil) {
        if (result != nil)
            [result addEntriesFromDictionary:strong];
        else
            result = (NSMutableDictionary *)strong;
    }
    if (result == nil)
        return [NSDictionary dictionary];
    return [[result copy] autorelease];
}
- (id)referencedObjectForObject:(id)aObject key:(id)aKey
{
    if (_strongReferences == nil)
        return nil;
    return [(NSDictionary *)NSMapGet(_strongReferences, aObject) objectForKey:aKey];
}
- (void)dereferenceObject:(id)aObject
{
    if (_strongReferences != nil)
        NSMapRemove(_strongReferences, aObject);
    if (_weakReferences != nil)
        NSMapRemove(_weakReferences, aObject);
}
- (void)dealloc
{
    if (_strongReferences != nil)
        NSFreeMapTable(_strongReferences);
    if (_weakReferences != nil)
        NSFreeMapTable(_weakReferences);
    [super dealloc];
}
@end
