#import "HyperPlayerBasePrefix.h"
#import "HSCanvasItemsSublayer.h"


@interface HSGenericItemsCanvasSublayer : HSCanvasItemsSublayer
{
    NSMutableArray *_canvasItems;
    NSString *_cursorIdentifier;
    BOOL _supportsHitTesting;
}
- (void)canvasItemWillOrDidChange:(id)aChange;
- (void)setCursorIdentifier:(id)aIdentifier;
- (id)cursorIdentifier;
- (void)willRemoveCanvasItem:(id)aItem;
- (void)didAddCanvasItem:(id)aItem;
- (void)removeAllCanvasItems;
- (void)removeCanvasItem:(id)aItem;
- (void)addCanvasItem:(id)aItem;
- (id)canvasItems;
- (id)mutableCanvasItems;
- (void)setSupportsHitTesting:(BOOL)aTesting;
- (BOOL)supportsHitTesting;
- (id)canvasItemAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfCanvasItems;
- (void)dealloc;
@end

