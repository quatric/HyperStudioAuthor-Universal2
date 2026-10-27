#import "HyperPlayerBasePrefix.h"


@interface HSMultipleObjectsAttributeSet : NSObject <NSCopying, NSMutableCopying>
{
    id _implementation;
}
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges withPriority:(CGFloat)aPriority;
- (id)sharedObservingSessionForChanges:(NSUInteger)aChanges withPriority:(CGFloat)aPriority;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)aEqual;
- (BOOL)isEqualToMultipleObjectsAttributeSet:(id)aSet;
- (id)allObjects;
- (id)attributesForObject:(id)aObject;
- (id)objectEnumerator;
- (BOOL)excludesAttributeSet:(id)aSet forObject:(id)aObject;
- (BOOL)intersectsAttributeSet:(id)aSet forObject:(id)aObject;
- (BOOL)includesAttribute:(id)aAttribute forObject:(id)aObject;
- (BOOL)containsAttribute:(id)aAttribute forObject:(id)aObject;
- (NSUInteger)attributeCountForObject:(id)aObject;
- (NSUInteger)objectCount;
- (id)description;
- (id)mutableCopyWithZone:(NSZone *)aZone;
- (id)copyWithZone:(NSZone *)aZone;
- (void)dealloc;
- (id)initWithMultipleObjectsAttributeSet:(id)aSet;
- (void)HSMultipleObjectsAttributeSet_protected_removeAllAttributes;
- (void)HSMultipleObjectsAttributeSet_protected_setImplementation:(id)aImplementation;
- (id)HSMultipleObjectsAttributeSet_protected_mutableImplementationForExpanding:(BOOL)aExpanding;
- (id)HSMultipleObjectsAttributeSet_protected_implementation;
@end

@interface HSMutableMultipleObjectsAttributeSet : HSMultipleObjectsAttributeSet
{
}
- (void)setMultipleObjectsAttributeSet:(id)aSet;
- (void)unionMultipleObjectsAttributeSet:(id)aSet;
- (void)minusMultipleObjectsAttributeSet:(id)aSet;
- (void)intersectMultipleObjectsAttributeSet:(id)aSet;
- (void)removeAllAttributes;
- (void)removeAttributesForObject:(id)aObject;
- (void)removeAttributes:(id)aAttributes forObject:(id)aObject;
- (void)removeAttribute:(id)aAttribute forObject:(id)aObject;
- (void)addAttributes:(id)aAttributes forObject:(id)aObject;
- (void)addAttribute:(id)aAttribute forObject:(id)aObject;
- (id)copyWithZone:(NSZone *)aZone;
@end

@interface HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetImplementation : NSObject <NSCopying>
{
    HSPointer *_objectToAttributesMapPointer;
    struct __CFDictionary *_observingSessions;
}
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges withPriority:(CGFloat)aPriority;
- (id)sharedObservingSessionForChanges:(NSUInteger)aChanges withPriority:(CGFloat)aPriority;
- (void)unionMultipleObjectsAttributeSetImplementation:(id)aImplementation;
- (void)minusMultipleObjectsAttributeSetImplementation:(id)aImplementation;
- (void)intersectMultipleObjectsAttributeSetImplementation:(id)aImplementation;
- (void)HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetImplementation_addObjectIdentifier:(NSUInteger)aIdentifier toDataArray:(id *)aArray;
- (void)removeAllAttributes;
- (void)removeAttributesForObject:(id)aObject;
- (void)removeAttributes:(id)aAttributes forObject:(id)aObject;
- (void)removeAttribute:(id)aAttribute forObject:(id)aObject;
- (void)addAttributes:(id)aAttributes forObject:(id)aObject;
- (void)addAttribute:(id)aAttribute forObject:(id)aObject;
- (id)HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetImplementation_mutableAttributeSetForObject:(id)aObject addingAttributes:(id)aAttributes;
- (id)HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetImplementation_mutableObjectToAttributesMap;
- (id)allObjects;
- (id)attributesForObject:(id)aObject;
- (id)objectEnumerator;
- (BOOL)excludesAttributeSet:(id)aSet forObject:(id)aObject;
- (BOOL)intersectsAttributeSet:(id)aSet forObject:(id)aObject;
- (BOOL)includesAttribute:(id)aAttribute forObject:(id)aObject;
- (BOOL)containsAttribute:(id)aAttribute forObject:(id)aObject;
- (NSUInteger)attributeCountForObject:(id)aObject;
- (NSUInteger)objectCount;
- (BOOL)isMutable;
- (id)HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetImplementation_attributeSetForObject:(id)aObject;
- (id)description;
- (id)objectToAttributesMapDescription;
- (id)HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetImplementation_descriptionForAttributes:(id)aAttributes;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)aEqual;
- (BOOL)isEqualToMultipleObjectsAttributeSetImplementation:(id)aImplementation;
- (id)HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetImplementation_objectToAttributesMap;
- (id)copyWithZone:(NSZone *)aZone;
- (void)release;
- (void)dealloc;
- (id)initWithObjectToAttributesMap:(id)aMap;
- (id)init;
@end

@interface HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetObservingSession : NSObject <HSMultipleObjectsAttributeSetObservingSession, NSObject>
{
    unsigned int _backwardRetainCount;
    HSMultipleObjectsAttributeSet_HSMultipleObjectsAttributeSetImplementation *_multipleObjectsAttributeSetImplementation;
    unsigned int _observedAttributeChanges;
    struct __CFDictionary *_observerToSelectorsMap;
}
- (void)forwardAttributeChangeNotification:(id)aNotification;
- (void)removeAllObservers;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector;
- (id)description;
- (void)backwardRelease;
- (id)backwardRetain;
- (void)release;
- (id)retain;
- (void)dealloc;
- (id)initWithMultipleObjectsAttributeSetImplementation:(id)aImplementation changesToObserve:(NSUInteger)aObserve withPriority:(CGFloat)aPriority;
- (id)init;
@end

@interface HSMultipleObjectsAttributeSet_HSObjectEnumerator : NSEnumerator
{
    HSPointer *_objectToAttributesMapPointer;
    NSMapEnumerator _objectToAttributesMapEnumerator;
}
- (id)allObjects;
- (id)nextObject;
- (void)dealloc;
- (id)initWithObjectToAttributesMapPointer:(id)aPointer;
- (id)init;
@end

@interface HSMultipleObjectsAttributeSet_HSEmptyObjectEnumerator : NSEnumerator
{
}
- (id)allObjects;
- (id)nextObject;
@end

@interface HSMultipleObjectsAttributeSet_HSObjectAttributes : NSObject <NSCopying>
{
    id _object;
    NSEMutableProtocolSet *_attributes;
}
- (id)attributes;
- (id)object;
- (id)copyWithZone:(NSZone *)aZone;
- (void)dealloc;
- (id)initWithObject:(id)aObject attributes:(id)aAttributes;
- (id)init;
@end

