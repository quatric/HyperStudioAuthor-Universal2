#import "NSEWindow.h"

// A shaped window's shadow: a plain window of the same frame behind it (its
// child), titled when the window has title bar buttons.
static NSUInteger shadowStyleMask(NSUInteger mask)
{
    return (mask & ~(NSUInteger)0xe) | ((mask & 0xe) ? NSWindowStyleMaskTitled : 0);
}

@implementation NSEWindow

- (void)setHasOpaqueShapeShadow:(BOOL)aShadow
{
    if (!aShadow) {
        if (_shadowChild) {
            [_shadowChild orderWindow:NSWindowOut relativeTo:0];
            [self removeChildWindow:_shadowChild];
            [_shadowChild release];
            _shadowChild = nil;
        }
        return;
    }
    if (_shadowChild)
        return;
    NSUInteger mask = shadowStyleMask([self styleMask]);
    NSRect content = [[self class] contentRectForFrameRect:[self frame] styleMask:mask];
    _shadowChild = [[__NSEWindowShadowChild alloc] initWithContentRect:content styleMask:mask
                                                               backing:NSBackingStoreBuffered defer:NO screen:[self screen]];
    if (!_shadowChild)
        return;
    [_shadowChild setReleasedWhenClosed:NO];
    [_shadowChild disableCursorRects];
    [_shadowChild setIgnoresMouseEvents:YES];
    [self addChildWindow:_shadowChild ordered:NSWindowBelow];
    if ([self isVisible])
        [_shadowChild orderWindow:NSWindowBelow relativeTo:[self windowNumber]];
}

- (BOOL)hasOpaqueShapeShadow
{
    return _shadowChild != nil;
}

// Out of its parent, the window is the shadow's parent again.
- (void)setParentWindow:(id)aWindow
{
    [super setParentWindow:aWindow];
    if (_shadowChild && !aWindow) {
        [self removeChildWindow:_shadowChild];
        [self addChildWindow:_shadowChild ordered:NSWindowBelow];
        if ([self isVisible])
            [_shadowChild orderWindow:NSWindowBelow relativeTo:[self windowNumber]];
    }
}

- (void)becomeKeyWindow
{
    [super becomeKeyWindow];
    if (_shadowChild && ![_shadowChild isVisible])
        [_shadowChild orderWindow:NSWindowBelow relativeTo:[self windowNumber]];
}

- (void)orderFrontRegardless
{
    [super orderFrontRegardless];
    if (_shadowChild)
        [_shadowChild orderWindow:NSWindowBelow relativeTo:[self windowNumber]];
}

- (void)orderWindow:(NSInteger)aWindow relativeTo:(NSInteger)aTo
{
    if (aWindow == NSWindowBelow || aWindow == NSWindowAbove) {
        [super orderWindow:aWindow relativeTo:aTo];
        if (_shadowChild)
            [_shadowChild orderWindow:NSWindowBelow relativeTo:[self windowNumber]];
    }
    else if (aWindow == NSWindowOut) {
        [_shadowChild orderWindow:NSWindowOut relativeTo:0];
        [super orderWindow:NSWindowOut relativeTo:aTo];
    }
    else
        [super orderWindow:aWindow relativeTo:aTo];
}

- (void)setFrame:(NSRect)aFrame display:(BOOL)aDisplay
{
    if (!_shadowChild) {
        [super setFrame:aFrame display:aDisplay];
        return;
    }
    if (aDisplay)
        [self disableScreenUpdatesUntilFlush];
    [super setFrame:aFrame display:NO];
    [_shadowChild setFrame:[self frame] display:aDisplay];
    if (aDisplay)
        [self display];
}

- (void)setStyleMask:(NSUInteger)aMask
{
    [_shadowChild setStyleMask:shadowStyleMask(aMask)];
    [super setStyleMask:aMask];
}

- (void)dealloc
{
    [_shadowChild release];
    [super dealloc];
}

@end

@implementation __NSEWindowShadowChild

// It stays where its parent is.
- (NSRect)constrainFrameRect:(NSRect)aRect toScreen:(id)aScreen
{
    return [[self parentWindow] frame];
}

- (void)sendEvent:(id)aEvent
{
}

@end

@implementation NSWindow (NSEWindowPartial)

// What the window shows in the rectangle (window coordinates), drawn again
// from its views (screen grabs need permission now). The caller releases it.
- (struct CGImage *)NSE_copyImageFromRect:(NSRect)aRect
{
    if (NSIsEmptyRect(aRect))
        return NULL;
    NSView *view = [[self contentView] superview];
    if (!view)
        view = [self contentView];
    if (!view)
        return NULL;
    NSRect rect = NSIntegralRect([view convertRect:aRect fromView:nil]);
    NSBitmapImageRep *rep = [view bitmapImageRepForCachingDisplayInRect:rect];
    if (!rep)
        return NULL;
    [view cacheDisplayInRect:rect toBitmapImageRep:rep];
    return CGImageRetain([rep CGImage]);
}

- (struct OpaqueCMProfileRef *)NSE_displayColorSyncProfile
{
    struct OpaqueCMProfileRef *profile = NULL;
    [self NSEWindow_getDisplayColorSpace:NULL CGColorSpace:NULL colorSyncProfile:&profile];
    return profile;
}

- (struct CGColorSpace *)NSE_displayCGColorSpace
{
    struct CGColorSpace *space = NULL;
    [self NSEWindow_getDisplayColorSpace:NULL CGColorSpace:&space colorSyncProfile:NULL];
    return space;
}

- (id)NSE_displayColorSpace
{
    id space = nil;
    [self NSEWindow_getDisplayColorSpace:&space CGColorSpace:NULL colorSyncProfile:NULL];
    return space;
}

// The color space of the window, else of its screen, else of the main
// display. The profile is a ColorSyncProfileRef now (CMProfileRef is gone).
- (void)NSEWindow_getDisplayColorSpace:(id *)aSpace CGColorSpace:(struct CGColorSpace **)aSpace2 colorSyncProfile:(struct OpaqueCMProfileRef **)aProfile
{
    NSColorSpace *space = [self colorSpace];
    if (!space && [self screen] && !(space = [[self screen] colorSpace]))
        return;
    if (space) {
        if (aSpace)
            *aSpace = space;
        if (aSpace2)
            *aSpace2 = [space CGColorSpace];
        if (aProfile)
            *aProfile = (struct OpaqueCMProfileRef *)[space colorSyncProfile];
        return;
    }
    ColorSyncProfileRef profile = ColorSyncProfileCreateWithDisplayID(CGMainDisplayID());
    if (!profile)
        return;
    if (aSpace)
        *aSpace = [[[NSColorSpace alloc] initWithColorSyncProfile:profile] autorelease];
    if (aSpace2) {
        CGColorSpaceRef cgSpace = CGColorSpaceCreateWithPlatformColorSpace(profile);
        *aSpace2 = cgSpace ? (struct CGColorSpace *)CFAutorelease(cgSpace) : NULL;
    }
    if (aProfile)
        *aProfile = (struct OpaqueCMProfileRef *)CFAutorelease(profile);
    else
        CFRelease(profile);
}

// The space's profile, else one made from its ICC data (or the CG space's;
// (CGColorSpaceRef)-1 means the space's own). Autoreleased.
- (struct OpaqueCMProfileRef *)NSEWindow_colorSyncProfileForColorSpace:(id)aSpace withCGColorSpace:(struct CGColorSpace *)aSpace2
{
    void *profile = [aSpace colorSyncProfile];
    if (profile)
        return profile;
    NSData *data = [[aSpace ICCProfileData] retain];
    if (!data) {
        if (aSpace2 == (struct CGColorSpace *)-1)
            aSpace2 = [aSpace CGColorSpace];
        if (!aSpace2 || !(data = (NSData *)CGColorSpaceCopyICCData(aSpace2)))
            return NULL;
    }
    ColorSyncProfileRef made = ColorSyncProfileCreate((CFDataRef)data, NULL);
    [data release];
    return made ? (struct OpaqueCMProfileRef *)CFAutorelease(made) : NULL;
}

@end

@implementation NSWindow (NSEWindowLoading)

// Added convertRect{To,From}{Screen,Backing}: before 10.7.
+ (void)load
{
}

@end
