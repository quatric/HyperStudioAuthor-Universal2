#import "BTSizeToPointSnapSource.h"

// What the tools snap: a size being dragged (with the point it puts the
// dragged handle at) or a point (with the point reflected from it).

static NSString *LineDescription(struct CGELine line)
{
    return [NSString stringWithFormat:@"(%fx %c %fy %c %f == 0)", line.a, line.b < 0 ? '-' : '+', fabs(line.b),
                                      line.c < 0 ? '-' : '+', fabs(line.c)];
}

static NSString *TransformDescription(CGAffineTransform t)
{
    return [NSString stringWithFormat:@"{%f, %f, %f, %f, %f, %f}", t.a, t.b, t.c, t.d, t.tx, t.ty];
}

@implementation BTSizeSnapSource

- (id)initWithSize:(CGSize)aSize minSize:(CGSize)aSize2 maxSize:(CGSize)aSize3 proportionFactor:(CGFloat)aFactor showTransform:(CGAffineTransform)aTransform options:(id)aOptions
{
    self = [super init];
    if (!self)
        return nil;
    if (aOptions) {
        _options = [aOptions copy];
        if (!_options) {
            [self release];
            return nil;
        }
    }
    _size = aSize;
    _minSize = aSize2;
    _maxSize = aSize3;
    _proportionFactor = aFactor;
    _showTransform = aTransform;
    return self;
}

- (void)dealloc
{
    [_options release];
    [super dealloc];
}

- (CGSize)size
{
    return _size;
}

- (CGSize)minSize
{
    return _minSize;
}

- (CGSize)maxSize
{
    return _maxSize;
}

- (CGFloat)proportionFactor
{
    return _proportionFactor;
}

- (CGAffineTransform)showTransform
{
    return _showTransform;
}

- (id)options
{
    return _options;
}

- (id)BTSizeSnapSource_protected_membersDescription
{
    return [NSString stringWithFormat:@"size = {%f, %f}; min size = {%f, %f}; max size = {%f, %f}; proportion factor = %f; "
                                      @"show transform = %@; options = %@",
                                      _size.width, _size.height, _minSize.width, _minSize.height, _maxSize.width,
                                      _maxSize.height, _proportionFactor, TransformDescription(_showTransform), _options];
}

- (id)description
{
    return [NSString stringWithFormat:@"<%@: %p> {%@}", NSStringFromClass([self class]), self,
                                      [self BTSizeSnapSource_protected_membersDescription]];
}

@end

@implementation BTSizeToPointSnapSource

+ (id)sourceWithSize:(CGSize)aSize minSize:(CGSize)aSize2 maxSize:(CGSize)aSize3 proportionFactor:(CGFloat)aFactor showTransform:(CGAffineTransform)aTransform options:(id)aOptions basePoint:(CGPoint)aPoint resizingCenter:(CGPoint)aCenter reflectingTransform:(CGAffineTransform)aTransform2
{
    return [[[[self class] alloc] initWithSize:aSize minSize:aSize2 maxSize:aSize3 proportionFactor:aFactor
                                 showTransform:aTransform options:aOptions basePoint:aPoint resizingCenter:aCenter
                           reflectingTransform:aTransform2] autorelease];
}

- (id)initWithSize:(CGSize)aSize minSize:(CGSize)aSize2 maxSize:(CGSize)aSize3 proportionFactor:(CGFloat)aFactor showTransform:(CGAffineTransform)aTransform options:(id)aOptions
{
    [self release];
    return nil;
}

- (id)initWithSize:(CGSize)aSize minSize:(CGSize)aSize2 maxSize:(CGSize)aSize3 proportionFactor:(CGFloat)aFactor showTransform:(CGAffineTransform)aTransform options:(id)aOptions basePoint:(CGPoint)aPoint resizingCenter:(CGPoint)aCenter reflectingTransform:(CGAffineTransform)aTransform2
{
    self = [super initWithSize:aSize minSize:aSize2 maxSize:aSize3 proportionFactor:aFactor showTransform:aTransform
                       options:aOptions];
    if (!self)
        return nil;
    _basePoint = aPoint;
    _resizingCenter = aCenter;
    _reflectingTransform = aTransform2;
    return self;
}

- (id)BTSizeSnapSource_protected_membersDescription
{
    return [NSString stringWithFormat:@"%@; base point = {%f, %f}; resizing center = {%f, %f}; reflecting transform = %@",
                                      [super BTSizeSnapSource_protected_membersDescription], _basePoint.x, _basePoint.y,
                                      _resizingCenter.x, _resizingCenter.y, TransformDescription(_reflectingTransform)];
}

// The base point scaled about the resizing center by the new size over the
// source size (1 for an empty dimension), through the reflecting transform.
- (CGPoint)reflectedPointForSize:(CGSize)aSize
{
    CGSize size = [self size];
    CGFloat sx = size.width != 0 ? aSize.width / size.width : 1.0;
    CGFloat sy = size.height != 0 ? aSize.height / size.height : 1.0;
    CGPoint point = CGPointMake(sx * _basePoint.x + (1.0 - sx) * _resizingCenter.x,
                                sy * _basePoint.y + (1.0 - sy) * _resizingCenter.y);
    return CGPointApplyAffineTransform(point, _reflectingTransform);
}

@end

@implementation BTPointSnapSource

- (id)initWithPoint:(CGPoint)aPoint minXBound:(CGFloat)aBound maxXBound:(CGFloat)aBound2 minYBound:(CGFloat)aBound3 maxYBound:(CGFloat)aBound4 trajectoryLine:(struct CGELine)aLine options:(id)aOptions
{
    self = [super init];
    if (!self)
        return nil;
    if (aOptions) {
        _options = [aOptions copy];
        if (!_options) {
            [self release];
            return nil;
        }
    }
    _point = aPoint;
    _minXBound = aBound;
    _maxXBound = aBound2;
    _minYBound = aBound3;
    _maxYBound = aBound4;
    _trajectoryLine = aLine;
    return self;
}

- (void)dealloc
{
    [_options release];
    [super dealloc];
}

- (CGPoint)point
{
    return _point;
}

- (CGFloat)minXBound
{
    return _minXBound;
}

- (CGFloat)maxXBound
{
    return _maxXBound;
}

- (CGFloat)minYBound
{
    return _minYBound;
}

- (CGFloat)maxYBound
{
    return _maxYBound;
}

- (struct CGELine)trajectoryLine
{
    return _trajectoryLine;
}

- (id)options
{
    return _options;
}

- (id)BTPointSnapSource_protected_membersDescription
{
    return [NSString stringWithFormat:@"point = {%f, %f}; minXBound = %f; maxXBound = %f; minYBound = %f; maxYBound = %f; "
                                      @"trajectory = %@; options = %@",
                                      _point.x, _point.y, _minXBound, _maxXBound, _minYBound, _maxYBound,
                                      LineDescription(_trajectoryLine), _options];
}

- (id)description
{
    return [NSString stringWithFormat:@"<%@: %p> {%@}", NSStringFromClass([self class]), self,
                                      [self BTPointSnapSource_protected_membersDescription]];
}

@end

@implementation BTPointToPointSnapSource

+ (id)sourceWithPoint:(CGPoint)aPoint minXBound:(CGFloat)aBound maxXBound:(CGFloat)aBound2 minYBound:(CGFloat)aBound3 maxYBound:(CGFloat)aBound4 trajectoryLine:(struct CGELine)aLine options:(id)aOptions reflectingTransform:(CGAffineTransform)aTransform
{
    return [[[[self class] alloc] initWithPoint:aPoint minXBound:aBound maxXBound:aBound2 minYBound:aBound3
                                      maxYBound:aBound4 trajectoryLine:aLine options:aOptions
                            reflectingTransform:aTransform] autorelease];
}

- (id)initWithPoint:(CGPoint)aPoint minXBound:(CGFloat)aBound maxXBound:(CGFloat)aBound2 minYBound:(CGFloat)aBound3 maxYBound:(CGFloat)aBound4 trajectoryLine:(struct CGELine)aLine options:(id)aOptions
{
    return [self initWithPoint:aPoint minXBound:aBound maxXBound:aBound2 minYBound:aBound3 maxYBound:aBound4
                trajectoryLine:aLine options:aOptions reflectingTransform:CGAffineTransformIdentity];
}

- (id)initWithPoint:(CGPoint)aPoint minXBound:(CGFloat)aBound maxXBound:(CGFloat)aBound2 minYBound:(CGFloat)aBound3 maxYBound:(CGFloat)aBound4 trajectoryLine:(struct CGELine)aLine options:(id)aOptions reflectingTransform:(CGAffineTransform)aTransform
{
    self = [super initWithPoint:aPoint minXBound:aBound maxXBound:aBound2 minYBound:aBound3 maxYBound:aBound4
                 trajectoryLine:aLine options:aOptions];
    if (!self)
        return nil;
    _reflectingTransform = aTransform;
    return self;
}

- (id)BTPointSnapSource_protected_membersDescription
{
    return [NSString stringWithFormat:@"%@; reflecting transform = %@", [super BTPointSnapSource_protected_membersDescription],
                                      TransformDescription(_reflectingTransform)];
}

- (CGPoint)reflectedPointForPoint:(CGPoint)aPoint
{
    return CGPointApplyAffineTransform(aPoint, _reflectingTransform);
}

@end
