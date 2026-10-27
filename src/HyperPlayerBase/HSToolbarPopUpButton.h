#import "HyperPlayerBasePrefix.h"


@interface HSToolbarPopUpButton : NSPopUpButton
{
    NSImage *_regularImage;
    NSImage *_smallImage;
}
- (void)dealloc;
- (void)setControlSize:(NSControlSize)aSize;
- (NSControlSize)controlSize;
- (void)setRegularImage:(NSImage *)aImage;
- (void)setSmallImage:(NSImage *)aImage;
@end
