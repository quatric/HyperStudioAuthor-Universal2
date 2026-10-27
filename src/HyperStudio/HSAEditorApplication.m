#import "HSAEditorApplication.h"
static BOOL sMouseMovedPending;
static id sValidateActionItem;


@implementation HSAEditorApplication

/* i386 ivar offsets: _colorPickerMode=0x4c, _keyEventsConsumer=0x50 */

+ (id)sharedHyperApplication
{
    NSApplication *self_00;
    BOOL pvVar2;
    id pvVar1_2;

    self_00 = [self sharedApplication];
    pvVar2 = [self_00 isKindOfClass:[HSAEditorApplication class]];
    pvVar1_2 = nil;
    if (pvVar2) {
        pvVar1_2 = self_00;
    }
    return pvVar1_2;
}

- (void)hide:(id)aHide
{
    if (![[[[NSDocumentController sharedDocumentController] currentDocument] modeSwitcher] switching]) {
        [super hide:aHide];
    }
}

- (void)setColorPickerMode:(NSInteger)aMode
{
    _colorPickerMode = aMode;
}

- (void)toggleColorPanel:(id)aPanel
{
    if (![[NSColorPanel sharedColorPanel] isVisible]) {
        [NSColorPanel setPickerMode:_colorPickerMode];
        _colorPickerMode = 7;
    }
    [NSApp orderFrontColorPanel:aPanel];
}

- (void)orderFrontFontPanel:(id)aPanel
{
    [[NSFontManager sharedFontManager] orderFrontFontPanel:aPanel];
}

- (BOOL)validateUserInterfaceItem:(id)aItem
{
    SEL action = (SEL)[(id<NSValidatedUserInterfaceItem>)aItem action];
    id document = [[NSDocumentController sharedDocumentController] currentDocument];
    if (document == nil) {
        document = [[[NSDocumentController sharedDocumentController] documents] lastObject];
    }
    if ([[document actionExecutionContext] waitingForMouseDownEvent]) {
        return action == @selector(showHelp:);
    }
    if (action == @selector(runPageLayout:)) {
        document = [[NSDocumentController sharedDocumentController] currentDocument];
        if (document == nil) {
            return NO;
        }
        return ![[document currentWindowController] isSheetRunning];
    }
    if (action != @selector(terminate:)) {
        BOOL visible;
        if (action == @selector(orderFrontFontPanel:)) {
            if (![aItem respondsToSelector:@selector(setState:)]) {
                return YES;
            }
            visible = [[NSFontPanel sharedFontPanel] isVisible];
        } else {
            if (action != @selector(toggleColorPanel:)) {
                return YES;
            }
            if (![aItem respondsToSelector:@selector(setState:)]) {
                return YES;
            }
            visible = [[NSColorPanel sharedColorPanel] isVisible];
        }
        [aItem setState:visible];
        return YES;
    }
    return [[NSApplication sharedApplication] modalWindow] == nil;
    return 0;
}

- (void)sendEvent:(id)aEvent
{
    NSUInteger type = [(NSEvent *)aEvent type];
    SEL performSelector = NULL;
    SEL targetSelector = NULL;
    switch (type) {
    case 5:
        sMouseMovedPending = YES;
        break;
    case 8:
    case 9:
        if ([[[[NSDocumentController sharedDocumentController] currentDocument] modeSwitcher] switching]) {
            goto finish;
        }
        break;
    case 10:
        if ([[aEvent characters] length] != 0) {
            [_keyEventsConsumer processKeyDownEvent:aEvent];
            NSUInteger flags = [(NSEvent *)aEvent modifierFlags];
            unsigned short character = [[aEvent characters] characterAtIndex:0];
            unsigned short unmodified = 0;
            if ([[aEvent charactersIgnoringModifiers] length] != 0) {
                unmodified = [[aEvent charactersIgnoringModifiers] characterAtIndex:0];
            }
            NSUInteger modifiers = flags & 0xffff0000;
            BOOL single = [[aEvent characters] length] == 1;
            if (single && character == 9) {
                performSelector = @selector(togglePlayEditViaGlobalShortcut:);
                targetSelector = @selector(togglePlayEdit:);
                if ((modifiers | 0x10000) != 0x50000) {
                    break;
                }
                goto dispatch;
            }
            if (single && character == 0x19) {
                performSelector = targetSelector = @selector(switchToRectSelectionToolViaGlobalShortcut:);
                if ((modifiers | 0x10000) == 0x70000) {
                    goto dispatch;
                }
                break;
            }
            if (single && (character == 0x5b || character == 0x5d)) {
                if ((modifiers | 0x10000) == 0x110000) {
                    performSelector = targetSelector = @selector(switchToPreviousObjectAssistantPaneViaGlobalShortcut:);
                    if (character == 0x5d) {
                        performSelector = targetSelector = @selector(switchToNextObjectAssistantPaneViaGlobalShortcut:);
                    }
                    goto dispatch;
                }
                break;
            }
            if (single && (unmodified == 0x2b || unmodified == 0x3d)) {
                performSelector = targetSelector = @selector(zoomIn:);
                if (modifiers == 0x80000 || modifiers == 0x280000 || modifiers == 0x2a0000) {
                    goto dispatch;
                }
                break;
            }
            if (single && (unmodified == 0x2d || unmodified == 0x5f)) {
                performSelector = targetSelector = @selector(zoomOut:);
                if (modifiers == 0xa0000) {
                    goto dispatch;
                }
                break;
            }
            if (single && (unmodified | 0x10) == 0x3c
                && ![[[[NSDocumentController sharedDocumentController] currentDocument] actionExecutionContext] waitingForMouseDownEvent]) {
                if ((flags & 0x100000) == 0) {
                    break;
                }
                goto previousCard;
            }
            if (single && (unmodified | 0x10) == 0x3e
                && ![[[[NSDocumentController sharedDocumentController] currentDocument] actionExecutionContext] waitingForMouseDownEvent]) {
                if ((flags & 0x180000) == 0x180000 || (flags & 0x1a0000) == 0x1a0000) {
                    goto nextCard;
                }
                performSelector = targetSelector = @selector(goToNextCardWithoutLeaveActions:);
                if ((flags & 0x100000) != 0) {
                    goto dispatch;
                }
                break;
            }
            if (single) {
                if (![[[HSEditorController sharedDocumentController] currentDocument] isInPurePlayerMode]
                    && ![[[HSEditorController sharedDocumentController] currentDocument] isInPresentationMode]) {
                    break;
                }
                switch (character) {
                case 0xf700:
                case 0xf702:
                case 0xf72c:
                previousCard:
                    performSelector = targetSelector = @selector(goToPreviousCardWithoutLeaveActions:);
                    break;
                case 0xf701:
                case 0xf703:
                case 0xf72d:
                nextCard:
                    performSelector = targetSelector = @selector(advanceToNextCardWithoutLeaveActions:);
                    break;
                case 0xf729:
                    performSelector = targetSelector = @selector(goToFirstCardWithoutLeaveActions:);
                    break;
                case 0xf72b:
                    performSelector = targetSelector = @selector(goToLastCardWithoutLeaveActions:);
                    break;
                default:
                    goto forward;
                }
            dispatch:
                {
                    id target = [self targetForAction:targetSelector to:nil from:self];
                    if (target != nil && performSelector != NULL && [self performAction:performSelector target:target validate:YES]) {
                        goto finish;
                    }
                }
            }
        }
        break;
    case 11:
        [_keyEventsConsumer processKeyUpEvent:aEvent];
        break;
    }
forward:
    if (type != 0x16 || [aEvent momentumPhase] == 0) {
        [super sendEvent:aEvent];
    } else {
        [[(NSEvent *)aEvent window] sendEvent:aEvent];
    }
finish:
    if (type == 0xc) {
        id mainWindow = [self mainWindow];
        if (mainWindow != [self keyWindow]) {
            [(NSWindow *)mainWindow sendEvent:aEvent];
        }
    } else if (type == 5 && sMouseMovedPending) {
        NSWindow *mainWindow = [self mainWindow];
        if (![mainWindow acceptsMouseMovedEvents]) {
            sMouseMovedPending = NO;
        } else {
            NSWindow *eventWindow = [aEvent window];
            if (mainWindow != eventWindow) {
                NSPoint location = [(NSEvent *)aEvent locationInWindow];
                if (eventWindow != nil) {
                    location = [eventWindow convertBaseToScreen:location];
                }
                location = [mainWindow convertScreenToBase:location];
                aEvent = [NSEvent mouseEventWithType:NSMouseMoved location:location modifierFlags:[(NSEvent *)aEvent modifierFlags] timestamp:[(NSEvent *)aEvent timestamp] windowNumber:[mainWindow windowNumber] context:[mainWindow graphicsContext] eventNumber:[(NSEvent *)aEvent eventNumber] clickCount:[(NSEvent *)aEvent clickCount] pressure:[(NSEvent *)aEvent pressure]];
            }
            [mainWindow mouseMoved:aEvent];
        }
    }
}

- (BOOL)sendAction:(SEL)aAction to:(id)aTo from:(id)aFrom
{
    [[[HSEditorController sharedDocumentController] currentDocument] finalizeBitmapToolIfNeededForAction:aAction to:aTo from:aFrom];
    return (BOOL)[super sendAction:aAction to:aTo from:aFrom];
}

- (void)noteMainWindowDidHandleMouseMovedEvent
{
    sMouseMovedPending = NO;
}

- (BOOL)performAction:(SEL)aAction target:(id)aTarget validate:(BOOL)aValidate
{
    if (aTarget == nil) {
        return NO;
    }
    if (aValidate) {
        if (sValidateActionItem == nil) {
            sValidateActionItem = [HSValidateActionItem new];
        }
        [sValidateActionItem setAction:aAction];
        if ([aTarget conformsToProtocol:@protocol(NSUserInterfaceValidations)]) {
            if (![aTarget validateUserInterfaceItem:sValidateActionItem]) {
                return NO;
            }
        }
    }
    [aTarget performSelector:aAction withObject:self];
    return YES;
}

- (void)hideSplashWindow
{
    [[HSSplashScreenWindowController sharedSplashWindow] hideSplashWaitUntilTimeout:NO];
}

- (void)beginSheet:(id)aSheet modalForWindow:(id)aWindow modalDelegate:(id)aDelegate didEndSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    [self hideSplashWindow];
    [super beginSheet:aSheet modalForWindow:aWindow modalDelegate:aDelegate didEndSelector:aSelector contextInfo:aInfo];
}

- (struct _NSModalSession *)beginModalSessionForWindow:(id)aWindow relativeToWindow:(id)aWindow2
{
    [self hideSplashWindow];
    return [super beginModalSessionForWindow:aWindow relativeToWindow:aWindow2];
}

- (struct _NSModalSession *)beginModalSessionForWindow:(id)aWindow
{
    [self hideSplashWindow];
    return [super beginModalSessionForWindow:aWindow];
}

- (NSInteger)runModalForWindow:(id)aWindow relativeToWindow:(id)aWindow2
{
    [self hideSplashWindow];
    return (int)[super runModalForWindow:aWindow relativeToWindow:aWindow2];
}

- (NSInteger)runModalForWindow:(id)aWindow
{
    [self hideSplashWindow];
    return (int)[super runModalForWindow:aWindow];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _colorPickerMode = 7;
        _keyEventsConsumer = [HSKeysRegistry sharedRegistry];
    }
    return self;
}

@end

@implementation HSValidateActionItem

/* i386 ivar offsets: _action=0x4 */

- (void)setAction:(SEL)aAction
{
    _action = aAction;
}

- (SEL)action
{
    return _action;
}

- (NSInteger)tag
{
    return 0;
}

@end

