#import "HSAbstractSelectionSync.h"

@implementation HSAbstractSelectionSync

+ (BOOL)isEnabledByDefault
{
    return YES;
}

- (void)notifySelectionDidChange
{
}

- (BOOL)isRegisteredSelectionHost:(id)aHost
{
    return NO;
}

- (void)setEnabled:(BOOL)aEnabled
{
    if ((aEnabled != NO) != _isEnabled) {
        _isEnabled = aEnabled != NO;
        [self refreshCurrentlySelectedObjectAndNotify:NO];
    }
}

- (BOOL)isEnabled
{
    return _isEnabled;
}

- (void)setCurrentSelectionHost:(id)aHost
{
    [self setCurrentSelectionHost:aHost andNotify:NO];
}

// Original quirk kept: a new host refreshes without the extra notification; only re-setting the same host honors aNotify.
- (void)setCurrentSelectionHost:(id)aHost andNotify:(BOOL)aNotify
{
    if (_currentSelectionHost != aHost) {
        [_currentSelectionHost release];
        _currentSelectionHost = [aHost retain];
        [self refreshCurrentlySelectedObjectAndNotify:NO];
    }
    else if (aNotify) {
        [self refreshCurrentlySelectedObjectAndNotify:YES];
    }
}

- (id)currentSelectionHost
{
    return _currentSelectionHost;
}

- (void)refreshCurrentlySelectedObjectAndNotify:(BOOL)aNotify
{
    [self setCurrentSelectedObject:[self currentlySelectedObjectInActiveSelectionHost]];
    if (aNotify)
        [self notifySelectionDidChange];
}

- (id)currentlySelectedObjectInActiveSelectionHost
{
    if (!_isEnabled)
        return nil;
    return [_currentSelectionHost ownSelectedObject];
}

- (void)setCurrentSelectedObject:(id)aObject
{
    if (_currentSelectedObject != aObject) {
        [_currentSelectedObject release];
        _currentSelectedObject = [aObject retain];
        [self notifySelectionDidChange];
    }
}

- (id)currentSelectedObject
{
    return [[_currentSelectedObject retain] autorelease];
}

- (id)init
{
    self = [super init];
    if (self != nil)
        _isEnabled = [[self class] isEnabledByDefault];
    return self;
}

- (void)dealloc
{
    [_currentSelectedObject release];
    [_currentSelectionHost release];
    [super dealloc];
}

@end
