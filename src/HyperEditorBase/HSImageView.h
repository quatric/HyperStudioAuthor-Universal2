#import "HyperEditorBasePrefix.h"


@interface HSImageView : NSView
{
    NSImage *_image;
}
- (void)setImage:(id)aImage;
- (id)image;
- (void)drawRect:(NSRect)aRect;
- (void)dealloc;
@end

