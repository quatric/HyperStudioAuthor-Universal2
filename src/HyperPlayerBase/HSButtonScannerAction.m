#import "HSButtonScannerAction.h"
#import "HSActionExecutionContext.h"

// Switch scanning: highlights the usable buttons of the card one after the
// other (from the last to the first) every scanDelay seconds; the switch key
// (0-3, space, Return or Enter) or a click runs the highlighted button's
// actions, Escape stops. A scan cycle count of 0 scans forever.
@implementation HSButtonScannerAction

- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return ![aType isEqualToString:@"HSiBooksAuthorDocumentType"];
}

- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    if (![self isValid])
        return nil;
    id dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
    [dictionary setObject:[NSString stringWithFormat:@"%.1f", (double)[self scanDelay]] forKey:@"scanDelay"];
    [dictionary setObject:[NSString stringWithFormat:@"%.1f", (double)[self resetDelay]] forKey:@"resetDelay"];
    [dictionary setObject:[NSString stringWithFormat:@"%i", (int)[self scanCyclesCount]] forKey:@"scanCyclesCount"];
    [dictionary setObject:[self hidesCursor] ? @"1" : @"0" forKey:@"hidesCursor"];
    return dictionary;
}

- (id)XMLElementRepresentationInContext:(id)aContext
{
    id element = [super XMLElementRepresentationInContext:aContext];
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    [element addAttribute:[NSXMLNode attributeWithName:@"scanDelay" stringValue:[NSString stringWithFormat:@"%.2f", (double)_scanDelay]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"resetDelay" stringValue:[NSString stringWithFormat:@"%.2f", (double)_resetDelay]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"scanCyclesCount" stringValue:[NSString stringWithFormat:@"%u", _scanCyclesCount]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"hidesCursor" stringValue:_hidesCursor ? HSXMLStoring1String : HSXMLStoring0String]];
    [pool release];
    return element;
}

- (id)XMLElementName
{
    return @"actButtonScanner";
}

- (BOOL)supportedInIPad
{
    return YES;
}

- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}

- (void)actionsForObject:(id)aObject didFinishForEvent:(id)aEvent inActionExecutionManager:(id)aManager
{
    [self stop:self];
}

- (BOOL)handleMouseDownEvent:(id)aEvent
{
    BOOL idle = !_isChildActionRunning;
    if (idle)
        [self runActionsForActiveObject];
    return idle;
}

- (BOOL)handleKeyUpEvent:(id)aEvent
{
    if (_isChildActionRunning)
        return NO;
    if ((short)[(NSEvent *)aEvent keyCode] == 0x35) {     // Escape
        [self stop:self];
        return NO;
    }
    if ([self isButtonScannerEvent:aEvent])
        [self runActionsForActiveObject];
    return YES;
}

- (BOOL)handleKeyDownEvent:(id)aEvent
{
    // Holding the switch down pauses the scan.
    if ([self isButtonScannerEvent:aEvent])
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(moveToNextButton) object:nil];
    return YES;
}

- (BOOL)isButtonScannerEvent:(id)aEvent
{
    static NSCharacterSet *sScannerCharacters = nil;
    if ([self activeObject] == nil)
        return NO;
    unsigned short keyCode = [(NSEvent *)aEvent keyCode];
    if (keyCode == 0x24 || keyCode == 0x4c)     // Return, Enter
        return YES;
    if (sScannerCharacters == nil)
        sScannerCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"0123 "] retain];
    NSString *characters = [aEvent charactersIgnoringModifiers];
    if (characters != nil && [characters length])
        return [characters rangeOfCharacterFromSet:sScannerCharacters].location != NSNotFound;
    return NO;
}

- (void)stop:(id)aStop
{
    [_context unregisterEventResponderAction:self];
    [_context stopAllActionsForRequestor:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(moveToNextButton) object:nil];
    if (_hidesCursor)
        [_context showCursor];
    [self setCurentButtonIndex:NSNotFound];
    [_context setButtonScannerAction:nil];
    [_context release];
    _context = nil;
    [super stop:aStop];
}

- (BOOL)canBeStopped
{
    return YES;
}

- (void)startInContext:(id)aContext
{
    _context = [aContext retain];
    _curentButtonIndex = NSNotFound;
    if (_hidesCursor)
        [_context hideCursor];
    [_context setButtonScannerAction:self];
    [_context registerEventResponderAction:self];
    [self performSelector:@selector(moveToNextButton) withObject:nil afterDelay:[self resetDelay]];
}

- (void)runActionsForActiveObject
{
    _isChildActionRunning = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(moveToNextButton) object:nil];
    [_context showCursor];
    [_context runActionsForObject:[self activeObject] forRequestor:self];
}

- (id)activeObject
{
    return [[self availableButtons] extraObjectAtIndex:[self currentButtonIndex]];
}

- (void)moveToNextButton
{
    // Steps backwards; from NSNotFound (start) or past the first button it
    // wraps to the last one, which completes a cycle.
    NSUInteger index = [self currentButtonIndex] - 1;
    if (index >= [[self availableButtons] count]) {
        _cyclesDoneCount++;
        if ([self scanCyclesCount] != 0 && _cyclesDoneCount > [self scanCyclesCount]) {
            [self stop:self];
            return;
        }
        index = [[self availableButtons] count] - 1;
    }
    [self setCurentButtonIndex:index];
    [self performSelector:@selector(moveToNextButton) withObject:nil afterDelay:[self scanDelay]];
}

- (void)setCurentButtonIndex:(NSUInteger)aIndex
{
    _curentButtonIndex = aIndex;
    [self highlightObject:[self activeObject]];
}

- (NSUInteger)currentButtonIndex
{
    return _curentButtonIndex;
}

- (void)containerAttributeDidChange:(id)aChange
{
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}

- (void)setCurrentStack:(id)aStack
{
    if (_currentStack == aStack)
        return;
    [[_currentStack queryHyperInterface:@protocol(HSNodeContainer)] removeObserver:self selector:@selector(containerAttributeDidChange:) ofChanges:2 ofChildrenAttribute:@protocol(HSNodeContainerChildrenAttribute)];
    [_currentStack release];
    _currentStack = [aStack retain];
    [[_currentStack queryHyperInterface:@protocol(HSNodeContainer)] addObserver:self selector:@selector(containerAttributeDidChange:) ofChanges:2 ofChildrenAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.25f];
}

- (id)availableButtons
{
    if (_availableObjects == nil) {
        NSMutableArray *objects = [NSMutableArray new];
        NSEnumerator *enumerator = [[[self card] queryHyperInterface:@protocol(HSNodeAttributes)] hyperDeepEnumerator];
        id object;
        while ((object = [enumerator nextObject]) != nil) {
            if ([self canUseObject:object])
                [objects addObject:object];
        }
        _availableObjects = [[NSArray alloc] initWithArray:objects];
        [objects release];
    }
    return _availableObjects;
}

- (BOOL)canUseObject:(id)aObject
{
    id attributes = [aObject queryHyperInterface:@protocol(HSCardObjectAttributes)];
    if (![aObject implementsHyperInterface:@protocol(HSSystemButtonInteractiveModeAttributes)])
        return NO;
    if ([attributes isLocked])
        return NO;
    return ![attributes isHidden];
}

- (BOOL)isValid
{
    NSEnumerator *enumerator = [[[self card] queryHyperInterface:@protocol(HSNodeAttributes)] hyperDeepEnumerator];
    id object;
    while ((object = [enumerator nextObject]) != nil) {
        if ([self canUseObject:object])
            return YES;
    }
    return NO;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:
            [NSArray arrayWithObjects:@"scanDelay", @"resetDelay", @"scanCyclesCount", @"hidesCursor", nil]];
}

- (void)setHidesCursor:(BOOL)aCursor
{
    if (_hidesCursor == aCursor)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"HSButtonScannerHideCursorChange" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHidesCursor:[self hidesCursor]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSButtonScannerHidesCursorAttribute) ofObject:self withUserInfo:nil];
    _hidesCursor = aCursor;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSButtonScannerHidesCursorAttribute) ofObject:self withUserInfo:nil];
}

- (BOOL)hidesCursor
{
    return _hidesCursor;
}

- (void)setScanCyclesCount:(NSUInteger)aCount
{
    if (_scanCyclesCount == aCount)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"HSButtonScannerSetScanCyclesCount" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setScanCyclesCount:[self scanCyclesCount]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSButtonScannerScanCyclesAttribute) ofObject:self withUserInfo:nil];
    _scanCyclesCount = (unsigned int)aCount;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSButtonScannerScanCyclesAttribute) ofObject:self withUserInfo:nil];
}

- (NSUInteger)scanCyclesCount
{
    return _scanCyclesCount;
}

- (void)setResetDelay:(CGFloat)aDelay
{
    if (_resetDelay == (float)aDelay)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"HSButtonScannerSetResetDelay" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setResetDelay:[self resetDelay]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSButtonScannerResetDelayAttribute) ofObject:self withUserInfo:nil];
    _resetDelay = (float)aDelay;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSButtonScannerResetDelayAttribute) ofObject:self withUserInfo:nil];
}

- (CGFloat)resetDelay
{
    return _resetDelay;
}

- (void)setScanDelay:(CGFloat)aDelay
{
    if (_scanDelay == (float)aDelay)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"HSButtonScannerSetScanDelay" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setScanDelay:[self scanDelay]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSButtonScannerScanDelayAttribute) ofObject:self withUserInfo:nil];
    _scanDelay = (float)aDelay;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSButtonScannerScanDelayAttribute) ofObject:self withUserInfo:nil];
}

- (CGFloat)scanDelay
{
    return _scanDelay;
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(moveToNextButton) object:nil];
    [self setCurrentStack:nil];
    [_availableObjects release];
    [_context release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _resetDelay = 0.25f;
        _scanDelay = 1.0f;
        _hidesCursor = YES;
    }
    return self;
}

@end
