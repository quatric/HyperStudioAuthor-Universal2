#import "HSGenericModalController.h"

@implementation HSGenericModalController
// A sheet ends with the flag as its return code; applies changes on OK.
- (void)finishDialog:(BOOL)aDialog
{
    [self willCloseWindow];
    if ([[self window] isSheet]) {
        [NSApp endSheet:[self window] returnCode:aDialog];
        [_sheetWindow release];
        _sheetWindow = nil;
    } else {
        [NSApp stopModalWithCode:aDialog];
    }
    if (aDialog)
        [self applyChanges];
}
- (void)continueDialog
{
    if (_runningAsSheet)
        [NSApp beginSheet:[self window] modalForWindow:_sheetWindow modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
    else
        [[self window] makeKeyAndOrderFront:self];
    _isPaused = NO;
}
- (void)pauseDialog
{
    _isPaused = YES;
    if (_runningAsSheet)
        [NSApp endSheet:[self window]];
    [[self window] orderOut:self];
}
- (void)cancel:(id)aCancel
{
    [self willCloseWindow];
    if ([[self window] isSheet])
        [NSApp endSheet:[self window] returnCode:0];
    else
        [NSApp stopModalWithCode:0];
}
// Ends editing first so the field editor commits its value.
- (void)ok:(id)aOk
{
    if ([[self window] makeFirstResponder:[self window]])
        [self finishDialog:YES];
}
// Calls didEndSelector(controller, returnCode) on the delegate unless paused.
- (void)sheetDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    if (_isPaused)
        return;
    id delegate = _delegate;
    HSGenericModalController *controller = self;
    NSInteger code = aCode;
    _delegate = nil;
    [[self window] orderOut:self];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[delegate methodSignatureForSelector:_didEndSelector]];
    [invocation setTarget:delegate];
    [invocation setSelector:_didEndSelector];
    [invocation setArgument:&controller atIndex:2];
    [invocation setArgument:&code atIndex:3];
    [invocation invoke];
}
- (void)runForWindow:(id)aWindow delegate:(id)aDelegate didEndSelector:(SEL)aSelector
{
    _delegate = aDelegate;
    _didEndSelector = aSelector;
    [self window];
    _runningAsSheet = YES;
    _sheetWindow = [aWindow retain];
    [self willShowWindow];
    [NSApp beginSheet:[self window] modalForWindow:aWindow modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
}
- (NSInteger)runModalWithDelegate:(id)aDelegate
{
    _delegate = aDelegate;
    return [self runModal];
}
- (NSInteger)runModal
{
    [self window];
    _runningAsSheet = NO;
    [self willShowWindow];
    NSInteger result = [NSApp runModalForWindow:[self window]];
    [[self window] orderOut:self];
    return result;
}
- (void)applyChanges
{
}
- (void)willCloseWindow
{
}
- (void)willShowWindow
{
}
- (void)didLoadNib
{
}
// Subclasses name their nib.
- (id)nibName
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
- (id)parentWindow
{
    return _sheetWindow;
}
- (id)window
{
    if (!_window)
        [self loadUI];
    return _window;
}
- (void)loadUI
{
    if (_window)
        return;
    if ([NSBundle loadNibNamed:[self nibName] owner:self]) {
        [self didLoadNib];
        [[self window] setDefaultButtonCell:[_defaultButton cell]];
        [[[self window] firstResponder] setNextResponder:self];
    }
}
- (void)dealloc
{
    [_window release];
    [super dealloc];
}
- (id)delegate
{
    return _delegate;
}
@end

@implementation HSGenericModalController (ButtonObjectValidation)
// With aIcon, at least one of the buttons must show its icon.
+ (BOOL)isValidButtonObject:(id)aObject validateIcon:(BOOL)aIcon
{
    id button = [aObject queryHyperInterface:@protocol(HSButtonObjectAttributes)];
    if (!button)
        return NO;
    if (!aIcon)
        return YES;
    if (![button isHyperAllProxy])
        return [button isIconVisible];
    NSEnumerator *enumerator = [[button allHyperInterfaces] objectEnumerator];
    id interface;
    while ((interface = [enumerator nextObject])) {
        if ([interface isIconVisible])
            return YES;
    }
    return NO;
}
@end

@implementation HSGenericModalController (PreviewImageVisualRectCalculation)
// The rect at the origin sized like the object's visible image: system
// image views use their cell's drawing rect, other geometry its frame size.
+ (NSRect)previewImageVisualRectForObject:(id)aObject
{
    NSRect rect = NSZeroRect;
    id geometry = [aObject queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (geometry) {
        id system = [aObject queryHyperInterface:@protocol(HSSystemObjectAttributes)];
        if (system) {
            NSView *view = [system hyperSystemView];
            if (view && [view isKindOfClass:[NSImageView class]])
                rect.size = [[(NSImageView *)view cell] drawingRectForBounds:[view bounds]].size;
        } else {
            rect.size = [geometry affineFrameSize];
        }
    } else {
        id image = [aObject queryHyperInterface:@protocol(HSImageAttributes)];
        if (image)
            rect.size = [image imageRect].size;
    }
    return rect;
}
@end
