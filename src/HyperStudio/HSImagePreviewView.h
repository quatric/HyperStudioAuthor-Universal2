#import "HyperStudioPrefix.h"


@interface HSImagePreviewView : NSView
{
    NSImage *_image;
    int _scaling;
    id _delegate;
    unsigned int _isFlippedVertically:1;
    unsigned int _isFlippedHorizontally:1;
}
- (BOOL)resignFirstResponder;
- (BOOL)becomeFirstResponder;
- (BOOL)acceptsFirstResponder;
- (void)mouseDown:(id)aDown;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)setFlippedHorizontally:(BOOL)aHorizontally;
- (void)setFlippedVertically:(BOOL)aVertically;
- (void)setScaling:(NSInteger)aScaling;
- (NSInteger)scaling;
- (void)setImage:(id)aImage;
- (id)image;
- (void)drawRect:(NSRect)aRect;
- (void)dealloc;
@end

