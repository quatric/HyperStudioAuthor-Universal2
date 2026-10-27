#import "SMKBitmapToolsPrefix.h"


@interface BTSizeSnapSource : NSObject <BTSizeSnapSource, NSObject>
{
    CGSize _size;
    CGSize _minSize;
    CGSize _maxSize;
    CGFloat _proportionFactor;
    CGAffineTransform _showTransform;
    NSDictionary *_options;
}
- (id)description;
- (id)BTSizeSnapSource_protected_membersDescription;
- (id)options;
- (CGAffineTransform)showTransform;
- (CGFloat)proportionFactor;
- (CGSize)maxSize;
- (CGSize)minSize;
- (CGSize)size;
- (void)dealloc;
- (id)initWithSize:(CGSize)aSize minSize:(CGSize)aSize2 maxSize:(CGSize)aSize3 proportionFactor:(CGFloat)aFactor showTransform:(CGAffineTransform)aTransform options:(id)aOptions;
@end

@interface BTSizeToPointSnapSource : BTSizeSnapSource <BTSizeToPointReflecting>
{
    CGPoint _basePoint;
    CGPoint _resizingCenter;
    CGAffineTransform _reflectingTransform;
}
+ (id)sourceWithSize:(CGSize)aSize minSize:(CGSize)aSize2 maxSize:(CGSize)aSize3 proportionFactor:(CGFloat)aFactor showTransform:(CGAffineTransform)aTransform options:(id)aOptions basePoint:(CGPoint)aPoint resizingCenter:(CGPoint)aCenter reflectingTransform:(CGAffineTransform)aTransform2;
- (id)BTSizeSnapSource_protected_membersDescription;
- (CGPoint)reflectedPointForSize:(CGSize)aSize;
- (id)initWithSize:(CGSize)aSize minSize:(CGSize)aSize2 maxSize:(CGSize)aSize3 proportionFactor:(CGFloat)aFactor showTransform:(CGAffineTransform)aTransform options:(id)aOptions basePoint:(CGPoint)aPoint resizingCenter:(CGPoint)aCenter reflectingTransform:(CGAffineTransform)aTransform2;
- (id)initWithSize:(CGSize)aSize minSize:(CGSize)aSize2 maxSize:(CGSize)aSize3 proportionFactor:(CGFloat)aFactor showTransform:(CGAffineTransform)aTransform options:(id)aOptions;
@end

@interface BTPointSnapSource : NSObject <BTPointSnapSource, NSObject>
{
    CGPoint _point;
    CGFloat _minXBound;
    CGFloat _maxXBound;
    CGFloat _minYBound;
    CGFloat _maxYBound;
    struct CGELine _trajectoryLine;
    NSDictionary *_options;
}
- (id)description;
- (id)BTPointSnapSource_protected_membersDescription;
- (id)options;
- (struct CGELine)trajectoryLine;
- (CGFloat)maxYBound;
- (CGFloat)minYBound;
- (CGFloat)maxXBound;
- (CGFloat)minXBound;
- (CGPoint)point;
- (void)dealloc;
- (id)initWithPoint:(CGPoint)aPoint minXBound:(CGFloat)aBound maxXBound:(CGFloat)aBound2 minYBound:(CGFloat)aBound3 maxYBound:(CGFloat)aBound4 trajectoryLine:(struct CGELine)aLine options:(id)aOptions;
@end

@interface BTPointToPointSnapSource : BTPointSnapSource <BTPointToPointReflecting>
{
    CGAffineTransform _reflectingTransform;
}
+ (id)sourceWithPoint:(CGPoint)aPoint minXBound:(CGFloat)aBound maxXBound:(CGFloat)aBound2 minYBound:(CGFloat)aBound3 maxYBound:(CGFloat)aBound4 trajectoryLine:(struct CGELine)aLine options:(id)aOptions reflectingTransform:(CGAffineTransform)aTransform;
- (id)BTPointSnapSource_protected_membersDescription;
- (CGPoint)reflectedPointForPoint:(CGPoint)aPoint;
- (id)initWithPoint:(CGPoint)aPoint minXBound:(CGFloat)aBound maxXBound:(CGFloat)aBound2 minYBound:(CGFloat)aBound3 maxYBound:(CGFloat)aBound4 trajectoryLine:(struct CGELine)aLine options:(id)aOptions reflectingTransform:(CGAffineTransform)aTransform;
- (id)initWithPoint:(CGPoint)aPoint minXBound:(CGFloat)aBound maxXBound:(CGFloat)aBound2 minYBound:(CGFloat)aBound3 maxYBound:(CGFloat)aBound4 trajectoryLine:(struct CGELine)aLine options:(id)aOptions;
@end

