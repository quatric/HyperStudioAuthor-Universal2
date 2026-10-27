#import "HSUndoableGroup.h"

@implementation HSUndoableGroup

/* i386 ivar offsets: _internalUndoManager=0x4, _outerUndoManager=0x8, _isClosed=0xc, _modelDelegate=0x10, _actionName=0x14, _cancelsEditingAfterLastUndoOperation=0x18 */

+ (id)createOpenedWithModelDelegate:(id)aDelegate
{
    return [[self alloc] initWithModelDelegate:aDelegate];
}

- (void)setActionName:(id)aName
{
    if (_actionName != aName) {
        [_actionName release];
        _actionName = [aName retain];
    }
}

- (id)actionName
{
    return _actionName;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00066616 @ 00066616, 309 bytes * /

void FUN_00066616(HSUndoableGroup *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  
  while( true ) {
    pvVar1 = _objc_msgSend(self->_internalUndoManager,sel_canUndo);
    if ((char)pvVar1 == '\0') break;
    _objc_msgSend(self->_internalUndoManager,sel_undo);
  }
  pvVar1 = _objc_msgSend(self,sel_modelDelegate);
  pvVar2 = _objc_msgSend(self,sel_outerUndoManager);
  _objc_msgSend(pvVar1,sel_setUndoManager_,pvVar2);
  pvVar1 = _objc_msgSend(self,sel_outerUndoManager);
  _objc_msgSend(pvVar1,sel_beginUndoGrouping);
  pvVar1 = _objc_msgSend(self,sel_outerUndoManager);
  pvVar2 = _objc_msgSend(self,sel_actionName);
  op = sel_setActionName_;
  while( true ) {
    _objc_msgSend(pvVar1,op,pvVar2);
    pvVar1 = _objc_msgSend(self->_internalUndoManager,sel_canRedo);
    if ((char)pvVar1 == '\0') break;
    pvVar1 = self->_internalUndoManager;
    op = sel_redo;
  }
  pvVar1 = _objc_msgSend(self,sel_outerUndoManager,pvVar2);
  _objc_msgSend(pvVar1,sel_endUndoGrouping);
  return;
}

*/
- (void)transferActionsToOuterUndoManager
{
    while ([_internalUndoManager canUndo]) {
        [_internalUndoManager undo];
    }
    [[self modelDelegate] setUndoManager:[self outerUndoManager]];
    [[self outerUndoManager] beginUndoGrouping];
    [[self outerUndoManager] setActionName:[self actionName]];
    while ([_internalUndoManager canRedo]) {
        [_internalUndoManager redo];
    }
    [[self outerUndoManager] endUndoGrouping];
}

- (void)undoLimitSentinel
{
    id pvVar1_2;

    if (_isClosed == NO) {
        pvVar1_2 = [[self modelDelegate] retain];
        if ([self cancelsEditingAfterLastUndoOperation]) {
            [pvVar1_2 undoableGroupWillCancelEditingAfterLastUndoOperation:self];
            if ([self isOpened]) {
                [self cancelChanges];
            }
        }
        [pvVar1_2 release];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000667fb @ 000667fb, 95 bytes * /

void FUN_000667fb(HSUndoableGroup *self,SEL _cmd,BOOL setCancelsEditingAfterLastUndoOperation)

{
  id self_00;
  SEL op;
  HSUndoableGroup *pHVar1;
  
  self_00 = self->_internalUndoManager;
  op = sel_removeAllActionsWithTarget_;
  pHVar1 = self;
  if (setCancelsEditingAfterLastUndoOperation != '\0') {
    self_00 = _objc_msgSend(self_00,sel_prepareWithInvocationTarget_,self);
    op = sel_undoLimitSentinel;
  }
  _objc_msgSend(self_00,op,pHVar1);
  self->_cancelsEditingAfterLastUndoOperation = setCancelsEditingAfterLastUndoOperation;
  return;
}

*/
- (void)setCancelsEditingAfterLastUndoOperation:(BOOL)aOperation
{
    if (aOperation) {
        [[_internalUndoManager prepareWithInvocationTarget:self] undoLimitSentinel];
    } else {
        [_internalUndoManager removeAllActionsWithTarget:self];
    }
    _cancelsEditingAfterLastUndoOperation = aOperation;
}

- (BOOL)cancelsEditingAfterLastUndoOperation
{
    return _cancelsEditingAfterLastUndoOperation;
}

- (void)setModelDelegate:(id)aDelegate
{
    if (_modelDelegate != aDelegate) {
        [_modelDelegate release];
        _modelDelegate = [aDelegate retain];
    }
}

- (id)modelDelegate
{
    return _modelDelegate;
}

- (BOOL)isOpened
{
    return _isClosed == NO;
}

- (void)setOuterUndoManager:(id)aManager
{
    _outerUndoManager = aManager;
}

- (id)outerUndoManager
{
    return _outerUndoManager;
}

- (void)setInternalUndoManager:(id)aManager
{
    if (_internalUndoManager != aManager) {
        [_internalUndoManager release];
        _internalUndoManager = [aManager retain];
    }
}

- (id)internalUndoManager
{
    return _internalUndoManager;
}

- (void)cancelChanges
{
    BOOL pvVar1;

    _isClosed = YES;
    pvVar1 = [_internalUndoManager isUndoing];
    if (!pvVar1) {
        while (pvVar1 = [_internalUndoManager canUndo], pvVar1) {
            [_internalUndoManager undo];
        }
    }
    [[self modelDelegate] setUndoManager:[self outerUndoManager]];
    [[self outerUndoManager] release];
    [self setModelDelegate:nil];
    if ([_internalUndoManager isUndoing]) {
        [[_internalUndoManager retain] autorelease];
    }
    [self setInternalUndoManager:nil];
}

- (void)acceptChanges
{
    [_internalUndoManager hyperRemoveAllRedoActions];
    _isClosed = YES;
    [self transferActionsToOuterUndoManager];
    [[self outerUndoManager] release];
    [self setModelDelegate:nil];
    [self setInternalUndoManager:nil];
}

- (void)start:(id)aStart
{
    id pvVar1_3;

    _isClosed = NO;
    [self setModelDelegate:aStart];
    [self setOuterUndoManager:[aStart undoManager]];
    [[self outerUndoManager] retain];
    pvVar1_3 = [NSUndoManager new];
    [self setInternalUndoManager:pvVar1_3];
    [pvVar1_3 release];
    [aStart setUndoManager:[self internalUndoManager]];
    [self setCancelsEditingAfterLastUndoOperation:YES];
}

- (void)dealloc
{
    if ([self isOpened]) {
        [_outerUndoManager release];
    }
    [_modelDelegate release];
    [_internalUndoManager release];
    [super dealloc];
}

- (id)init
{
    return nil;
}

- (id)initWithModelDelegate:(id)aDelegate
{
    self = [super init];
    if (self != nil) {
        _isClosed = 1;
        _cancelsEditingAfterLastUndoOperation = 1;
        [self start:aDelegate];
    }
    return self;
}

@end

