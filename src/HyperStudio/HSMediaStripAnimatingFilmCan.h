#import "HyperStudioPrefix.h"


@interface HSMediaStripAnimatingFilmCan : NSView
{
    NSArray *_images;
    BOOL _isRenderingEnabled;
    unsigned int _renderedImageIndex;
}
+ (id)generatedDataForDistancesToRightEdgeInAnimation;
+ (id)distancesToRightEdgeInAnimation;
+ (id)calculateDistancesToRightEdgeInAnimationForRep:(id)aRep iconCount:(NSInteger)aCount;
+ (NSUInteger)calculateDistanceToRightEdgeForIconWithRep:(id)aRep iconCount:(NSInteger)aCount animationStep:(NSInteger)aStep;
+ (CGFloat)filmCanWidthDistanceBetweenFrameIndex:(NSUInteger)aIndex andFrameIndex:(NSUInteger)aIndex2;
+ (CGFloat)filmCanWidthDistanceForAnimationFramesRange:(NSRange)aRange;
+ (id)imagesForAnimation;
+ (id)createImagesForRep:(id)aRep iconCount:(NSInteger)aCount;
+ (id)createImageForIconWithRep:(id)aRep iconCount:(NSInteger)aCount animationStep:(NSInteger)aStep;
+ (NSUInteger)indexOfFirstFrameWhenStripReachesMaxSize;
+ (NSUInteger)distanceToRightEdgeInAnimationInFrameAtIndex:(NSUInteger)aIndex;
+ (NSUInteger)countOfDistancesToRightEdgeInAnimation;
- (void)drawRect:(NSRect)aRect;
- (void)drawImage:(id)aImage;
- (NSUInteger)maxRenderedImageIndex;
- (void)setRenderedImageIndex:(NSUInteger)aIndex;
- (NSUInteger)renderedImageIndex;
- (NSUInteger)countOfImages;
- (id)images;
- (BOOL)isRenderingEnabled;
- (void)setIsRenderingEnabled:(BOOL)aEnabled;
- (void)dealloc;
@end

