#import "HSMovieObjectData.h"

// Relative float comparison used by the original angle setters.
static BOOL HSMovieObjectDataFloatsDiffer(float a, float b)
{
    float magnitude = MAX(a != 0.0f ? fabsf(a) : 1.0f, b != 0.0f ? fabsf(b) : 1.0f);
    return magnitude * 0.0005f < fabsf(a - b);
}

@implementation HSMovieObjectData

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraStoringWithCodingContext:aContext]];
    [keys addObject:@"hasController"];
    [keys addObject:@"eraseWhenDone"];
    [keys addObject:@"opacity"];
    [keys addObject:@"movieFlippedHorizontal"];
    [keys addObject:@"movieFlippedVertical"];
    [keys addObject:@"movieRotationAngle"];
    [keys addObject:@"tiltAngle"];
    [keys addObject:@"panAngle"];
    [keys addObject:@"fieldOfView"];
    [keys addObject:@"relativeSourceRectAsString"];
    if (![[aContext codingOperation] isEqualToString:@"HSObjectStyleCodingOperation"])
        [keys addObject:@"movieProportion"];
    return keys;
}

- (id)relativeSourceRectAsString
{
    return NSStringFromRect(_relativeMovieSourceRect);
}

- (void)setRelativeSourceRectAsString:(id)aString
{
    _relativeMovieSourceRect = NSRectFromString(aString);
}

- (NSRect)relativeMovieSourceRect
{
    return _relativeMovieSourceRect;
}

- (void)setRelativeMovieSourceRect:(NSRect)aRect
{
    _relativeMovieSourceRect = aRect;
}

- (CGFloat)fieldOfView
{
    return _fieldOfView;
}

- (void)setFieldOfView:(CGFloat)aView
{
    if (HSMovieObjectDataFloatsDiffer(_fieldOfView, aView))
        _fieldOfView = aView;
}

- (CGFloat)panAngle
{
    return _panAngle;
}

- (void)setPanAngle:(CGFloat)aAngle
{
    if (HSMovieObjectDataFloatsDiffer(_panAngle, aAngle))
        _panAngle = aAngle;
}

- (CGFloat)tiltAngle
{
    return _tiltAngle;
}

- (void)setTiltAngle:(CGFloat)aAngle
{
    if (HSMovieObjectDataFloatsDiffer(_tiltAngle, aAngle))
        _tiltAngle = aAngle;
}

- (void)setPrinting:(BOOL)aPrinting
{
    _printing = aPrinting;
}

- (BOOL)isPrinting
{
    return _printing;
}

- (void)setMovieRotationAngle:(CGFloat)aAngle
{
    _movieRotationAngle = aAngle;
}

- (CGFloat)movieRotationAngle
{
    return _movieRotationAngle;
}

- (void)setMovieFlippedVertical:(BOOL)aVertical
{
    _movieFlippedVertical = aVertical;
}

- (BOOL)isMovieFlippedVertical
{
    return _movieFlippedVertical;
}

- (void)setMovieFlippedHorizontal:(BOOL)aHorizontal
{
    _movieFlippedHorizontal = aHorizontal;
}

- (BOOL)isMovieFlippedHorizontal
{
    return _movieFlippedHorizontal;
}

- (void)setKeepWidthWhileResizing:(BOOL)aResizing
{
    _keepWidthWhileResizing = aResizing;
}

- (BOOL)keepWidthWhileResizing
{
    return _keepWidthWhileResizing;
}

- (void)setMovieProportion:(CGFloat)aProportion
{
    _movieProportion = aProportion;
}

- (CGFloat)movieProportion
{
    return _movieProportion;
}

- (void)setEraseWhenDone:(BOOL)aDone
{
    _eraseWhenDone = aDone;
}

- (BOOL)eraseWhenDone
{
    return _eraseWhenDone;
}

- (void)setHasController:(BOOL)aController
{
    _hasController = aController;
}

- (BOOL)hasController
{
    return _hasController;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _hasController = NO;
        _eraseWhenDone = NO;
        _movieProportion = 1.0f;
        _keepWidthWhileResizing = YES;
        _movieFlippedHorizontal = NO;
        _movieFlippedVertical = NO;
        _movieRotationAngle = 0.0f;
        _printing = NO;
        _relativeMovieSourceRect = NSMakeRect(0.0, 0.0, 1.0, 1.0);
    }
    return self;
}

- (void)setShadowEnabled:(BOOL)aEnabled
{
    [super setShadowEnabled:aEnabled];
}

@end
