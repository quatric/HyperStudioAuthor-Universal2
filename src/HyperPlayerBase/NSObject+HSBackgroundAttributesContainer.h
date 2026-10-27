#import "HyperPlayerBasePrefix.h"


@interface NSObject (HSBackgroundAttributesContainer)
- (void)setCurrentBackground:(id)aBackground;
- (id)currentBackground;
- (id)hyperBackgroundThumbnailForSize:(NSSize)aSize;
- (void)hyperDrawBackgroundInROI:(NSRect)aROI ofBounds:(NSRect)aBounds;
- (id)queryBackgroundGraphicsInterface:(id)aInterface;
- (void)setBackgroundGraphics:(id)aGraphics;
- (void)setBackgroundGraphics:(id)aGraphics copyObject:(BOOL)aObject;
- (id)undoManagerForGraphics:(id)aGraphics;
- (void)hyperVisualAttributesChanged:(id)aChanged;
@end

