#import "HyperPlayerBasePrefix.h"


@interface HSReferenceRegistry : NSObject <HSWeakReferencer>
{
    NSMapTable *_strongReferences;
    NSMapTable *_weakReferences;
}
+ (id)sharedRegistry;
- (void)addWeakReferenceToObject:(id)aObject forObject:(id)aObject2 key:(id)aKey;
- (void)addStrongReferenceToObject:(id)aObject forObject:(id)aObject2 key:(id)aKey;
- (void)removeReferenceToObject:(id)aObject forObject:(id)aObject2 key:(id)aKey;
- (BOOL)removeWeakReferenceToObject:(id)aObject forObject:(id)aObject2 key:(id)aKey;
- (BOOL)removeStrongReferenceToObject:(id)aObject forObject:(id)aObject2 key:(id)aKey;
- (id)referencedObjectsForObject:(id)aObject;
- (id)referencedObjectForObject:(id)aObject key:(id)aKey;
- (void)dereferenceObject:(id)aObject;
- (void)dealloc;
@end

