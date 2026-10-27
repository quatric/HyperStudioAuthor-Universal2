#import "HyperPlayerBasePrefix.h"


@interface HSPresentationContext : NSObject
{
}
+ (id)presentationContext;
- (BOOL)isInteractive;
- (BOOL)isUIObjectsContext;
- (BOOL)canOpenObjectInPlayer;
- (BOOL)canOpenObjectInEditor;
- (BOOL)isSlideshowContext;
- (BOOL)needsHistory;
- (BOOL)isPrinting;
- (id)contextIdentifier;
- (NSInteger)renderQuality;
- (BOOL)supportsRotatableObjects;
- (BOOL)supportsResizableObjects;
- (BOOL)supportsDraggableObjects;
- (BOOL)allowsEditing;
- (BOOL)supportsOwnActions;
- (BOOL)supportsUserActions;
@end

