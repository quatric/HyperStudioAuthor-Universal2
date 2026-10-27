#import "HyperPlayerBasePrefix.h"


@interface HSWeaklyReferencedObject : NSObject <HSWeakReferencing>
{
    HSWeakReferenceRegistry *_weakReferenceRegistry;
}
- (void)unregisterWeakReferencer:(void *)aReferencer;
- (void)registerWeakReferencer:(id)aReferencer;
- (void)release;
- (id)retain;
- (void)dealloc;
@end

@interface HSWeakReferenceRegistry : NSObject
{
    struct __CFDictionary *_weakReferencers;
    struct __CFDictionary *_newWeakReferencers;
    id<HSWeakReferencing> *_pointerToObjectBeingDereferenced;
    unsigned int _weakReferencersLockCount;
}
- (void)stopDereferencing;
- (BOOL)isDereferencing;
- (void)makeWeakReferencersDereferenceObject:(id)aObject;
- (void)removeWeakReferencer:(void *)aReferencer;
- (BOOL)HSWeakReferenceRegistry_removeWeakReferencer:(void *)aReferencer fromWeakReferencersMap:(struct __CFDictionary *)aMap;
- (void)addWeakReferencer:(id)aReferencer;
- (void)dealloc;
@end

