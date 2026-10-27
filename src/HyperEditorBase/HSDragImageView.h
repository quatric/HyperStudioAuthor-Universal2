#import "HyperEditorBasePrefix.h"


@interface HSDragImageView : NSImageView
{
    id _delegate;
}
- (void)pasteboard:(id)aPasteboard provideDataForType:(id)aType;
- (void)mouseDragged:(id)aDragged;
- (void)mouseDown:(id)aDown;
- (BOOL)acceptsFirstMouse:(id)aMouse;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
@end

@interface HSDragImageView (HSDragImageViewPrivate)
- (id)dragImage;
@end

