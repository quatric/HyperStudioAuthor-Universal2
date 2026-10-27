#import "HSAutoOriginedPanel.h"
// Frames read from the preferences are moved back onto the main screen.
@implementation HSAutoOriginedPanel
- (void)setFrame:(NSRect)aFrame display:(BOOL)aDisplay
{
    if (_readingFrameFromPrefereces)
        aFrame = [HSAutoOriginedWindow onscreenFrameUsingFrame:aFrame];
    [super setFrame:aFrame display:aDisplay];
}
- (BOOL)setFrameUsingName:(id)aName
{
    _readingFrameFromPrefereces = YES;
    BOOL result = [super setFrameUsingName:aName];
    _readingFrameFromPrefereces = NO;
    return result;
}
- (void)setFrameFromString:(id)aString
{
    _readingFrameFromPrefereces = YES;
    [super setFrameFromString:aString];
    _readingFrameFromPrefereces = NO;
}
@end
@implementation HSAutoOriginedWindow
// A frame not inside the main screen is moved 20 points inside its edges.
// Original quirk kept: the right/top correction ignores the screen origin.
+ (NSRect)onscreenFrameUsingFrame:(NSRect)aFrame
{
    NSRect screen = [[NSScreen mainScreen] frame];
    if (NSContainsRect(screen, aFrame))
        return aFrame;
    if (aFrame.origin.x < screen.origin.x)
        aFrame.origin.x = screen.origin.x + 20.0;
    if (aFrame.origin.y < screen.origin.y)
        aFrame.origin.y = screen.origin.y + 20.0;
    if (screen.origin.x + screen.size.width < aFrame.origin.x + aFrame.size.width)
        aFrame.origin.x = (screen.size.width - aFrame.size.width) - 20.0;
    if (screen.origin.y + screen.size.height < aFrame.origin.y + aFrame.size.height)
        aFrame.origin.y = (screen.size.height - aFrame.size.height) - 20.0;
    return aFrame;
}
- (void)setFrame:(NSRect)aFrame display:(BOOL)aDisplay
{
    if (_readingFrameFromPrefereces)
        aFrame = [HSAutoOriginedWindow onscreenFrameUsingFrame:aFrame];
    [super setFrame:aFrame display:aDisplay];
}
- (BOOL)setFrameUsingName:(id)aName
{
    _readingFrameFromPrefereces = YES;
    BOOL result = [super setFrameUsingName:aName];
    _readingFrameFromPrefereces = NO;
    return result;
}
- (void)setFrameFromString:(id)aString
{
    _readingFrameFromPrefereces = YES;
    [super setFrameFromString:aString];
    _readingFrameFromPrefereces = NO;
}
@end
