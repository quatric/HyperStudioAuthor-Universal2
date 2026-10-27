#import "SMKBitmapToolsPrefix.h"
#import "BTTool.h"


@interface BTFillTool : BTTool
{
    NSCursor *_willDrawCursor;
    NSCursor *_willAlternateDrawCursor;
    NSCursor *_pickColorCursor;
    struct CGEColor *_fillColor;
    struct CGEColor *_alternateFillColor;
    CGFloat _tolerance;
    NSUInteger _colorPickingOption;
    NSUInteger _alternateFillColorOption;
    unsigned int _isFillColorInitialized:1;
    unsigned int _isPickColorCursorInitialized:1;
    unsigned int _isWillAlternateDrawCursorInitialized:1;
    unsigned int _isUsingAlternateFillColor:1;
    unsigned int _isColorPicking:1;
}
- (void)drawRect:(NSRect)aRect ofActiveFeedbackLayersExcludingLayers:(id)aLayers;
- (void)drawRect:(NSRect)aRect ofActiveFeedbackLayersExcludingLayer:(id)aLayer;
- (void)drawRect:(NSRect)aRect ofActiveFeedbackLayers:(id)aLayers;
- (void)drawRect:(NSRect)aRect ofActiveFeedbackLayer:(id)aLayer;
- (id)activeFeedbackLayersForDrawing;
- (BOOL)isFeedbackLayerActive:(id)aActive;
- (id)activeFeedbackLayers;
- (void)drawRect:(NSRect)aRect;
- (BOOL)flagsChanged:(id)aChanged;
- (BOOL)mouseDown:(id)aDown;
- (id)cursorForPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags;
- (id)BTFillTool_bitmapWorkImage;
- (id)currentStage;
- (BOOL)activateWithDelegate:(id)aDelegate inView:(id)aView;
- (id)outputKeys;
- (id)inputKeys;
- (id *)optionalImageProtocols;
- (id *)requiredImageProtocols;
- (void)setTolerance:(CGFloat)aTolerance;
- (CGFloat)tolerance;
- (void)setAlternateFillColor:(id)aColor;
- (id)alternateFillColor;
- (void)setFillColor:(id)aColor;
- (id)fillColor;
- (id)defaultFillColor;
- (struct CGEColor *)BTFillTool_fillColor;
- (struct CGEColor *)BTFillTool_createDefaultFillColor;
- (void)setPickColorCursor:(id)aCursor;
- (id)pickColorCursor;
- (id)defaultPickColorCursor;
- (void)setWillAlternateDrawCursor:(id)aCursor;
- (id)willAlternateDrawCursor;
- (id)defaultWillAlternateDrawCursor;
- (void)setWillDrawCursor:(id)aCursor;
- (id)willDrawCursor;
- (id)defaultWillDrawCursor;
- (void)setAlternateColorOption:(NSUInteger)aOption;
- (NSUInteger)alternateColorOption;
- (NSUInteger)defaultAlternateColorOption;
- (void)setColorPickingOption:(NSUInteger)aOption;
- (NSUInteger)colorPickingOption;
- (NSUInteger)defaultColorPickingOption;
- (void)dealloc;
- (id)init;
@end

