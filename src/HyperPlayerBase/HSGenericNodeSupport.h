#import "HyperPlayerBasePrefix.h"


@interface HSGenericNodeSupport : NSObject <HSNodeSupport, NSObject>
{
    NSMutableArray *_nodes;
    id _allObjectsProxy;
}
+ (id)nodeSupport;
+ (id)sharedNodeSupport;
- (BOOL)isAttributesNotificationPostingDisabled;
- (id)cardGroupController;
- (id)delegate;
- (id)scriptController;
- (id)undoManager;
- (void)invalidateAllObjectsProxy;
- (id)allObjectsInterface;
- (id)allObjectsProxy;
- (void)removeAllNodes;
- (BOOL)removeNode:(id)aNode;
- (BOOL)addNodeIfSupportIsNeeded:(id)aNeeded;
- (void)addNode:(id)aNode;
- (void)dealloc;
@end

