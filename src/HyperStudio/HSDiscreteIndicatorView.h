#import "HyperStudioPrefix.h"


@interface HSDiscreteIndicatorView : NSView
{
    float _minValue;
    float _maxValue;
    float _warningValue;
    float _criticalValue;
    float _value;
    float _spaceSizeBetweenIndicatorSegments;
    BOOL _isVertical;
}
+ (NSSize)minSize;
+ (id)imageNamed:(id)aNamed;
+ (id)sharedImages;
- (id)imageNamed:(id)aNamed;
- (NSRect)segmentFrameAtIndex:(NSInteger)aIndex inFrame:(NSRect)aFrame;
- (void)drawSegmentInFrame:(NSRect)aFrame withState:(NSInteger)aState;
- (void)drawIndicatorInFrame:(NSRect)aFrame;
- (void)sizeToFit;
- (BOOL)isVerticalDirection;
- (void)setVerticalDirection:(BOOL)aDirection;
- (void)setCriticalValue:(CGFloat)aValue;
- (CGFloat)criticalValue;
- (void)setWarningValue:(CGFloat)aValue;
- (CGFloat)warningValue;
- (CGFloat)value;
- (void)setValue:(CGFloat)aValue;
- (CGFloat)maxValue;
- (void)setMaxValue:(CGFloat)aValue;
- (void)setMinValue:(CGFloat)aValue;
- (CGFloat)minValue;
- (void)drawRect:(NSRect)aRect;
- (BOOL)isFlipped;
- (void)dealloc;
- (id)initWithFrame:(NSRect)aFrame;
@end

