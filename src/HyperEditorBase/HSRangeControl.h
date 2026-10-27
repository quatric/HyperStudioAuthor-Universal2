#import "HyperEditorBasePrefix.h"


@interface HSRangeControl : NSControl
{
    id _delegate;
    BOOL _didInterpretCurrentKeyDownEvent;
}
+ (Class)cellClass;
- (SEL)rightKnobClickAction;
- (void)setRightKnobClickAction:(SEL)aAction;
- (SEL)leftKnobClickAction;
- (void)setLeftKnobClickAction:(SEL)aAction;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)setFinishTime:(double)aTime;
- (void)setStartTime:(double)aTime;
- (void)setDuration:(double)aDuration;
- (double)finishTime;
- (double)startTime;
- (double)duration;
- (BOOL)isFlipped;
- (BOOL)isOpaque;
- (BOOL)needsPanelToBecomeKey;
- (BOOL)acceptsFirstMouse:(id)aMouse;
- (void)moveRightAndModifySelection:(id)aSelection;
- (void)moveRight:(id)aRight;
- (void)moveLeftAndModifySelection:(id)aSelection;
- (void)moveLeft:(id)aLeft;
- (void)moveDown:(id)aDown;
- (void)moveUp:(id)aUp;
- (void)doCommandBySelector:(SEL)aSelector;
- (void)keyDown:(id)aDown;
- (id)initWithFrame:(NSRect)aFrame;
@end

@interface HSRangeControl (Accessibility)
- (id)accessibilityAttributeValue:(id)aValue;
- (id)accessibilityFocusedUIElement;
- (id)accessibilityHitTest:(NSPoint)aTest;
- (BOOL)accessibilityIsIgnored;
@end

