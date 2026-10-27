#import "HyperStudioPrefix.h"


@interface HSEditorCanvasHitTester : HSCanvasHitTester
{
}
- (BOOL)hitTestRect:(NSRect)aRect inItem:(id)aItem;
- (BOOL)hitTestPoint:(NSPoint)aPoint inItem:(id)aItem;
- (BOOL)shouldHitTestCanvasItem:(id)aItem;
@end

