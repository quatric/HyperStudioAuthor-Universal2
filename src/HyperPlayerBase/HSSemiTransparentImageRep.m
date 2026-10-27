#import "HSSemiTransparentImageRep.h"
@implementation HSSemiTransparentImageRep
// The image drawn at the rep's opacity.
- (BOOL)draw
{
    [_image drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:_opacity];
    return YES;
}
- (id)copyWithZone:(NSZone *)aZone
{
    return [self retain];
}
- (void)dealloc
{
    [_image release];
    [super dealloc];
}
// Not archivable.
- (void)encodeWithCoder:(id)aCoder
{
}
- (id)initWithCoder:(id)aCoder
{
    [self release];
    return nil;
}
- (id)initWithImage:(id)aImage opacity:(CGFloat)aOpacity
{
    self = [super init];
    if (self != nil) {
        _image = [aImage retain];
        _opacity = aOpacity;
        if (_image != nil)
            [super setSize:[_image size]];
    }
    return self;
}
@end
