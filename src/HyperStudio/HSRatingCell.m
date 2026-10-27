#import "HSRatingCell.h"

@implementation HSRatingCell

- (void)setPointsCount:(NSUInteger)aCount
{
    _pointsCount = (unsigned int)aCount;
}

- (NSUInteger)pointsCount
{
    return _pointsCount;
}

- (void)setRating:(CGFloat)aRating
{
    _rating = aRating;
}

- (CGFloat)rating
{
    return _rating;
}

- (id)pointDimmedImage
{
    return _pointDimmedImage;
}

- (void)setPointDimmedImage:(id)aImage
{
    if (_pointDimmedImage != aImage) {
        [_pointDimmedImage release];
        _pointDimmedImage = [aImage retain];
    }
}

- (id)pointImage
{
    return _pointImage;
}

- (void)setPointImage:(id)aImage
{
    if (_pointImage != aImage) {
        [_pointImage release];
        _pointImage = [aImage retain];
    }
}

- (id)copyWithZone:(NSZone *)aZone
{
    HSRatingCell *copy = [[HSRatingCell allocWithZone:aZone] init];
    [copy setRating:_rating];
    [copy setPointsCount:_pointsCount];
    [copy setPointDimmedImage:_pointDimmedImage];
    [copy setPointImage:_pointImage];
    return copy;
}

- (void)drawWithFrame:(NSRect)aFrame inView:(id)aView
{
    [self drawInteriorWithFrame:aFrame inView:aView];
}

// Dimmed points fill the cell; lit points cover the rating, the last one clipped to the fraction.
- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView
{
    NSSize imageSize = [_pointDimmedImage size];
    [_pointDimmedImage setFlipped:[aView isFlipped]];
    [_pointImage setFlipped:[aView isFlipped]];
    float pointWidth = aFrame.size.width / (float)_pointsCount;
    NSRect sourceRect = NSMakeRect(0.0, 0.0, imageSize.width, imageSize.height);
    for (unsigned int i = 0; i < _pointsCount; i++)
        [_pointDimmedImage drawInRect:NSMakeRect(aFrame.origin.x + i * pointWidth, aFrame.origin.y, pointWidth, aFrame.size.height) fromRect:sourceRect operation:NSCompositingOperationSourceOver fraction:1.0];
    float points = _rating / (float)(1.0 / (double)_pointsCount);
    unsigned int whole = (unsigned int)floorf(points);
    float fraction = points - (float)whole;
    for (unsigned int i = 0; i < whole; i++)
        [_pointImage drawInRect:NSMakeRect(aFrame.origin.x + i * pointWidth, aFrame.origin.y, pointWidth, aFrame.size.height) fromRect:sourceRect operation:NSCompositingOperationSourceOver fraction:1.0];
    [_pointImage drawInRect:NSMakeRect(aFrame.origin.x + whole * pointWidth, aFrame.origin.y, pointWidth * fraction, aFrame.size.height) fromRect:NSMakeRect(0.0, 0.0, imageSize.width * fraction, imageSize.height) operation:NSCompositingOperationSourceOver fraction:1.0];
}

- (void)dealloc
{
    [_pointImage release];
    [_pointDimmedImage release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil)
        _pointsCount = 1;
    return self;
}

@end
