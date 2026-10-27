#import "HyperStudioPrefix.h"


@interface HSBrightnessView : NSView
{
    HSColor *_color;
}
+ (id)defaultColor;
- (id)color;
- (void)setColor:(id)aColor;
- (void)initializeColor;
- (void)drawRect:(NSRect)aRect;
- (id)initWithFrame:(NSRect)aFrame;
- (void)dealloc;
@end

