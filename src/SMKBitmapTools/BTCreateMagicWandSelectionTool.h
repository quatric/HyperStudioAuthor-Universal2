#import "SMKBitmapToolsPrefix.h"
#import "BTTool.h"


@interface BTCreateMagicWandSelectionTool : BTTool
{
    NSCursor *_willCreateSelectionCursor;
    CGFloat _tolerance;
    NSPoint _selectionStartPoint;
    CGPathRef _selectionPath;
    BOOL _isSelectionStartPointDefined;
}
- (void)finalizeSelectionPath:(id)aPath;
- (void)selectAllArea:(id)aArea;
- (void)setSelectionStartPoint:(id)aPoint;
- (BOOL)mouseDown:(id)aDown;
- (void)BTCreateMagicWandSelectionTool_createSelectionPathForPoint:(NSPoint)aPoint event:(id)aEvent;
- (id)BTCreateMagicWandSelectionTool_bitmapWorkImage;
- (id)cursorForPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags;
- (id)currentStage;
- (BOOL)activateWithDelegate:(id)aDelegate inView:(id)aView;
- (id)outputKeys;
- (id)inputKeys;
- (id)selectionPath;
- (id)selectionStartPoint;
- (void)setTolerance:(CGFloat)aTolerance;
- (CGFloat)tolerance;
- (void)setWillCreateSelectionCursor:(id)aCursor;
- (id)willCreateSelectionCursor;
- (id)defaultWillCreateSelectionCursor;
- (id *)optionalImageProtocols;
- (id *)requiredImageProtocols;
- (void)dealloc;
@end

