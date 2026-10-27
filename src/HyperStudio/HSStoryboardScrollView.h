#import "HyperStudioPrefix.h"


@interface HSStoryboardScrollView : NSScrollView
{
    HSStoryboardView *_storyboardView;
    NSSlider *_scaleSlider;
    NSImageView *_leftImageView;
    NSImageView *_rightImageView;
}
- (void)tile;
- (id)scaleSlider;
- (void)setStoryboardView:(id)aView;
- (id)storyboardView;
- (void)dealloc;
- (id)initWithFrame:(NSRect)aFrame storyboardView:(id)aView;
@end

