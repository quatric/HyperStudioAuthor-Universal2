#import "HSBaseBitmapToolCanvasLayer.h"
// Canvas sublayer that hosts a bitmap tool. Events, drawing and any
// message the layer itself doesn't understand go to the tool's
// underlying bitmap tool (`[_tool bitmapTool]`). The tool isn't retained.

static NSString *HSBaseBitmapToolCanvasLayerLocalized(NSString *aKey)
{
    return [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:aKey value:@"" table:@"Editor"];
}

@implementation HSBaseBitmapToolCanvasLayer

// Actions the layer doesn't handle are validated by the bitmap tool. A
// region editing tool needs a selection. Copy, Cut and Delete are
// retitled to "Copy Selection" and the like.
- (BOOL)validateUserInterfaceItem:(id)aItem
{
    SEL action = [(id<NSValidatedUserInterfaceItem>)aItem action];
    if ([super respondsToSelector:action])
        return YES;
    if (![(BTTool *)[_tool bitmapTool] validateAction:action])
        return NO;
    BOOL valid = YES;
    if ([(BTTool *)[_tool bitmapTool] isKindOfClass:[BTRegionEditingTool class]])
        valid = [(BTRegionEditingTool *)[_tool bitmapTool] selectionPath] != nil;
    NSString *format;
    if (action == @selector(copy:))
        format = @"HSCopyFormat";
    else if (action == @selector(cut:))
        format = @"HSCutFormat";
    else if (action == @selector(delete:))
        format = @"HSDeleteFormat";
    else
        return valid;
    NSString *selection = HSBaseBitmapToolCanvasLayerLocalized(@"Selection");
    [aItem setTitle:[NSString stringWithFormat:HSBaseBitmapToolCanvasLayerLocalized(format), selection]];
    return valid;
}

- (void)forwardInvocation:(id)aInvocation
{
    id bitmapTool = [_tool bitmapTool];
    if (bitmapTool)
        [aInvocation invokeWithTarget:bitmapTool];
    else
        [super forwardInvocation:aInvocation];
}

- (id)methodSignatureForSelector:(SEL)aSelector
{
    id signature = [super methodSignatureForSelector:aSelector];
    if (!signature)
        signature = [(BTTool *)[_tool bitmapTool] methodSignatureForSelector:aSelector];
    return signature;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector])
        return YES;
    return [(BTTool *)[_tool bitmapTool] respondsToSelector:aSelector];
}

- (void)representedObjectDidChange
{
    [_tool reactivate];
}

- (BOOL)handleRawKeyDownEvent:(id)aEvent
{
    return [(BTTool *)[_tool bitmapTool] keyDown:aEvent];
}

- (BOOL)handleFlagsChanged:(id)aChanged atPoint:(NSPoint)aPoint
{
    return [(BTTool *)[_tool bitmapTool] flagsChanged:aChanged];
}

- (BOOL)handleMouseMovedAtPoint:(NSPoint)aPoint insideView:(BOOL)aView event:(id)aEvent
{
    return [(BTTool *)[_tool bitmapTool] mouseMoved:aEvent];
}

- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent
{
    if (aView && [_tool isActiveAtPoint:aPoint]) {
        id cursor = [(BTTool *)[_tool bitmapTool] cursorForPoint:aPoint modifierFlags:aFlags];
        if (cursor)
            return [[[HSCursor alloc] initWithCursor:cursor] autorelease];
    }
    return nil;
}

- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    return [(BTTool *)[_tool bitmapTool] mouseDown:aEvent];
}

// The layer covers the whole canvas.
- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo
{
    return self;
}

- (void)renderRect:(NSRect)aRect
{
    [(BTTool *)[_tool bitmapTool] drawRect:aRect];
}

- (void)setTool:(id)aTool
{
    _tool = aTool;
}

- (id)tool
{
    return _tool;
}

@end
