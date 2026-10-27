#import "HyperStudioPrefix.h"


@interface HSCrayonItem : NSObject
{
    NSColor *_color;
    NSRect _frame;
    NSImage *_image;
    NSBezierPath *_hitZonePath;
}
+ (id)sharedCrayonShadow;
+ (id)sharedCrayonsBlinksRasterImage;
+ (id)sharedCrayonShapePath;
- (BOOL)hitTestPoint:(NSPoint)aPoint;
- (void)drawInView:(id)aView;
- (id)imageForView:(id)aView;
- (void)setFrame:(NSRect)aFrame;
- (NSRect)frame;
- (id)color;
- (BOOL)isFlipped;
- (void)dealloc;
- (id)initWithColor:(id)aColor frame:(NSRect)aFrame;
@end

