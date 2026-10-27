#import "SMKBitmapToolsPrefix.h"


@interface NSImageRep_BTImage_BTCocoaImageRep : NSImageRep
{
    id<BTCocoaImage> _cocoaImage;
}
- (BOOL)draw;
- (void)dealloc;
- (id)initWithBTCocoaImage:(id)aImage;
- (id)init;
@end

@interface NSImageRep_BTImage_BTCGImageRep : NSImageRep
{
    id<BTCGImage> _coreGraphicsImage;
}
- (BOOL)draw;
- (void)dealloc;
- (id)initWithBTCGImage:(id)aImage;
- (id)init;
@end

@interface NSImageRep (BTImage)
+ (id)BT_imageRepWithBTCocoaImage:(id)aImage;
+ (id)BT_imageRepWithBTCGImage:(id)aImage;
@end

