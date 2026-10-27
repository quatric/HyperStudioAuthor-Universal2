#import "HyperStudioPrefix.h"


@interface HSCustomWindow : NSPanel
{
    HSCustomWindowContentView *_customContentView;
}
- (NSRect)contentRectForFrameRect:(NSRect)aRect;
- (NSRect)frameRectForContentRect:(NSRect)aRect;
- (void)setContentView:(id)aView;
- (void)setCustomWindowContentViewClass:(Class)aClass;
- (void)moveSubviewsOfView:(id)aView toView:(id)aView2;
- (id)customWindowContentView;
- (void)dealloc;
- (id)initWithContentRect:(NSRect)aRect styleMask:(NSUInteger)aMask backing:(NSUInteger)aBacking defer:(BOOL)aDefer;
@end

