#import "HyperEditorBasePrefix.h"


@interface HSControlAnimation : NSAnimation
{
    NSArray *_properties;
}
- (void)finishAnimation;
- (void)setCurrentProgress:(CGFloat)aProgress;
- (void)dealloc;
- (id)initWithAnimationProperties:(id)aProperties;
@end

