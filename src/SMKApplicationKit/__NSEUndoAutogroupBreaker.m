#import "__NSEUndoAutogroupBreaker.h"
#import <objc/runtime.h>
#import <libkern/OSAtomic.h>

// An auto-group is the undo group NSUndoManager opens per event. Ending it
// (NSE_endUndoAutogroup) only attaches a breaker: the next undo registration
// (or nested beginUndoGrouping) in that group closes it and opens a new one.
// An action name set with no group open is kept by a namer until a group
// opens, or dropped before the run loop's timers fire.

static int32_t breakerCount;    // live breakers
static int32_t namerCount;      // live namers

static IMP origBeginUndoGrouping;
static IMP origRegisterUndo;
static IMP origPrepareWithInvocationTarget;
static IMP origSetActionName;
static IMP origSetGroupsByEvent;
static IMP origSetRunLoopModes;

static void breakAutogroup(NSUndoManager *self, BOOL registering)
{
    void *key = [__NSEUndoAutogroupBreaker class];
    if (![self NSE_associatedObjectForKey:key])
        return;
    if (registering && ![self groupsByEvent])
        [NSException raise:NSInternalInconsistencyException
                    format:@"NSUndoManager %p is in invalid state: must begin a group before registering undo.", self];
    [self NSE_removeAssociatedObjectForKey:key];
    [self endUndoGrouping];
    [self beginUndoGrouping];
}

static void hookBeginUndoGrouping(NSUndoManager *self, SEL _cmd)
{
    if (breakerCount)
        breakAutogroup(self, NO);
    ((void (*)(id, SEL))origBeginUndoGrouping)(self, _cmd);
}

static void hookRegisterUndo(NSUndoManager *self, SEL _cmd, id target, SEL selector, id object)
{
    if (breakerCount)
        breakAutogroup(self, YES);
    ((void (*)(id, SEL, id, SEL, id))origRegisterUndo)(self, _cmd, target, selector, object);
}

static id hookPrepareWithInvocationTarget(NSUndoManager *self, SEL _cmd, id target)
{
    if (breakerCount)
        breakAutogroup(self, YES);
    return ((id (*)(id, SEL, id))origPrepareWithInvocationTarget)(self, _cmd, target);
}

static void hookSetActionName(NSUndoManager *self, SEL _cmd, NSString *name)
{
    if (namerCount)
        [self NSE_removeAssociatedObjectForKey:[__NSEUndoAutogroupNamer class]];
    ((void (*)(id, SEL, NSString *))origSetActionName)(self, _cmd, name);
}

static void hookSetGroupsByEvent(NSUndoManager *self, SEL _cmd, BOOL flag)
{
    ((void (*)(id, SEL, BOOL))origSetGroupsByEvent)(self, _cmd, flag);
    if (!flag && namerCount)
        [self NSE_removeAssociatedObjectForKey:[__NSEUndoAutogroupNamer class]];
}

static void hookSetRunLoopModes(NSUndoManager *self, SEL _cmd, NSArray *modes)
{
    __NSEUndoAutogroupNamer *namer = nil;
    NSArray *oldModes = nil;
    if (namerCount) {
        namer = [self NSE_associatedObjectForKey:[__NSEUndoAutogroupNamer class]];
        if (namer)
            oldModes = [[self runLoopModes] copy];
    }
    ((void (*)(id, SEL, NSArray *))origSetRunLoopModes)(self, _cmd, modes);
    [namer updateRunLoopModesFrom:oldModes];
    [oldModes release];
}

// Replaces three NSUndoManager methods once, keeping the originals.
static void hookUndoManager(dispatch_once_t *once, SEL sels[3], IMP hooks[3], IMP *origs[3])
{
    dispatch_once(once, ^{
        Class cls = [NSUndoManager class];
        for (int i = 0; i < 3; i++) {
            Method m = class_getInstanceMethod(cls, sels[i]);
            *origs[i] = class_getMethodImplementation(cls, sels[i]);
            class_replaceMethod(cls, sels[i], hooks[i], method_getTypeEncoding(m));
        }
    });
}

static void closeGroupingObserverCallout(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    [(NSUndoManager *)info NSE_removeAssociatedObjectForKey:[__NSEUndoAutogroupNamer class]];
}

@implementation __NSEUndoAutogroupBreaker

- (void)__NSEUndoAutogroupBreaker_undoMangerWillCloseUndoGroupNotification:(id)aNotification
{
    [_undoManager NSE_removeAssociatedObjectForKey:[__NSEUndoAutogroupBreaker class]];
}

- (void)dealloc
{
    OSAtomicAdd32(-1, &breakerCount);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUndoManagerWillCloseUndoGroupNotification object:_undoManager];
    [super dealloc];
}

- (id)initWithUndoManger:(id)aManger
{
    if ((self = [super init])) {
        _undoManager = aManger;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(__NSEUndoAutogroupBreaker_undoMangerWillCloseUndoGroupNotification:)
                                                     name:NSUndoManagerWillCloseUndoGroupNotification
                                                   object:_undoManager];
        OSAtomicAdd32(1, &breakerCount);
    }
    return self;
}

- (id)init
{
    [self release];
    return nil;
}

@end

@implementation __NSEUndoAutogroupNamer

- (void)__NSEUndoAutogroupNamer_undoMangerDidOpenUndoGroupNotification:(id)aNotification
{
    [self retain];
    if (_actionName)
        [_undoManager setActionName:_actionName];
    [_undoManager NSE_removeAssociatedObjectForKey:[__NSEUndoAutogroupNamer class]];
    [self release];
}

- (void)updateRunLoopModesFrom:(id)aFrom
{
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    if (_closeGroupingObserver)
        for (NSString *mode in aFrom)
            CFRunLoopRemoveObserver(runLoop, _closeGroupingObserver, (CFStringRef)mode);
    NSArray *modes = [_undoManager runLoopModes];
    if (![modes count])
        return;
    if (!_closeGroupingObserver) {
        _closeGroupingObserver = [self __NSEUndoAutogroupNamer_newCloseGroupingObserver];
        if (!_closeGroupingObserver)
            return;
    }
    for (NSString *mode in modes)
        CFRunLoopAddObserver(runLoop, _closeGroupingObserver, (CFStringRef)mode);
}

- (void)setActionName:(id)aName
{
    id name = [aName copy];
    [_actionName release];
    _actionName = name;
}

- (id)actionName
{
    return _actionName;
}

- (void)dealloc
{
    OSAtomicAdd32(-1, &namerCount);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUndoManagerDidOpenUndoGroupNotification object:_undoManager];
    if (_closeGroupingObserver) {
        CFRunLoopObserverInvalidate(_closeGroupingObserver);
        CFRelease(_closeGroupingObserver);
    }
    [_actionName release];
    [super dealloc];
}

- (id)initWithUndoManger:(id)aManger
{
    if (!(self = [super init]))
        return nil;
    _undoManager = aManger;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(__NSEUndoAutogroupNamer_undoMangerDidOpenUndoGroupNotification:)
                                                 name:NSUndoManagerDidOpenUndoGroupNotification
                                               object:_undoManager];
    NSArray *modes = [_undoManager runLoopModes];
    if ([modes count]) {
        _closeGroupingObserver = [self __NSEUndoAutogroupNamer_newCloseGroupingObserver];
        if (!_closeGroupingObserver) {
            [self release];
            return nil;
        }
        CFRunLoopRef runLoop = CFRunLoopGetCurrent();
        for (NSString *mode in modes)
            CFRunLoopAddObserver(runLoop, _closeGroupingObserver, (CFStringRef)mode);
    }
    OSAtomicAdd32(1, &namerCount);
    return self;
}

- (id)init
{
    [self release];
    return nil;
}

- (struct __CFRunLoopObserver *)__NSEUndoAutogroupNamer_newCloseGroupingObserver
{
    CFRunLoopObserverContext context = { 0, _undoManager, NULL, NULL, CFCopyDescription };
    return CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopBeforeTimers, false, 350000,
                                   closeGroupingObserverCallout, &context);
}

@end

@implementation NSUndoManager (NSEUndoManager)

- (void)NSE_endUndoAutogroup
{
    if (![self groupsByEvent])
        [NSException raise:NSInternalInconsistencyException
                    format:@"NSUndoManager %p is in invalid state: NSE_endUndoAutogroup is sent with grouping by event disabled.", self];
    NSInteger level = [self groupingLevel];
    if (level == 0)
        [NSException raise:NSInternalInconsistencyException
                    format:@"NSUndoManager %p is in invalid state: NSE_endUndoAutogroup is sent with no auto-group open.", self];
    else if (level != 1)
        [NSException raise:NSInternalInconsistencyException
                    format:@"NSUndoManager %p is in invalid state: NSE_endUndoAutogroup is sent with nested groups open.", self];
    __NSEUndoAutogroupBreaker *breaker = [[__NSEUndoAutogroupBreaker allocWithZone:[self zone]] initWithUndoManger:self];
    if (!breaker)
        return;
    static dispatch_once_t once;
    SEL sels[3] = { @selector(beginUndoGrouping), @selector(registerUndoWithTarget:selector:object:),
                    @selector(prepareWithInvocationTarget:) };
    IMP hooks[3] = { (IMP)hookBeginUndoGrouping, (IMP)hookRegisterUndo, (IMP)hookPrepareWithInvocationTarget };
    IMP *origs[3] = { &origBeginUndoGrouping, &origRegisterUndo, &origPrepareWithInvocationTarget };
    hookUndoManager(&once, sels, hooks, origs);
    [self NSE_setAssociatedObject:breaker forKey:[__NSEUndoAutogroupBreaker class] withPolicy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
    [breaker release];
}

- (void)NSE_setActionNameIfNeeded:(id)aNeeded
{
    NSInteger level = [self groupingLevel];
    // In an open group, unless it's an auto-group about to be broken.
    if (level != 0 && (level != 1 || !breakerCount
                       || ![self NSE_associatedObjectForKey:[__NSEUndoAutogroupBreaker class]])) {
        [self setActionName:aNeeded];
        return;
    }
    if (![self groupsByEvent])
        return;
    void *key = [__NSEUndoAutogroupNamer class];
    __NSEUndoAutogroupNamer *namer = [self NSE_associatedObjectForKey:key];
    if (namer) {
        [namer setActionName:aNeeded];
        return;
    }
    static dispatch_once_t once;
    SEL sels[3] = { @selector(setActionName:), @selector(setGroupsByEvent:), @selector(setRunLoopModes:) };
    IMP hooks[3] = { (IMP)hookSetActionName, (IMP)hookSetGroupsByEvent, (IMP)hookSetRunLoopModes };
    IMP *origs[3] = { &origSetActionName, &origSetGroupsByEvent, &origSetRunLoopModes };
    hookUndoManager(&once, sels, hooks, origs);
    namer = [[__NSEUndoAutogroupNamer allocWithZone:[self zone]] initWithUndoManger:self];
    if (!namer)
        return;
    [self NSE_setAssociatedObject:namer forKey:key withPolicy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
    [namer setActionName:aNeeded];
    [namer release];
}

- (id)NSE_pendingActionName
{
    if (!namerCount)
        return nil;
    return [[self NSE_associatedObjectForKey:[__NSEUndoAutogroupNamer class]] actionName];
}

@end

#pragma mark Captured functions

static IMP *const capturedSlots[] = { &origBeginUndoGrouping, &origRegisterUndo, &origPrepareWithInvocationTarget,
                                      &origSetActionName, &origSetGroupsByEvent, &origSetRunLoopModes };
static const IMP capturingHooks[] = { (IMP)hookBeginUndoGrouping, (IMP)hookRegisterUndo,
                                      (IMP)hookPrepareWithInvocationTarget, (IMP)hookSetActionName,
                                      (IMP)hookSetGroupsByEvent, (IMP)hookSetRunLoopModes };

void NSERecaptureFunction(void *function, void *newFunction)
{
    for (size_t i = 0; i < sizeof capturedSlots / sizeof *capturedSlots; i++)
        OSAtomicCompareAndSwapPtrBarrier(function, newFunction, (void *volatile *)capturedSlots[i]);
}

CFDictionaryRef NSECopyCapturedFunctions(void)
{
    const void *keys[6], *values[6];
    CFIndex count = 0;
    for (size_t i = 0; i < 6; i++)
        if (*capturedSlots[i]) {
            keys[count] = *capturedSlots[i];
            values[count++] = capturingHooks[i];
        }
    return CFDictionaryCreate(kCFAllocatorDefault, keys, values, count, &kCFEAlignedPointerDictionaryKeyCallBacks, NULL);
}
