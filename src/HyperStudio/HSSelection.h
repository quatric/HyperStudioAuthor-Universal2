#import "HyperStudioPrefix.h"


@interface HSSelection : NSObject <HSSelectionInterface, NSObject>
{
    NSMutableSet *_objects;
    id _selectedObject;
    id<HSSelectionOwner> _owner;
    BOOL _hadAnyChangesOtherThanRemovingObjectsSinceLastNotification;
}
- (void)setOwner:(id)aOwner;
- (id)owner;
- (void)notifySelectionDidChange;
- (void)removeAllObjects;
- (void)removeObject:(id)aObject;
- (void)addObject:(id)aObject;
- (BOOL)containsObject:(id)aObject;
- (id)anySelectedObject;
- (id)selectedObject;
- (void)setSelectedObject:(id)aObject;
- (id)objectEnumerator;
- (id)objectsArray;
- (NSUInteger)objectsCount;
- (id)objects;
- (void)dealloc;
- (id)init;
@end

