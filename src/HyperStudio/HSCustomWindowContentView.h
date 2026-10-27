#import "HyperStudioPrefix.h"


@interface HSCustomWindowContentView : HSTexturedView
{
    NSView *_containerView;
    float _margins[4];
}
- (NSRect)applyMarginsToRect:(NSRect)aRect extend:(BOOL)aExtend;
- (void)setBottomMargin:(CGFloat)aMargin;
- (CGFloat)bottomMargin;
- (void)setTopMargin:(CGFloat)aMargin;
- (CGFloat)topMargin;
- (void)setRightMargin:(CGFloat)aMargin;
- (CGFloat)rightMargin;
- (void)setLeftMargin:(CGFloat)aMargin;
- (CGFloat)leftMargin;
- (void)addSubview:(id)aSubview positioned:(NSInteger)aPositioned relativeTo:(id)aTo;
- (void)addSubview:(id)aSubview;
- (id)containerView;
- (void)dealloc;
@end

