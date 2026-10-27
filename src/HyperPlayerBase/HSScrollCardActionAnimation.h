#import "HyperPlayerBasePrefix.h"


@interface HSScrollCardActionAnimation : NSAnimation
{
    NSView *_documentView;
    NSPoint _newOrigin;
    float _dx;
    float _dy;
}
- (void)setCurrentProgress:(CGFloat)aProgress;
- (void)dealloc;
- (id)initWithView:(id)aView scrollPoint:(NSPoint)aPoint;
@end

