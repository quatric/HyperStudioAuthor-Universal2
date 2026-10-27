#import "HyperStudioPrefix.h"


@interface HSShadowView : NSView
{
    NSView *_shadowSubview;
    NSColor *_backgroundColor;
    id _shadow;
    NSRect _cachedShadowRect;
    NSImage *_cachedImage;
    BOOL _cachingDisabled;
    BOOL _isActive;
}
- (void)viewDidEndLiveResize;
- (void)viewWillStartLiveResize;
- (void)setShadow:(id)aShadow;
- (id)shadow;
- (void)setActive:(BOOL)aActive;
- (BOOL)isActive;
- (id)activeBorderColor;
- (void)setBackgroundColor:(id)aColor;
- (id)backgroundColor;
- (id)hitTest:(NSPoint)aTest;
- (BOOL)becomeFirstResponder;
- (BOOL)acceptsFirstResponder;
- (void)drawRect:(NSRect)aRect;
- (id)cachedImage;
- (void)drawBorderWithPath:(id)aPath;
- (void)drawShadowWithPath:(id)aPath;
- (id)shadowRectPath;
- (void)willRemoveSubview:(id)aSubview;
- (void)invalidateCache;
- (NSRect)shadowRect;
- (void)dealloc;
@end

