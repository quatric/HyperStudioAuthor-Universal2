#import "HyperEditorBasePrefix.h"


@interface HSColorSlider : NSControl
{
    NSImage *_knobImage;
    NSImage *_knobPressedImage;
    BOOL _isPressed;
    float _knobHeight;
    NSColor *_bottomColor;
    NSColor *_topColor;
    unsigned int _markersCount;
    float _floatValue;
}
+ (id)defaultBottomColor;
+ (id)defaultTopColor;
+ (Class)cellClass;
- (id)accessibilityFocusedUIElement;
- (BOOL)accessibilityIsIgnored;
- (id)accessibilityHitTest:(NSPoint)aTest;
- (id)accessibilityAttributeValue:(id)aValue;
- (id)knobPressedImage;
- (id)knobImage;
- (void)updateWithEvent:(id)aEvent;
- (void)mouseDragged:(id)aDragged;
- (void)mouseUp:(id)aUp;
- (void)mouseDown:(id)aDown;
- (BOOL)acceptsFirstMouse:(id)aMouse;
- (float)floatValue;
- (void)setFloatValue:(float)aValue;
- (NSUInteger)markersCount;
- (void)setMarkersCount:(NSUInteger)aCount;
- (void)setBottomColor:(id)aColor;
- (id)bottomColor;
- (void)setTopColor:(id)aColor;
- (id)topColor;
- (void)drawRect:(NSRect)aRect;
- (void)dealloc;
- (id)initWithFrame:(NSRect)aFrame;
@end

