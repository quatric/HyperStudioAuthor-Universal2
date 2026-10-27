#import "HyperPlayerBasePrefix.h"
#import "HSMovieObjectBaseData.h"


@interface HSMovieObjectData : HSMovieObjectBaseData
{
    BOOL _hasController;
    BOOL _eraseWhenDone;
    float _movieProportion;
    BOOL _keepWidthWhileResizing;
    BOOL _movieFlippedHorizontal;
    BOOL _movieFlippedVertical;
    float _movieRotationAngle;
    BOOL _printing;
    float _tiltAngle;
    float _panAngle;
    float _fieldOfView;
    NSRect _relativeMovieSourceRect;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)relativeSourceRectAsString;
- (void)setRelativeSourceRectAsString:(id)aString;
- (NSRect)relativeMovieSourceRect;
- (void)setRelativeMovieSourceRect:(NSRect)aRect;
- (CGFloat)fieldOfView;
- (void)setFieldOfView:(CGFloat)aView;
- (CGFloat)panAngle;
- (void)setPanAngle:(CGFloat)aAngle;
- (CGFloat)tiltAngle;
- (void)setTiltAngle:(CGFloat)aAngle;
- (void)setPrinting:(BOOL)aPrinting;
- (BOOL)isPrinting;
- (void)setMovieRotationAngle:(CGFloat)aAngle;
- (CGFloat)movieRotationAngle;
- (void)setMovieFlippedVertical:(BOOL)aVertical;
- (BOOL)isMovieFlippedVertical;
- (void)setMovieFlippedHorizontal:(BOOL)aHorizontal;
- (BOOL)isMovieFlippedHorizontal;
- (void)setKeepWidthWhileResizing:(BOOL)aResizing;
- (BOOL)keepWidthWhileResizing;
- (void)setMovieProportion:(CGFloat)aProportion;
- (CGFloat)movieProportion;
- (void)setEraseWhenDone:(BOOL)aDone;
- (BOOL)eraseWhenDone;
- (void)setHasController:(BOOL)aController;
- (BOOL)hasController;
- (id)init;
- (void)setShadowEnabled:(BOOL)aEnabled;
@end

