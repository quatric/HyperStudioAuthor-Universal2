#import "HyperPlayerBasePrefix.h"


@interface HSBackgroundView : NSView
{
    HSBackgroundViewRenderer *_backgroundRenderer;
    NSDictionary *_backgroundAttributes;
}
- (void)drawRect:(NSRect)aRect;
- (id)backgroundAttributes;
- (void)setBackgroundAttributes:(id)aAttributes;
- (id)backgroundRenderer;
- (void)setBackgroundRenderer:(id)aRenderer;
- (void)dealloc;
- (id)initWithFrame:(NSRect)aFrame;
- (id)initWithFrame:(NSRect)aFrame backgroundAttributes:(id)aAttributes;
@end

