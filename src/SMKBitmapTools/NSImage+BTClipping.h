#import "SMKBitmapToolsPrefix.h"


@interface NSImage (BTClipping)
- (id)BT_imageByCroppingWithBezierPath:(id)aPath antialiased:(BOOL)aAntialiased;
- (id)BT_imageByCuttingOutBezierPath:(id)aPath antialiased:(BOOL)aAntialiased intoImage:(id *)aImage;
- (void)NSImage_BTClipping_cutOutBezierPath:(id)aPath antialiased:(BOOL)aAntialiased intoImage:(id *)aImage resultImage:(id *)aImage2;
@end

