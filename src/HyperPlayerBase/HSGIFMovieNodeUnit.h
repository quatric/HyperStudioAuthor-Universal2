#import "HyperPlayerBasePrefix.h"
#import "HSCelMovieNodeUnit.h"


@interface HSGIFMovieNodeUnit : HSCelMovieNodeUnit
{
    HSNewMedia *_animatedGIFMedia;
    NSBezierPath *_croppingPath;
    struct CGImageSource *_precachedGIFImageSource;
    BOOL _calculateFrameTimeLength;
}
+ (struct __CFDictionary *)HSGIFMovieNodeUnit_defaultImageSourceOptions;
+ (id)keysForStoring;
- (void)HSGIFMovieNodeUnit_calculateFrameTimeLengthForFramesImageSource:(struct CGImageSource *)aSource;
- (struct CGImageSource *)HSGIFMovieNodeUnit_imageSource;
- (void)HSGIFMovieNodeUnit_setFramesMedia:(id)aMedia precachedSource:(struct CGImageSource *)aSource;
- (id)frameImageForMediaUID:(id)aUID;
- (void)setAnimatedGIFMediaUID:(id)aUID;
- (id)animatedGIFMediaUID;
- (void)setCroppingPath:(id)aPath;
- (id)croppingPath;
- (void)setFramesMedia:(id)aMedia precachedSource:(struct CGImageSource *)aSource;
- (void)setFramesMedia:(id)aMedia precachedFrames:(id)aFrames;
- (void)setFramesMedia:(id)aMedia;
- (void)setGeneratedFramesMedia:(id)aMedia;
- (id)framesMedia;
- (id)generatedFramesMedia;
- (id)objectMediaUIDs;
- (BOOL)isHyperEqual:(id)aEqual;
- (id)copyWithZone:(NSZone *)aZone;
- (void)dealloc;
@end

