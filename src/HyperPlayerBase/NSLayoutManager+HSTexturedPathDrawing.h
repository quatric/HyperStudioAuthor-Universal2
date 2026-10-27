#import "HyperPlayerBasePrefix.h"


@interface NSLayoutManager (HSTexturedPathDrawing)
- (id)hyperRenderingPathWithGlyphRange:(NSRange)aRange textContainerOrigin:(NSPoint)aOrigin;
- (id)hyperPathForGlyphRange:(NSRange)aRange atPoint:(NSPoint)aPoint;
@end

