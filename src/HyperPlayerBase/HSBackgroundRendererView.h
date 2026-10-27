#import "HyperPlayerBasePrefix.h"


@interface HSBackgroundRendererView : NSView
{
    id<HSBackgroundRenderer> _backgroundRendererInterface;
}
- (void)drawRect:(NSRect)aRect;
- (void)setBackgroundRenderer:(id)aRenderer;
- (id)backgroundRenderer;
- (void)dealloc;
@end

