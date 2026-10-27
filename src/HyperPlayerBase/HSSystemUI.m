#import "HSSystemUI.h"
// The shared controller of the system UI mode (menu bar and Dock hiding): it
// remembers the mode it replaced and restores it.
@implementation HSSystemUI
static HSSystemUI *sSharedSystemUI;
// A singleton: allocation after the first returns nil.
+ (id)allocWithZone:(NSZone *)aZone
{
    @synchronized(self) {
        if (sSharedSystemUI == nil) {
            sSharedSystemUI = [super allocWithZone:aZone];
            return sSharedSystemUI;
        }
    }
    return nil;
}
+ (id)sharedSystemUI
{
    @synchronized(self) {
        if (sSharedSystemUI == nil)
            [[self alloc] init];
    }
    return sSharedSystemUI;
}
- (BOOL)menuBarVisible
{
    SystemUIMode mode = 0;
    SystemUIOptions options = 0;
    GetSystemUIMode(&mode, &options);
    return mode == kUIModeNormal && options == 0;
}
- (void)revertChanges
{
    if (_isUIModeSet && SetSystemUIMode(_oldUIMode, _oldUIOptions) == noErr) {
        _isUIModeSet = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSSystemUIModeDidChangeNotificationName" object:self];
    }
}
// Remembers the current mode only when changing it.
- (void)setupWithMode:(NSUInteger)aMode options:(NSUInteger)aOptions
{
    SystemUIMode mode = 0;
    SystemUIOptions options = 0;
    GetSystemUIMode(&mode, &options);
    _oldUIMode = mode;
    _oldUIOptions = (unsigned int)options;
    if (_oldUIMode == aMode && _oldUIOptions == aOptions)
        return;
    if (SetSystemUIMode((SystemUIMode)aMode, (SystemUIOptions)aOptions) == noErr) {
        _isUIModeSet = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSSystemUIModeDidChangeNotificationName" object:self];
    } else {
        _isUIModeSet = NO;
    }
}
- (void)dealloc
{
    if (_isUIModeSet)
        SetSystemUIMode(_oldUIMode, _oldUIOptions);
    [super dealloc];
}
- (id)autorelease
{
    return self;
}
- (void)release
{
}
- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}
- (id)retain
{
    return self;
}
- (id)copyWithZone:(NSZone *)aZone
{
    return self;
}
@end
