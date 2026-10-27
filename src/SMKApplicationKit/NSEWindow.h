#import "SMKApplicationKitPrefix.h"


@interface NSEWindow : NSWindow
{
    NSWindow *_shadowChild;
}
- (void)setHasOpaqueShapeShadow:(BOOL)aShadow;
- (BOOL)hasOpaqueShapeShadow;
- (void)setParentWindow:(id)aWindow;
- (void)becomeKeyWindow;
- (void)orderFrontRegardless;
- (void)orderWindow:(NSInteger)aWindow relativeTo:(NSInteger)aTo;
- (void)setFrame:(NSRect)aFrame display:(BOOL)aDisplay;
- (void)setStyleMask:(NSUInteger)aMask;
- (void)dealloc;
@end

@interface __NSEWindowShadowChild : NSWindow
{
}
- (NSRect)constrainFrameRect:(NSRect)aRect toScreen:(id)aScreen;
- (void)sendEvent:(id)aEvent;
@end

@interface NSWindow (NSEWindowPartial)
- (struct CGImage *)NSE_copyImageFromRect:(NSRect)aRect;
- (struct OpaqueCMProfileRef *)NSE_displayColorSyncProfile;
- (struct CGColorSpace *)NSE_displayCGColorSpace;
- (id)NSE_displayColorSpace;
- (void)NSEWindow_getDisplayColorSpace:(id *)aSpace CGColorSpace:(struct CGColorSpace **)aSpace2 colorSyncProfile:(struct OpaqueCMProfileRef **)aProfile;
- (struct OpaqueCMProfileRef *)NSEWindow_colorSyncProfileForColorSpace:(id)aSpace withCGColorSpace:(struct CGColorSpace *)aSpace2;
@end

@interface NSWindow (NSEWindowLoading)
+ (void)load;
@end

