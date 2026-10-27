#import "HSWeaklyReferencedObject.h"
// An object that tells its weak referencers (dereferenceObject:) when its
// last reference goes away. If one of them retains it while being told, the
// object survives and the rest are not told.
@implementation HSWeaklyReferencedObject
- (void)unregisterWeakReferencer:(void *)aReferencer
{
    [_weakReferenceRegistry removeWeakReferencer:aReferencer];
}
- (void)registerWeakReferencer:(id)aReferencer
{
    if (_weakReferenceRegistry == nil)
        _weakReferenceRegistry = [[HSWeakReferenceRegistry alloc] init];
    [_weakReferenceRegistry addWeakReferencer:aReferencer];
}
- (oneway void)release
{
    if ([self retainCount] == 1)
        [_weakReferenceRegistry makeWeakReferencersDereferenceObject:self];
    [super release];
}
- (id)retain
{
    if ([_weakReferenceRegistry isDereferencing])
        [_weakReferenceRegistry stopDereferencing];
    return [super retain];
}
- (void)dealloc
{
    [_weakReferenceRegistry release];
    [super dealloc];
}
@end

// The registry maps each weak referencer (not retained) to a registration
// count (an int owned by the dictionary). While the referencers are being
// told (_weakReferencersLockCount > 0), changes go to _newWeakReferencers,
// which is merged in afterwards: non-zero counts of the old map win.
static const void *HSWeakReferenceCountRetain(CFAllocatorRef allocator, const void *value)
{
    int *count = CFAllocatorAllocate(allocator, sizeof(int), 0);
    if (count != NULL)
        *count = *(const int *)value;
    return count;
}
static void HSWeakReferenceCountRelease(CFAllocatorRef allocator, const void *value)
{
    CFAllocatorDeallocate(allocator, (void *)value);
}
static CFStringRef HSWeakReferenceCountCopyDescription(const void *value)
{
    return CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%u"), *(const int *)value);
}
static Boolean HSWeakReferenceCountEqual(const void *value1, const void *value2)
{
    return *(const int *)value1 == *(const int *)value2;
}
static const CFDictionaryValueCallBacks HSWeakReferenceCountCallBacks = {
    0, HSWeakReferenceCountRetain, HSWeakReferenceCountRelease, HSWeakReferenceCountCopyDescription,
    HSWeakReferenceCountEqual
};
static CFMutableDictionaryRef HSWeakReferenceRegistryCreateMap(void)
{
    return CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFEWeakObjectPointerDictionaryKeyCallBacks,
                                     &HSWeakReferenceCountCallBacks);
}
// Merge applier: copies the live old counts into the new map.
static void HSWeakReferenceRegistryMerge(const void *key, const void *value, void *context)
{
    if (*(const int *)value != 0)
        CFDictionarySetValue((CFMutableDictionaryRef)context, key, value);
}
// Dereference applier; the context points to the object, nil once it has
// been retained again.
static void HSWeakReferenceRegistryDereference(const void *key, const void *value, void *context)
{
    id object = *(id *)context;
    if (object != nil && *(int *)value != 0) {
        *(int *)value = 0;
        [(id)key dereferenceObject:object];
    }
}

@implementation HSWeakReferenceRegistry
- (void)stopDereferencing
{
    if (_pointerToObjectBeingDereferenced != NULL) {
        *_pointerToObjectBeingDereferenced = nil;
        _pointerToObjectBeingDereferenced = NULL;
    }
}
- (BOOL)isDereferencing
{
    return _pointerToObjectBeingDereferenced != NULL;
}
- (void)makeWeakReferencersDereferenceObject:(id)aObject
{
    id object = aObject;
    if (_weakReferencers == NULL)
        return;
    if (_newWeakReferencers == NULL) {
        _weakReferencersLockCount++;
    } else {
        CFDictionaryApplyFunction(_weakReferencers, HSWeakReferenceRegistryMerge, _newWeakReferencers);
        CFRelease(_weakReferencers);
        _weakReferencers = _newWeakReferencers;
        _newWeakReferencers = NULL;
        _weakReferencersLockCount = 1;
    }
    _pointerToObjectBeingDereferenced = (id<HSWeakReferencing> *)&object;
    CFDictionaryRef map = CFRetain(_weakReferencers);
    CFDictionaryApplyFunction(map, HSWeakReferenceRegistryDereference, _pointerToObjectBeingDereferenced);
    CFRelease(map);
    // A nested call replaced the map: it has cleaned up.
    if (map != _weakReferencers)
        return;
    if (_pointerToObjectBeingDereferenced != NULL) {
        // Nobody kept the object: it goes away, and its referencers with it.
        // (The original left the pointer to this stack frame set when a new
        // map was waiting.)
        _weakReferencersLockCount = 0;
        _pointerToObjectBeingDereferenced = NULL;
        CFRelease(_weakReferencers);
        _weakReferencers = _newWeakReferencers;
        _newWeakReferencers = NULL;
    } else if (_newWeakReferencers != NULL) {
        CFDictionaryApplyFunction(_weakReferencers, HSWeakReferenceRegistryMerge, _newWeakReferencers);
        CFRelease(_weakReferencers);
        _weakReferencers = _newWeakReferencers;
        _newWeakReferencers = NULL;
        _weakReferencersLockCount = 0;
    } else {
        _weakReferencersLockCount--;
    }
}
- (void)removeWeakReferencer:(void *)aReferencer
{
    if (_weakReferencers == NULL)
        return;
    if (_newWeakReferencers != NULL
        && [self HSWeakReferenceRegistry_removeWeakReferencer:aReferencer fromWeakReferencersMap:_newWeakReferencers])
        return;
    [self HSWeakReferenceRegistry_removeWeakReferencer:aReferencer fromWeakReferencersMap:_weakReferencers];
}
// While locked, the last registration only drops to 0 (the entry stays).
- (BOOL)HSWeakReferenceRegistry_removeWeakReferencer:(void *)aReferencer fromWeakReferencersMap:(struct __CFDictionary *)aMap
{
    int *count = (int *)CFDictionaryGetValue(aMap, aReferencer);
    if (count == NULL || *count == 0)
        return NO;
    if (*count == 1) {
        if (_weakReferencersLockCount == 0)
            CFDictionaryRemoveValue(aMap, aReferencer);
        else
            *count = 0;
    } else {
        (*count)--;
    }
    return YES;
}
- (void)addWeakReferencer:(id)aReferencer
{
    int one = 1;
    if (_weakReferencers == NULL) {
        _weakReferencers = HSWeakReferenceRegistryCreateMap();
        if (_weakReferencers != NULL)
            CFDictionarySetValue(_weakReferencers, aReferencer, &one);
        return;
    }
    int *count = (int *)CFDictionaryGetValue(_weakReferencers, aReferencer);
    if (_weakReferencersLockCount == 0) {
        if (count != NULL)
            (*count)++;
        else
            CFDictionarySetValue(_weakReferencers, aReferencer, &one);
        return;
    }
    // Locked: move the registration (plus this one) to the new map.
    int moved = 1;
    if (count != NULL) {
        moved = *count + 1;
        *count = 0;
    }
    if (_newWeakReferencers == NULL) {
        _newWeakReferencers = HSWeakReferenceRegistryCreateMap();
        if (_newWeakReferencers == NULL)
            return;
        // As in the original, an existing registration goes back to the old
        // map here (the merge carries it over).
    } else {
        count = (int *)CFDictionaryGetValue(_newWeakReferencers, aReferencer);
    }
    if (count != NULL)
        *count += moved;
    else
        CFDictionarySetValue(_newWeakReferencers, aReferencer, &moved);
}
// (The original never releases a pending new map.)
- (void)dealloc
{
    if (_weakReferencers != NULL)
        CFRelease(_weakReferencers);
    if (_newWeakReferencers != NULL)
        CFRelease(_newWeakReferencers);
    [super dealloc];
}
@end
