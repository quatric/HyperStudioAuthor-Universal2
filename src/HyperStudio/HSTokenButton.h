#import "HyperStudioPrefix.h"


@interface HSTokenButton : NSControl
{
    BOOL _isDragging;
    int _trackingRectTag;
    SEL _doubleClickAction;
}
+ (Class)cellClass;
- (id)accessibilityAttributeValue:(id)aValue;
- (id)accessibilityFocusedUIElement;
- (id)accessibilityHitTest:(NSPoint)aTest;
- (BOOL)accessibilityIsIgnored;
- (void)writeCellToPasteboard:(id)aPasteboard;
- (void)pasteboard:(id)aPasteboard provideDataForType:(id)aType;
- (NSUInteger)draggingSourceOperationMaskForLocal:(BOOL)aLocal;
- (void)setBounds:(NSRect)aBounds;
- (void)setFrame:(NSRect)aFrame;
- (void)viewWillMoveToWindow:(id)aWindow;
- (void)viewDidMoveToWindow;
- (void)mouseUp:(id)aUp;
- (void)mouseDragged:(id)aDragged;
- (void)mouseDown:(id)aDown;
- (BOOL)acceptsFirstMouse:(id)aMouse;
- (void)mouseExited:(id)aExited;
- (void)mouseEntered:(id)aEntered;
- (void)setDoubleClickAction:(SEL)aAction;
- (SEL)doubleClickAction;
- (id)title;
- (void)setTitle:(id)aTitle;
- (id)menu;
- (void)setMenu:(id)aMenu;
@end

