#import "HSEditorSelectionSync.h"

@implementation HSEditorSelectionSync

/* i386 ivar offsets: _stackSelectionHost=0x10, _thisCardSelectionHost=0x14, _cardObjectsSelectionHost=0x18, _cardObjectsSecondarySelectionHost=0x1c, _notifyingWindow=0x20 */

+ (BOOL)isEnabledByDefault
{
    return NO;
}

- (void)windowWillClose:(id)aClose
{
    [self noteWindowControllerWillClose];
}

- (void)windowDidBecomeMain:(id)aMain
{
    [self noteWindowControllerDidBecomeMain];
}

- (void)setWindowController:(id)aController
{
    [self setNotifyingWindow:[aController window]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001f1ea6 @ 001f1ea6, 473 bytes * /

void FUN_001f1ea6(HSEditorSelectionSync *self,SEL _cmd,id setNotifyingWindow)

{
  id pvVar1;
  id pvVar2;
  HSEditorSelectionSync *pHVar3;
  undefined *puVar4;
  undefined4 uVar5;
  
  if (self->_notifyingWindow != setNotifyingWindow) {
    pvVar1 = (id)0x0;
    if (self->_notifyingWindow != (id)0x0) {
      pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
      _objc_msgSend(pvVar1,sel_removeObserver_name_object_,self,*(undefined4 *)PTR_003367cc,
                    self->_notifyingWindow);
      pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
      _objc_msgSend(pvVar1,sel_removeObserver_name_object_,self,*(undefined4 *)PTR_00336584,
                    self->_notifyingWindow);
      _objc_msgSend(self,sel_noteWindowControllerWillResignMain);
      pvVar1 = self->_notifyingWindow;
    }
    _objc_msgSend(pvVar1,sel_autorelease);
    pvVar1 = _objc_msgSend(setNotifyingWindow,sel_retain);
    self->_notifyingWindow = pvVar1;
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
      _objc_msgSend(pvVar1,sel_addObserver_selector_name_object_,self,sel_windowDidBecomeMain_,
                    *(undefined4 *)PTR_003367cc,self->_notifyingWindow);
      pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
      uVar5 = *(undefined4 *)PTR_00336584;
      pvVar1 = self->_notifyingWindow;
      pHVar3 = self;
      puVar4 = sel_windowWillClose_;
      _objc_msgSend(pvVar2,sel_addObserver_selector_name_object_,self,sel_windowWillClose_,uVar5,
                    pvVar1);
      pvVar2 = _objc_msgSend(self->_notifyingWindow,sel_isMainWindow);
      if ((char)pvVar2 != '\0') {
        _objc_msgSend(self,sel_noteWindowControllerDidBecomeMain,pHVar3,puVar4,uVar5,pvVar1);
      }
    }
  }
  return;
}

*/
- (void)setNotifyingWindow:(id)aWindow
{
    if (_notifyingWindow != aWindow) {
        if (_notifyingWindow != nil) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeMainNotification object:_notifyingWindow];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillCloseNotification object:_notifyingWindow];
            [self noteWindowControllerWillResignMain];
        }
        [_notifyingWindow autorelease];
        _notifyingWindow = [aWindow retain];
        if (_notifyingWindow != nil) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidBecomeMain:) name:NSWindowDidBecomeMainNotification object:_notifyingWindow];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:_notifyingWindow];
            if ([_notifyingWindow isMainWindow]) {
                [self noteWindowControllerDidBecomeMain];
            }
        }
    }
}

- (void)noteWindowControllerWillClose
{
    [self setEnabled:NO];
    [[HSGlobalSelectionSync globalSelectionSync] editorSelectionSyncWillResignActive:self];
}

- (void)noteWindowControllerWillResignMain
{
    [[HSGlobalSelectionSync globalSelectionSync] editorSelectionSyncWillResignActive:self];
}

- (void)noteWindowControllerDidBecomeMain
{
    [[HSGlobalSelectionSync globalSelectionSync] editorSelectionSyncDidBecomeActive:self];
}

- (void)setObjectBrowser:(id)aBrowser
{
    id pvVar1;
    id pvVar2;
    id pvVar2_2;

    if (_cardObjectsSecondarySelectionHost != aBrowser) {
        pvVar1 = [self currentSelectionHost];
        pvVar2 = _cardObjectsSecondarySelectionHost;
        if (pvVar1 == pvVar2) {
            [self setCurrentSelectionHost:_cardObjectsSelectionHost];
            pvVar2 = _cardObjectsSecondarySelectionHost;
        }
        [pvVar2 setDocumentSelectionHolder:nil];
        [_cardObjectsSecondarySelectionHost release];
        pvVar2_2 = [aBrowser retain];
        _cardObjectsSecondarySelectionHost = pvVar2_2;
        [pvVar2_2 setDocumentSelectionHolder:self];
    }
}

- (void)setCardView:(id)aView
{
    id pvVar1;
    id pvVar3;
    id pvVar3_2;

    if (_cardObjectsSelectionHost != aView) {
        pvVar1 = [self currentSelectionHost];
        pvVar3 = _cardObjectsSelectionHost;
        if (pvVar1 == pvVar3) {
            [self setCurrentSelectionHost:nil];
            pvVar3 = _cardObjectsSelectionHost;
        }
        if ([pvVar3 documentSelectionHolder] == self) {
            [_cardObjectsSelectionHost setDocumentSelectionHolder:nil];
        }
        [_cardObjectsSelectionHost release];
        pvVar3_2 = [aView retain];
        _cardObjectsSelectionHost = pvVar3_2;
        [pvVar3_2 setDocumentSelectionHolder:self];
    }
}

- (void)setThisCardSelectionHost:(id)aHost
{
    id pvVar1;
    id pvVar2;
    id pvVar2_2;

    if (_thisCardSelectionHost != aHost) {
        pvVar1 = [self currentSelectionHost];
        pvVar2 = _thisCardSelectionHost;
        if (pvVar1 == pvVar2) {
            [self setCurrentSelectionHost:nil];
            pvVar2 = _thisCardSelectionHost;
        }
        [pvVar2 setDocumentSelectionHolder:nil];
        [_thisCardSelectionHost release];
        pvVar2_2 = [aHost retain];
        _thisCardSelectionHost = pvVar2_2;
        [pvVar2_2 setDocumentSelectionHolder:self];
    }
}

- (void)setStackSelectionHost:(id)aHost
{
    id pvVar1;
    id pvVar2;
    id pvVar2_2;

    if (_stackSelectionHost != aHost) {
        pvVar1 = [self currentSelectionHost];
        pvVar2 = _stackSelectionHost;
        if (pvVar1 == pvVar2) {
            [self setCurrentSelectionHost:nil];
            pvVar2 = _stackSelectionHost;
        }
        [pvVar2 setDocumentSelectionHolder:nil];
        [_stackSelectionHost release];
        pvVar2_2 = [aHost retain];
        _stackSelectionHost = pvVar2_2;
        [pvVar2_2 setDocumentSelectionHolder:self];
    }
}

- (void)selectionHostDidChangeSelectedObject:(id)aObject
{
    [self updateOtherSelectionHostsWithChangedSelectionHost:aObject];
    if ([self currentSelectionHost] == aObject) {
        [self refreshCurrentlySelectedObjectAndNotify:YES];
    }
}

- (void)makeCurrentSelectionHost:(id)aHost
{
    [self setCurrentSelectionHost:aHost andNotify:YES];
}

- (BOOL)isRegisteredSelectionHost:(id)aHost
{
    if (aHost == nil) {
        return NO;
    }
    if (((_stackSelectionHost != aHost) && (_thisCardSelectionHost != aHost)) && (_cardObjectsSelectionHost != aHost)) {
        return _cardObjectsSecondarySelectionHost == aHost;
    }
    return YES;
}

- (id)ownSelectedObject
{
    return [self currentSelectedObject];
}

- (id)currentSelectionHost
{
    return [super currentSelectionHost];
}

- (void)notifySelectionDidChange
{
    [[HSGlobalSelectionSync globalSelectionSync] editorSelectionSyncDidChangeSelection:self];
}

- (void)updateOtherSelectionHostsWithChangedSelectionHost:(id)aHost
{
    id pvVar1;

    pvVar1 = _cardObjectsSelectionHost;
    if (pvVar1 == aHost) {
        pvVar1 = _cardObjectsSecondarySelectionHost;
    }
    if (_cardObjectsSecondarySelectionHost != aHost) {
        return;
    }
    [self updateSelectionHost:pvVar1 withChangedSelectionHost:aHost];
}

- (void)updateSelectionHost:(id)aHost withChangedSelectionHost:(id)aHost2
{
    [aHost updateSelectionWithSelectedObject:[aHost2 ownSelectedObject]];
}

- (void)dealloc
{
    int uVar2;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    uVar2 = 0;
    [_stackSelectionHost setDocumentSelectionHolder:nil];
    [_stackSelectionHost release];
    if ([_thisCardSelectionHost documentSelectionHolder] == self) {
        uVar2 = 0;
        [_thisCardSelectionHost setDocumentSelectionHolder:nil];
    }
    [_thisCardSelectionHost release];
    uVar2 = 0;
    [_cardObjectsSelectionHost setDocumentSelectionHolder:nil];
    [_cardObjectsSelectionHost release];
    if ([_cardObjectsSecondarySelectionHost documentSelectionHolder] == self) {
        uVar2 = 0;
        [_cardObjectsSecondarySelectionHost setDocumentSelectionHolder:nil];
    }
    [_cardObjectsSecondarySelectionHost release];
    [_notifyingWindow release];
    [super dealloc];
}

@end

