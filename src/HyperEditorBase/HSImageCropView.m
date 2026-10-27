#import "HSImageCropView.h"

// A tool view showing its image scaled, centred (pixel aligned) and at
// least filling the scroll view.

@implementation HSImageCropView

- (NSRect)convertImageRectToViewRect:(NSRect)aRect
{
    NSPoint offset = [self imageOffset];
    return NSMakeRect(offset.x + aRect.origin.x * _scaleFactor, offset.y + aRect.origin.y * _scaleFactor, aRect.size.width * _scaleFactor, aRect.size.height * _scaleFactor);
}

- (NSPoint)convertImagePointToViewPoint:(NSPoint)aPoint
{
    NSPoint offset = [self imageOffset];
    return NSMakePoint(offset.x + aPoint.x * _scaleFactor, offset.y + aPoint.y * _scaleFactor);
}

- (CGAffineTransform)imageToViewTransform
{
    NSPoint offset = [self imageOffset];
    return CGAffineTransformMake(_scaleFactor, 0, 0, _scaleFactor, offset.x, offset.y);
}

- (NSRect)convertViewRectToImageRect:(NSRect)aRect
{
    NSPoint offset = [self imageOffset];
    return NSMakeRect((aRect.origin.x - offset.x) / _scaleFactor, (aRect.origin.y - offset.y) / _scaleFactor, aRect.size.width / _scaleFactor, aRect.size.height / _scaleFactor);
}

- (NSPoint)convertViewPointToImagePoint:(NSPoint)aPoint
{
    NSPoint offset = [self imageOffset];
    return NSMakePoint((aPoint.x - offset.x) / _scaleFactor, (aPoint.y - offset.y) / _scaleFactor);
}

- (CGAffineTransform)viewToImageTransform
{
    NSPoint offset = [self imageOffset];
    CGFloat scale = 1.0 / _scaleFactor;
    return CGAffineTransformTranslate(CGAffineTransformMakeScale(scale, scale), -offset.x, -offset.y);
}

// The scaled image's origin, centred in the bounds.
- (NSPoint)imageOffset
{
    id image = [self image];
    if (image == nil)
        return NSZeroPoint;
    NSRect bounds = [self bounds];
    CGSize size = [image imageSize];
    CGFloat x = floor(NSMidX(bounds) - size.width * _scaleFactor * 0.5);
    CGFloat y = floor(NSMidY(bounds) - size.height * _scaleFactor * 0.5);
    return NSMakePoint(x - bounds.origin.x, y - bounds.origin.y);
}

- (id)undoManagerForTool:(id)aTool category:(id)aCategory
{
    return nil;
}

- (void)setScaleFactor:(double)aFactor
{
    if (_scaleFactor == aFactor)
        return;
    _scaleFactor = aFactor;
    [self HSImageCropView_updateFrameSize];
    [self setNeedsDisplay:YES];
}

- (void)setFrameSize:(NSSize)aSize
{
    CGSize size = [[self image] imageSize];
    CGFloat width = ceil(size.width * _scaleFactor);
    CGFloat height = ceil(size.height * _scaleFactor);
    [super setFrameSize:NSMakeSize(MAX(width, aSize.width), MAX(height, aSize.height))];
}

// The scroll view's content size, made big enough for the image.
- (void)HSImageCropView_updateFrameSize
{
    NSScrollView *scrollView = [self enclosingScrollView];
    NSSize size = [[scrollView class] contentSizeForFrameSize:[scrollView frame].size horizontalScrollerClass:nil verticalScrollerClass:nil borderType:[scrollView borderType] controlSize:NSControlSizeRegular scrollerStyle:[NSScroller preferredScrollerStyle]];
    [self setFrameSize:size];
}

- (double)scaleFactor
{
    return _scaleFactor;
}

- (void)setImage:(id)aImage
{
    [self setImage:aImage imageProperties:nil];
    [self HSImageCropView_updateFrameSize];
}

- (id)initWithFrame:(NSRect)aFrame
{
    if ((self = [super initWithFrame:aFrame]))
        _scaleFactor = 1.0;
    return self;
}

- (void)drawContentRect:(NSRect)aRect
{
    id image = [self image];
    if ([self backgroundColor] != nil) {
        [[self backgroundColor] set];
        NSRectFill(aRect);
    }
    if (image == nil)
        return;
    NSRect bounds = [self bounds];
    CGSize size = [image imageSize];
    NSRect rect;
    rect.size = NSMakeSize(size.width * _scaleFactor, size.height * _scaleFactor);
    rect.origin.x = floor(NSMidX(bounds) - rect.size.width * 0.5);
    rect.origin.y = floor(NSMidY(bounds) - rect.size.height * 0.5);
    if ([image conformsToProtocol:@protocol(BTCocoaImage)])
        [image drawInCurrentNSGraphicsContextInRect:rect];
    else if ([image conformsToProtocol:@protocol(BTCGImage)])
        [image drawInCGContext:[[NSGraphicsContext currentContext] CGContext] inRect:NSRectToCGRect(rect)];
}

- (void)dealloc
{
    [_backgroundColor release];
    [super dealloc];
}

- (void)mouseEntered:(id)aEvent
{
    [super mouseEntered:aEvent];
    [[self delegate] mouseEntered:aEvent inView:self];
}

- (void)tool:(id)aTool didUpdateOutputForKey:(id)aKey
{
    [super tool:aTool didUpdateOutputForKey:aKey];
    if ([aKey isEqualToString:@"selectionPath"] || [aKey isEqualToString:@"selectionStartPoint"] || [aKey isEqualToString:@"selectionAffineTransform"])
        [[self delegate] selectionDidUpdateInView:self];
}

- (id)delegate
{
    return _delegate;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)backgroundColor
{
    return _backgroundColor;
}

- (void)setBackgroundColor:(id)aColor
{
    if (_backgroundColor != aColor) {
        [_backgroundColor release];
        _backgroundColor = [aColor copy];
    }
}

@end
