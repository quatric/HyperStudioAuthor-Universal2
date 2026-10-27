#import "HyperPlayerBasePrefix.h"
#import "HSCanvasItemsSublayer.h"


@interface HSObservingCanvasSublayer : HSCanvasItemsSublayer
{
    NSMapTable *_itemsByRepresentedObject;
    id _rootRepresentedObject;
}
+ (id)stubCanvasItem;
- (void)willUnregisterCanvasItem:(id)aItem forRepresentedObject:(id)aObject;
- (void)didRegisterCanvasItem:(id)aItem forRepresentedObject:(id)aObject;
- (BOOL)invalidatesDisplayUponRegisterUnregister;
- (void)updateCanvasItemsIfNeeded;
- (void)updateRegisteredCanvasItemsIfNeeded;
- (void)dereferenceRegisteredCanvasItems:(id)aItems;
- (id)privateRegisteredCanvasItems;
- (id)registeredCanvasItems;
- (id)registeredCanvasItemsByRepresentedObject;
- (void)unregisterAllCanvasItems;
- (void)unregisterCanvasItem:(id)aItem forRepresentedObject:(id)aObject;
- (void)unregisterCanvasItem:(id)aItem;
- (void)unregisterCanvasItemForRepresentedObject:(id)aObject;
- (void)unregisterExistingCanvasItem:(id)aItem forRepresentedObject:(id)aObject;
- (void)registerCanvasItem:(id)aItem forRepresentedObject:(id)aObject;
- (id)canvasItemForRepresentedObject:(id)aObject;
- (id)canvasItemForRepresentedObjectIfExists:(id)aExists;
- (id)canvasItemForRepresentedObject:(id)aObject createIfNeeded:(BOOL)aNeeded;
- (id)representedObjectForCanvasItem:(id)aItem;
- (id)queryCanvasItemForRepresentedObject:(id)aObject;
- (id)objectInRepresentedObjectsAtIndex:(NSUInteger)aIndex;
- (NSUInteger)countOfRepresentedObjects;
- (id)canvasItemAtIndex:(NSUInteger)aIndex;
- (BOOL)storesStubItems;
- (NSUInteger)numberOfCanvasItems;
- (void)representedObjectDidChange;
- (void)setRootRepresentedObject:(id)aObject;
- (void)stopObservingNotificationsFromRootRepresentedObject:(id)aObject;
- (void)observeNotificationsFromRootRepresentedObject:(id)aObject;
- (void)dealloc;
@end

