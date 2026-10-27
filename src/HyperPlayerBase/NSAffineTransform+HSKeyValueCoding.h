#import "HyperPlayerBasePrefix.h"


@interface NSAffineTransform (HSKeyValueCoding)
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)extraDictionaryRepresentationWithCodingContext:(id)aContext;
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext;
@end

@interface NSAffineTransform (HSExtendedAffineTransform)
+ (id)transformWithHyperString:(id)aString;
+ (id)transformWithHyperCGAffineTransform:(CGAffineTransform)aTransform;
+ (id)transformWithHyperTransformStruct:(struct HyperPlayerBase_anon1)aStruct;
+ (id)hyperTransitionFromRect:(NSRect)aRect toRect:(NSRect)aRect2;
+ (id)hyperYFlipInRect:(NSRect)aRect;
+ (id)hyperXFlipInRect:(NSRect)aRect;
+ (id)hyperYFlipWithHeight:(CGFloat)aHeight;
+ (id)hyperXFlipWithWidth:(CGFloat)aWidth;
+ (id)hyperRotationBy:(CGFloat)aBy aboutPoint:(NSPoint)aPoint;
+ (id)hyperRotationBy:(CGFloat)aBy;
+ (id)hyperScalingBy:(NSSize)aBy aboutPoint:(NSPoint)aPoint;
+ (id)hyperScalingBy:(NSSize)aBy;
+ (id)hyperTranslationBy:(NSSize)aBy;
- (void)setHyperCGAffineTransform:(CGAffineTransform)aTransform;
- (CGAffineTransform)hyperCGAffineTransform;
- (NSSize)hyperRemoveScale;
- (NSSize)hyperInverseScaleFactor;
- (NSSize)hyperScaleFactor;
- (NSRect)hyperTransformAndBoundRect:(NSRect)aRect;
- (void)hyperTransformPoints:(NSPoint *)aPoints count:(NSUInteger)aCount;
- (BOOL)isHyperEqual:(id)aEqual;
- (id)hyperPostmultiplyBy:(id)aBy;
- (id)hyperPremultiplyBy:(id)aBy;
- (id)hyperInverseTransform;
- (id)hyperInvert;
- (id)hyperPostflipYInRect:(NSRect)aRect;
- (id)hyperPostflipXInRect:(NSRect)aRect;
- (id)hyperPreflipYInRect:(NSRect)aRect;
- (id)hyperPreflipXInRect:(NSRect)aRect;
- (id)hyperPostflipYWithHeight:(CGFloat)aHeight;
- (id)hyperPostflipXWithWidth:(CGFloat)aWidth;
- (id)hyperPreflipYWithHeight:(CGFloat)aHeight;
- (id)hyperPreflipXWithWidth:(CGFloat)aWidth;
- (id)hyperPostrotateBy:(CGFloat)aBy aboutPoint:(NSPoint)aPoint;
- (id)hyperPrerotateBy:(CGFloat)aBy aboutPoint:(NSPoint)aPoint;
- (id)hyperPostrotateBy:(CGFloat)aBy;
- (id)hyperPrerotateBy:(CGFloat)aBy;
- (id)hyperPostscaleBy:(NSSize)aBy aboutPoint:(NSPoint)aPoint;
- (id)hyperPrescaleBy:(NSSize)aBy aboutPoint:(NSPoint)aPoint;
- (id)hyperPostscaleBy:(NSSize)aBy;
- (id)hyperPrescaleBy:(NSSize)aBy;
- (id)hyperPosttranslateBy:(NSSize)aBy;
- (id)hyperPretranslateBy:(NSSize)aBy;
- (id)initWithHyperString:(id)aString;
- (id)initWithHyperCGAffineTransform:(CGAffineTransform)aTransform;
- (id)initWithHyperTransformStruct:(struct HyperPlayerBase_anon1)aStruct;
- (id)initWithHyperTransitionFromRect:(NSRect)aRect toRect:(NSRect)aRect2;
- (id)initWithHyperFlipYInRect:(NSRect)aRect;
- (id)initWithHyperFlipXInRect:(NSRect)aRect;
- (id)initWithHyperFlipYWithHeight:(CGFloat)aHeight;
- (id)initWithHyperFlipXWithWidth:(CGFloat)aWidth;
- (id)initWithHyperRotationBy:(CGFloat)aBy aboutPoint:(NSPoint)aPoint;
- (id)initWithHyperRotationBy:(CGFloat)aBy;
- (id)initWithHyperScalingBy:(NSSize)aBy aboutPoint:(NSPoint)aPoint;
- (id)initWithHyperScalingBy:(NSSize)aBy;
- (id)initWithHyperTranslationBy:(NSSize)aBy;
@end

