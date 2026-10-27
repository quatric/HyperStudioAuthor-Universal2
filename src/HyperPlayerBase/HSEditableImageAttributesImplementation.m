#import "HSEditableImageAttributesImplementation.h"
// Editable image attributes of a node with an editable image node unit:
// image editing goes to the unit, the image rect to the node's image rect
// subattributes.

@implementation HSEditableImageAttributesImplementation

+ (id)hyperImplementationWithNode:(id)aNode unit:(id)aUnit
{
    if (![aUnit isKindOfClass:[HSEditableImageNodeUnit class]])
        return nil;
    return [[[self alloc] initWithNodeUnit:aUnit node:aNode] autorelease];
}

- (id)attributeObservingController
{
    return _node;
}

- (void)setEditableImageMedia:(id)aMedia
{
    [_nodeUnit setEditableImageMedia:aMedia];
}

- (id)editableImageMedia
{
    return [_nodeUnit editableImageMedia];
}

- (NSRect)imageRect
{
    return [_imageRectSubattributes imageRect];
}

- (void)endEditImage
{
    [_nodeUnit endEditImage];
}

- (void)beginEditImage:(id)aImage inRect:(NSRect)aRect
{
    [_nodeUnit beginEditImage:aImage inRect:aRect];
}

- (void)beginEditImage:(id)aImage
{
    [_nodeUnit beginEditImage:aImage];
}

- (void)endEditImageContinuously
{
    [_nodeUnit endEditImageContinuously];
}

- (void)beginEditImageContinuously
{
    [_nodeUnit beginEditImageContinuously];
}

- (id)queryImageWithRequiredProtocols:(id *)aProtocols optionalProtocols:(id *)aProtocols2
{
    return [_nodeUnit queryImageWithRequiredProtocols:aProtocols optionalProtocols:aProtocols2];
}

- (id)hyperObject
{
    return _node;
}

- (id)node
{
    return _node;
}

- (void)dealloc
{
    [_imageRectSubattributes release];
    [_nodeUnit release];
    [_node release];
    [super dealloc];
}

- (id)initWithNodeUnit:(id)aUnit node:(id)aNode
{
    self = [super init];
    if (!self)
        return nil;
    _node = [aNode retain];
    _nodeUnit = [aUnit retain];
    _imageRectSubattributes = [[aNode queryHyperInterface:@protocol(HSImageRectSubattributes)] retain];
    if (!_imageRectSubattributes) {
        [self release];
        return nil;
    }
    return self;
}

@end
