// Exercises BTModifySelectionTool without a view: knob hit testing, cursor
// names, the transform actions with undo, a tracked corner scale and a
// tracked rotation, resize snap sources, and the feedback drawing.
#import <Cocoa/Cocoa.h>
#import "BTModifySelectionTool.h"
#import "BTSizeToPointSnapSource.h"

static int failures = 0;

static void check(BOOL aCondition, NSString *aWhat)
{
    if (!aCondition) {
        NSLog(@"FAIL: %@", aWhat);
        failures++;
    }
}

static BOOL near(CGFloat a, CGFloat b)
{
    return fabs(a - b) < 1e-9;
}

static BOOL nearPoint(CGPoint a, CGPoint b)
{
    return near(a.x, b.x) && near(a.y, b.y);
}

/* Mouse locations come from a settable point instead of a window. */
@interface TestModifyTool : BTModifySelectionTool
{
@public
    NSPoint location;
}
@end

@implementation TestModifyTool
- (NSPoint)eventLocationInImage:(id)aEvent { return location; }
- (NSPoint)eventLocationInView:(id)aEvent { return location; }
@end

@interface TestDelegate : NSObject
{
@public
    NSUndoManager *undoManager;
    NSMutableArray *stages;
}
@end

@implementation TestDelegate
- (id)layoutGuidingContextForTool:(id)aTool { return nil; }
- (id)mouseTrackingDelegateForTool:(id)aTool { return nil; }
- (id)imageViewTransformerForTool:(id)aTool { return nil; }
- (id)tool:(id)aTool willSetUndoActionName:(id)aName { return nil; }
- (void)tool:(id)aTool willRegisterUndoInManager:(id)aManager category:(id)aCategory {}
- (id)undoManagerForTool:(id)aTool category:(id)aCategory { return undoManager; }
- (BOOL)tool:(id)aTool didFinalizeStage:(id)aStage withEvent:(id)aEvent nextStage:(id)aNext
{
    [stages addObject:[NSString stringWithFormat:@"%@>%@", aStage, aNext]];
    return YES;
}
- (void)tool:(id)aTool didFinalizeOutputForKey:(id)aKey {}
- (void)tool:(id)aTool willUpdateOutputForKey:(id)aKey {}
- (void)tool:(id)aTool didUpdateOutputForKey:(id)aKey {}
- (void)tool:(id)aTool didUpdateCursorWithEvent:(id)aEvent {}
@end

static NSEvent *mouseEvent(NSEventType aType, NSUInteger aFlags)
{
    return [NSEvent mouseEventWithType:aType location:NSZeroPoint modifierFlags:aFlags timestamp:0 windowNumber:0 context:nil eventNumber:0 clickCount:1 pressure:1.0];
}

static CGAffineTransform transformOf(BTModifySelectionTool *aTool)
{
    CGAffineTransform t;
    [[aTool selectionAffineTransform] getValue:&t];
    return t;
}

/* One undo group around aBlock, then undone. */
static void undoGroup(NSUndoManager *aManager, void (^aBlock)(void))
{
    [aManager beginUndoGrouping];
    aBlock();
    [aManager endUndoGrouping];
}

static void drag(TestModifyTool *aTool, NSPoint aFrom, NSPoint aTo, NSUInteger aFlags)
{
    aTool->location = aFrom;
    [aTool mouseDown:mouseEvent(NSLeftMouseDown, 0)];
    [aTool trackMouseDown:mouseEvent(NSLeftMouseDown, aFlags) inView:nil];
    aTool->location = aTo;
    [aTool trackMouseDragged:mouseEvent(NSLeftMouseDragged, aFlags) inView:nil];
    [aTool trackMouseUp:mouseEvent(NSLeftMouseUp, aFlags) inView:nil];
}

int main(void)
{
    @autoreleasepool {
        TestModifyTool *tool = [[TestModifyTool alloc] init];
        check(CGAffineTransformIsIdentity(transformOf(tool)), @"starts untransformed");
        CGPathRef rect = CGPathCreateWithRect(CGRectMake(10, 20, 40, 30), NULL);
        [tool setSelectionPath:(id)rect];
        CGPathRelease(rect);
        check([tool selectionPath] != nil, @"path is kept");

        // Knobs: corners and sides counter clockwise from the bottom left, the handle right of the middle.
        struct { CGFloat x, y; NSInteger part; } hits[] = {
            { 30, 35, 1 }, { 10, 20, 2 }, { 10, 35, 3 }, { 10, 50, 4 }, { 30, 50, 5 }, { 50, 50, 6 },
            { 50, 35, 7 }, { 50, 20, 8 }, { 30, 20, 9 }, { 77.5, 35, 10 }, { 100, 100, 0 }, { 30, 27, 1 }, { 5, 35, 3 }, { -20, 35, 0 }
        };
        for (size_t i = 0; i < sizeof(hits) / sizeof(hits[0]); i++) {
            NSInteger part = [tool BTModifySelectionTool_selectionPartForPoint:NSMakePoint(hits[i].x, hits[i].y)];
            check(part == hits[i].part, [NSString stringWithFormat:@"part at (%g, %g) is %ld, got %ld", hits[i].x, hits[i].y, (long)hits[i].part, (long)part]);
        }
        check([[tool BTModifySelectionTool_cursorSubnameForSelectionPart:2] isEqualToString:@"ResizeBottomLeft"], @"bottom left cursor");
        check([[tool BTModifySelectionTool_cursorSubnameForSelectionPart:7] isEqualToString:@"ResizeCenterRight"], @"center right cursor");
        check([[tool BTModifySelectionTool_cursorSubnameForSelectionPart:10] isEqualToString:@"RotateCenterRight"], @"rotate cursor");
        check([[tool BTModifySelectionTool_cursorSubnameForSelectionPart:1] isEqualToString:@"Move"], @"move cursor");
        check([tool BTModifySelectionTool_cursorSubnameForSelectionPart:0] == nil, @"no cursor outside");
        check([tool cursorForPoint:NSMakePoint(30, 35) modifierFlags:0] == [NSCursor openHandCursor], @"will move cursor inside");
        check([tool doMoveSelectionCursor] == [NSCursor closedHandCursor], @"do move default");
        check([tool willResizeTopLeftSelectionCursor] == [NSCursor crosshairCursor], @"resize default");
        check([tool doRotateBottomCenterSelectionCursor] == [NSCursor pointingHandCursor], @"rotate default");
        [tool setWillMoveSelectionCursor:[NSCursor IBeamCursor]];
        check([tool cursorForPoint:NSMakePoint(30, 35) modifierFlags:0] == [NSCursor IBeamCursor], @"replaced cursor");
        check([[tool inputKeys] count] == 40 && [[tool outputKeys] count] == 2, @"keys");

        TestDelegate *delegate = [[TestDelegate alloc] init];
        delegate->undoManager = [[NSUndoManager alloc] init];
        [delegate->undoManager setGroupsByEvent:NO];
        delegate->stages = [NSMutableArray array];
        NSUndoManager *undo = delegate->undoManager;
        check([tool activateWithDelegate:delegate inView:nil], @"activates");

        undoGroup(undo, ^{ [tool moveSelectionBy:CGSizeMake(5, -3)]; });
        CGAffineTransform t = transformOf(tool);
        check(near(t.tx, 5) && near(t.ty, -3) && near(t.a, 1), @"moved");
        [undo undo];
        check(CGAffineTransformIsIdentity(transformOf(tool)), @"move undone");

        // A quarter turn keeps the bounds center and turns the knob names.
        undoGroup(undo, ^{ [tool rotateBy90DegreesCounterClockwise:nil]; });
        t = transformOf(tool);
        check(nearPoint(CGPointApplyAffineTransform(CGPointMake(30, 35), t), CGPointMake(30, 35)), @"rotation keeps the center");
        check(fabs(t.a) < 1e-12 && near(t.b, 1), @"quarter turn");
        check([[tool BTModifySelectionTool_cursorSubnameForSelectionPart:7] isEqualToString:@"ResizeTopCenter"], @"rotated side cursor");
        check([[tool BTModifySelectionTool_cursorSubnameForSelectionPart:10] isEqualToString:@"RotateTopCenter"], @"rotated handle cursor");
        undoGroup(undo, ^{ [tool unrotate:nil]; });
        check(CGAffineTransformEqualToTransform(transformOf(tool), CGAffineTransformIdentity) || fabs(transformOf(tool).b) < 1e-12, @"unrotated");
        undoGroup(undo, ^{ [tool reset:nil]; });
        check(CGAffineTransformIsIdentity(transformOf(tool)), @"reset");

        undoGroup(undo, ^{ [tool scaleSelectionAboutCenterBy:CGSizeMake(2, 0.5)]; });
        t = transformOf(tool);
        check(near(t.a, 2) && near(t.d, 0.5) && nearPoint(CGPointApplyAffineTransform(CGPointMake(30, 35), t), CGPointMake(30, 35)), @"scaled about the center");
        undoGroup(undo, ^{ [tool unscale:nil]; });
        t = transformOf(tool);
        check(near(t.a, 1) && near(t.d, 1), @"unscaled");
        undoGroup(undo, ^{ [tool reset:nil]; });

        undoGroup(undo, ^{ [tool flipHorizontally:nil]; });
        t = transformOf(tool);
        check([tool isSelectionFlippedHorizontally] && near(t.a, -1) && near(t.tx, 60), @"flipped horizontally");
        [undo undo];
        check(![tool isSelectionFlippedHorizontally] && CGAffineTransformIsIdentity(transformOf(tool)), @"flip undone");
        undoGroup(undo, ^{ [tool flipVertically:nil]; });
        t = transformOf(tool);
        check(![tool isSelectionFlippedHorizontally] && near(t.d, -1) && near(t.ty, 70), @"flipped vertically");
        undoGroup(undo, ^{ [tool reset:nil]; });

        // Dragging the top right corner to (90, 80) doubles the selection about the bottom left.
        [delegate->stages removeAllObjects];
        undoGroup(undo, ^{ drag(tool, NSMakePoint(50, 50), NSMakePoint(90, 80), 0); });
        t = transformOf(tool);
        check(near(t.a, 2) && near(t.d, 2) && near(t.tx, -10) && near(t.ty, -20), [NSString stringWithFormat:@"corner scale, got %g %g %g %g %g %g", t.a, t.b, t.c, t.d, t.tx, t.ty]);
        check(![tool isTracking] && [[tool currentStage] isEqualToString:@"BTWaitingToolStage"], @"tracking ended");
        check([delegate->stages containsObject:@"BTWaitingToolStage>BTModifyingSelectionToolStage"]
            && [delegate->stages containsObject:@"BTModifyingSelectionToolStage>BTWaitingToolStage"], @"stages");
        [undo undo];
        check(CGAffineTransformIsIdentity(transformOf(tool)), @"scale undone");

        // The center right knob scales x only; dragging past the left side flips.
        undoGroup(undo, ^{ drag(tool, NSMakePoint(50, 35), NSMakePoint(-30, 60), 0); });
        t = transformOf(tool);
        check(near(t.a, -1) && near(t.d, 1) && [tool isSelectionFlippedHorizontally], @"side drag flips");
        [undo undo];
        check(![tool isSelectionFlippedHorizontally] && CGAffineTransformIsIdentity(transformOf(tool)), @"side drag undone");

        // Dragging the handle a quarter turn around the center, snapping to 45 degrees with Shift.
        undoGroup(undo, ^{ drag(tool, NSMakePoint(77.5, 35), NSMakePoint(32, 82), NSShiftKeyMask); });
        t = transformOf(tool);
        check(fabs(t.a) < 1e-12 && near(t.b, 1) && nearPoint(CGPointApplyAffineTransform(CGPointMake(30, 35), t), CGPointMake(30, 35)), @"handle rotation");
        [undo undo];
        check(CGAffineTransformIsIdentity(transformOf(tool)), @"rotation undone");

        // Moving by the inside.
        undoGroup(undo, ^{ drag(tool, NSMakePoint(30, 35), NSMakePoint(36, 31), 0); });
        t = transformOf(tool);
        check(near(t.tx, 6) && near(t.ty, -4), @"drag moves");
        undoGroup(undo, ^{ [tool reset:nil]; });

        // Snap sources reflect a snapped corner onto the dragged knob.
        NSArray *sources = [tool BTModifySelectionTool_pointSnapSourcesForResizingSelectionByCornerAtIndex:2 aboutPoint:CGPointMake(30, 35) proportionally:YES withReflectingPoint:CGPointMake(50, 50)];
        check([sources count] == 4, @"four corner sources");
        BTPointToPointSnapSource *dragged = [sources objectAtIndex:0], *opposite = [sources objectAtIndex:1];
        check(nearPoint([dragged point], CGPointMake(50, 50)) && nearPoint([dragged reflectedPointForPoint:CGPointMake(60, 60)], CGPointMake(60, 60)), @"dragged corner reflects onto itself");
        check(nearPoint([opposite point], CGPointMake(10, 20)) && nearPoint([opposite reflectedPointForPoint:CGPointMake(0, 10)], CGPointMake(60, 60)), @"opposite corner mirrors about the center");
        CGELine line = [dragged trajectoryLine];
        check(near(line.a * 30 + line.b * 35 + line.c, 0) && near(line.a * 50 + line.b * 50 + line.c, 0), @"proportional line through the center");
        sources = [tool BTModifySelectionTool_pointSnapSourcesForResizingSelectionBySideWithCornerAtIndex:2 andCornerAtIndex:3 proportionally:NO withReflectingPoint:CGPointMake(50, 35)];
        check([sources count] == 2 && nearPoint([(BTPointToPointSnapSource *)[sources objectAtIndex:0] point], CGPointMake(50, 50))
            && nearPoint([(BTPointToPointSnapSource *)[sources objectAtIndex:0] reflectedPointForPoint:CGPointMake(60, 50)], CGPointMake(60, 35)), @"side sources reflect onto the middle");
        check([[tool BTModifySelectionTool_pointSnapSourcesForResizingSelectionByCornerAtIndex:0 proportionally:NO withReflectingPoint:CGPointZero] count] == 1, @"corner only source");

        // Feedback: white knob centers with red rims, ants on the bounds.
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(NULL, 128, 128, 8, 128 * 4, space, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
        CGColorSpaceRelease(space);
        [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithCGContext:context flipped:NO]];
        [tool draw_BTSelectionFeedbackLayer_Rect:NSMakeRect(0, 0, 128, 128)];
        [NSGraphicsContext setCurrentContext:nil];
        const uint8_t *data = CGBitmapContextGetData(context);
        const uint8_t *knob = data + (127 - 20) * 128 * 4 + 10 * 4;
        const uint8_t *rim = data + (127 - 20) * 128 * 4 + 8 * 4;
        const uint8_t *inside = data + (127 - 40) * 128 * 4 + 40 * 4;
        check(knob[0] == 255 && knob[1] == 255 && knob[2] == 255 && knob[3] == 255, @"knob center is white");
        check(rim[0] > 200 && rim[1] < 60 && rim[3] > 200, @"knob rim is red");
        check(inside[3] == 0, @"inside stays clear");
        int ants = 0;
        for (int x = 14; x < 46; x++)
            if (data[(127 - 49) * 128 * 4 + x * 4 + 3] != 0)
                ants++;
        check(ants > 20, [NSString stringWithFormat:@"ants along the top, %d pixels", ants]);
        CGContextRelease(context);

        [tool performDeactivate];
        [tool release];
        [undo release];
        [delegate release];
    }
    if (failures == 0)
        printf("modifyselectiontest passed\n");
    return failures != 0;
}
