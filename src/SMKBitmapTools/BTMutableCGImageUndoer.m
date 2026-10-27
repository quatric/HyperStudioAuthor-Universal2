#import "BTMutableCGImageUndoer.h"
#import "BTCGImageSaver.h"

// Undo for a mutable CG image: before each change the affected rect is
// copied, and undoing draws the copy back (registering the redo the same
// way). While grouping, a copy of the whole image is taken at the first
// change and the union of the changed rects is registered when the group ends.

@implementation BTMutableCGImageUndoer

- (id)init
{
    [self release];
    return nil;
}

- (id)initWithImage:(id)aImage delegate:(id)aDelegate
{
    self = [super init];
    if (!self)
        return nil;
    _image = [aImage retain];
    _delegate = aDelegate;
    return self;
}

- (void)dealloc
{
    [_originalImageCopy release];
    [_image release];
    [super dealloc];
}

- (id)image
{
    return _image;
}

- (id)delegate
{
    return _delegate;
}

// An autoreleased BTCGImage of aRect of aImage, in premultiplied ARGB.
- (id)BTMutableCGImageUndoer_copyRect:(CGRect)aRect fromImage:(id)aImage
{
    size_t width = CGRectGetWidth(aRect) > 0 ? lround(ceil(CGRectGetWidth(aRect))) : 0;
    size_t height = CGRectGetHeight(aRect) > 0 ? lround(ceil(CGRectGetHeight(aRect))) : 0;
    size_t bytesPerRow = ((width * 32 + 127) >> 3) & ~(size_t)15;
    NSMutableData *data = [[[NSMutableData alloc] initWithLength:height * bytesPerRow] autorelease];
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = NULL;
    id copy = nil;
    if ([data mutableBytes] && space) {
        context = CGBitmapContextCreate([data mutableBytes], width, height, 8, bytesPerRow, space,
                                        (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
        if (context) {
            [aImage drawInCGContext:context atPoint:CGPointMake(-aRect.origin.x, -aRect.origin.y)];
            copy = [[[BTCGImage alloc] initWithBitmapData:data
                                                    width:(NSUInteger)CGRectGetWidth(aRect)
                                                   height:(NSUInteger)CGRectGetHeight(aRect)
                                         bitsPerComponent:8
                                             bitsPerPixel:32
                                              bytesPerRow:bytesPerRow
                                               colorSpace:space
                                               bitmapInfo:kCGImageAlphaPremultipliedFirst
                                                   decode:NULL
                                        shouldInterpolate:NO
                                                   intent:kCGRenderingIntentDefault] autorelease];
        }
    }
    CGColorSpaceRelease(space);
    CGContextRelease(context);
    return copy;
}

- (void)BTMutableCGImageUndoer_replaceRect:(CGRect)aRect withImage:(id)aImage
{
    [_delegate imageUndoer:self willChangeImageInRect:aRect];
    id current = [self BTMutableCGImageUndoer_copyRect:aRect fromImage:_image];
    if (current)
        [[_delegate prepareUndoForImageUndoer:self withInvocationTarget:self]
            BTMutableCGImageUndoer_replaceRect:aRect withImage:current];
    [_image beginCGEditing];
    CGContextRef context = [_image imageCGContext];
    if (context) {
        CGContextClearRect(context, aRect);
        [aImage drawInCGContext:context inRect:aRect];
    }
    [_image endCGEditing];
    [_delegate imageUndoer:self didChangeImageInRect:aRect];
}

- (void)BTMutableCGImageUndoer_registerUndoInRect:(CGRect)aRect withOriginalImage:(id)aImage
{
    CGRect rect = CGRectIntegral(aRect);
    id original = [self BTMutableCGImageUndoer_copyRect:rect fromImage:aImage];
    if (original)
        [[_delegate prepareUndoForImageUndoer:self withInvocationTarget:self]
            BTMutableCGImageUndoer_replaceRect:rect withImage:original];
}

- (void)registerUndoInRect:(CGRect)aRect
{
    if (!_isGrouping)
        [self BTMutableCGImageUndoer_registerUndoInRect:aRect withOriginalImage:_image];
    else if (!_originalImageCopy) {
        CGSize size = [_image imageSize];
        _originalImageCopy = [[self BTMutableCGImageUndoer_copyRect:CGRectMake(0, 0, size.width, size.height)
                                                          fromImage:_image] retain];
        if (_originalImageCopy)
            _changedRect = aRect;
    } else
        _changedRect = CGRectUnion(_changedRect, aRect);
}

- (void)beginUndoGrouping
{
    _isGrouping = 1;
}

- (void)endUndoGrouping
{
    if (_originalImageCopy) {
        [self BTMutableCGImageUndoer_registerUndoInRect:_changedRect withOriginalImage:_originalImageCopy];
        [_originalImageCopy release];
        _originalImageCopy = nil;
    }
    _isGrouping = 0;
}

@end
