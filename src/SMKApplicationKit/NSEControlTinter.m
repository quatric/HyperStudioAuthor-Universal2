#import "NSEControlTinter.h"

@interface NSObject (NSEControlTinterDelegate)
- (id)controlTinter:(NSEControlTinter *)tinter willSetValue:(id)value forKey:(NSString *)key forTint:(NSControlTint)tint inControl:(id)control;
@end

typedef struct {
    id control;
    NSEControlTinter *tinter;
    NSUInteger tint;
    id delegate;
} ApplyContext;

// Sets one key of the control to its value for the tint (as the delegate
// would have it).
static void applyKey(const void *key, const void *tintMap, void *context)
{
    ApplyContext *c = context;
    id value = tintMap == kCFNull ? nil : (id)CFDictionaryGetValue(tintMap, (const void *)c->tint);
    if (c->delegate)
        value = [c->delegate controlTinter:c->tinter willSetValue:value forKey:(NSString *)key forTint:c->tint inControl:c->control];
    [c->control setValue:value forKey:(NSString *)key];
}

// Values of a control's keys for each control tint (graphite, blue…), set
// when the control's tint (or the system's, for the default tint) changes.
// The key to tint map is key -> (kCFNull or tint -> value).
@implementation NSEControlTinter

// The keys, then the controls, each list ending with nil.
+ (id)setTinterWithDelegate:(id)aDelegate forKeysAndControls:(id)aKey, ...
{
    NSEControlTinter *tinter = [[[NSEControlTinter alloc] init] autorelease];
    if (!tinter)
        return nil;
    [tinter setDelegate:aDelegate];
    va_list list;
    va_start(list, aKey);
    for (id key = aKey; key; key = va_arg(list, id))
        [tinter addKey:key];
    for (id control = va_arg(list, id); control; control = va_arg(list, id))
        [NSEControlTinter setTinter:tinter forControl:control];
    va_end(list);
    return tinter;
}

+ (void)tintControl:(id)aControl
{
    __NSEControlTinterLink *link = [aControl NSE_associatedObjectForKey:[__NSEControlTinterLink class]];
    if (link)
        [[link tinter] NSEControlTinter_applyTint:[link currentTint] toControl:aControl];
}

+ (void)removeTinterForControl:(id)aControl
{
    [aControl NSE_removeAssociatedObjectForKey:[__NSEControlTinterLink class]];
}

// The link watches the control's controlTint by key-value observing (before
// 10.6, setControlTint: was replaced instead).
+ (void)setTinter:(id)aTinter forControl:(id)aControl
{
    __NSEControlTinterLink *link = [[__NSEControlTinterLink alloc] initWithControl:aControl tinter:aTinter];
    if (link) {
        [aControl NSE_setAssociatedObject:link forKey:[__NSEControlTinterLink class] withPolicy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
        [link release];
    }
}

+ (id)tinterForControl:(id)aControl
{
    return [[aControl NSE_associatedObjectForKey:[__NSEControlTinterLink class]] tinter];
}

- (void)NSEControlTinter_applyTint:(NSUInteger)aTint toControl:(id)aControl
{
    if (!_keyToTintMap || !CFDictionaryGetCount(_keyToTintMap))
        return;
    ApplyContext context = { aControl, self, aTint, nil };
    if ([_delegate respondsToSelector:@selector(controlTinter:willSetValue:forKey:forTint:inControl:)])
        context.delegate = _delegate;
    CFDictionaryApplyFunction(_keyToTintMap, applyKey, &context);
}

- (void)removeKey:(id)aKey
{
    if (_keyToTintMap)
        CFDictionaryRemoveValue(_keyToTintMap, aKey);
}

- (void)addKey:(id)aKey
{
    if (!_keyToTintMap && !(_keyToTintMap = [self NSEControlTinter_createKeyToTintMap]))
        return;
    CFDictionaryAddValue(_keyToTintMap, aKey, kCFNull);
}

- (void)setValue:(id)aValue forKey:(id)aKey forTint:(NSUInteger)aTint
{
    CFMutableDictionaryRef tintMap;
    if (!_keyToTintMap) {
        if (!(_keyToTintMap = [self NSEControlTinter_createKeyToTintMap]))
            return;
        tintMap = NULL;
    }
    else
        tintMap = (CFMutableDictionaryRef)CFDictionaryGetValue(_keyToTintMap, aKey);
    if (!aValue) {
        if ((CFTypeRef)tintMap == kCFNull)
            return;
        if (tintMap)
            CFDictionaryRemoveValue(tintMap, (const void *)aTint);
        else
            CFDictionarySetValue(_keyToTintMap, aKey, kCFNull);
        return;
    }
    if (!tintMap || (CFTypeRef)tintMap == kCFNull) {
        tintMap = CFDictionaryCreateMutable(NULL, 0, &kCFEUnsignedIntegerDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        if (!tintMap)
            return;
        CFDictionarySetValue(_keyToTintMap, aKey, tintMap);
        CFRelease(tintMap);
    }
    CFDictionarySetValue(tintMap, (const void *)aTint, aValue);
}

- (struct __CFDictionary *)NSEControlTinter_createKeyToTintMap
{
    return CFDictionaryCreateMutable(NULL, 0, &kCFCopyStringDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
}

- (id)valueForKey:(id)aKey forTint:(NSUInteger)aTint
{
    if (!_keyToTintMap)
        return nil;
    CFDictionaryRef tintMap = CFDictionaryGetValue(_keyToTintMap, aKey);
    if (!tintMap || (CFTypeRef)tintMap == kCFNull)
        return nil;
    return (id)CFDictionaryGetValue(tintMap, (const void *)aTint);
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void)dealloc
{
    if (_keyToTintMap)
        CFRelease(_keyToTintMap);
    [super dealloc];
}

@end

// A control's tinter (as its associated object), following its tint.
@implementation __NSEControlTinterLink

- (void)__NSEControlTinterLink_defaultControlTintDidChange:(id)aChange
{
    NSControlTint tint = [NSColor currentControlTint];
    if (tint != _currentTint) {
        _currentTint = (unsigned int)tint;
        [_tinter NSEControlTinter_applyTint:tint toControl:_control];
    }
}

- (void)observeValueForKeyPath:(id)aPath ofObject:(id)aObject change:(id)aChange context:(void *)aContext
{
    if (aObject == _control && [aPath isEqualToString:@"controlTint"])
        [self __NSEControlTinterLink_tintDidChange];
}

- (void)endTintChange
{
    _tintChangeCounter--;
    if (!_tintChangeCounter)
        [self __NSEControlTinterLink_tintDidChange];
}

- (void)beginTintChange
{
    _tintChangeCounter++;
}

// The control's own tint, else the system's (watched while it's used).
- (void)__NSEControlTinterLink_tintDidChange
{
    NSControlTint tint = [_control controlTint];
    if (tint == NSDefaultControlTint) {
        tint = [NSColor currentControlTint];
        if (!_isDefaultTint) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__NSEControlTinterLink_defaultControlTintDidChange:)
                                                         name:NSControlTintDidChangeNotification object:NSApp];
            _isDefaultTint = 1;
        }
    }
    else if (_isDefaultTint) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSControlTintDidChangeNotification object:NSApp];
        _isDefaultTint = 0;
    }
    if (tint != _currentTint) {
        _currentTint = (unsigned int)tint;
        [_tinter NSEControlTinter_applyTint:tint toControl:_control];
    }
}

- (NSUInteger)currentTint
{
    return _currentTint;
}

- (id)tinter
{
    return _tinter;
}

- (void)dealloc
{
    [_control removeObserver:self forKeyPath:@"controlTint"];
    if (_isDefaultTint)
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSControlTintDidChangeNotification object:NSApp];
    [_tinter release];
    [super dealloc];
}

- (id)initWithControl:(id)aControl tinter:(id)aTinter
{
    if (!(self = [super init]))
        return nil;
    _control = aControl;
    _tinter = [aTinter retain];
    [_control addObserver:self forKeyPath:@"controlTint" options:0 context:NULL];
    _currentTint = (unsigned int)[_control controlTint];
    if (_currentTint == NSDefaultControlTint) {
        _currentTint = (unsigned int)[NSColor currentControlTint];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__NSEControlTinterLink_defaultControlTintDidChange:)
                                                     name:NSControlTintDidChangeNotification object:NSApp];
        _isDefaultTint = 1;
    }
    [_tinter NSEControlTinter_applyTint:_currentTint toControl:_control];
    return self;
}

- (id)init
{
    [self release];
    return nil;
}

@end
