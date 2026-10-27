#import "HyperStudioPrefix.h"


@interface HSInspectorLayout : NSObject <HSObjectAssistantLayout, NSObject>
{
    NSPoint _inspectorTopLeft;
    NSPoint _inspectorOrigin;
    BOOL _originInitialized;
    BOOL _shouldCorrectWindowFrame;
}
- (void)setShouldCorrectWindowFrame:(BOOL)aFrame;
- (BOOL)shouldCorrectWindowFrame;
- (id)layoutForObjectFrame:(NSRect)aFrame cardViewFrame:(NSRect)aFrame2 windowSize:(NSSize)aSize currentWindowSize:(NSSize)aSize2 primaryObstacleRects:(id)aRects secondaryObstacleRects:(id)aRects2 shouldNotCoverObjectForInspector:(BOOL)aInspector oldLayout:(id)aLayout;
- (NSRect)calculateWindowFrame:(NSRect)aFrame shouldNotCoverObjectWithFrame:(NSRect)aFrame2;
- (void)setInspectorTopLeft:(NSPoint)aLeft;
- (NSPoint)inspectorTopLeft;
@end

