#import "HyperStudioPrefix.h"


@interface HSSegmentView : NSView
{
    HSSegmentAttributesView *_attributesView;
    HSSegmentBodyView *_bodyView;
    HSSegmentRulerView *_rulerView;
    id _dataSource;
    id _delegate;
    NSRange _selectedSegments;
    float _scale;
    double _primaryInterval;
    unsigned int _secondaryCount;
    double _firstPrimaryValue;
    float _initialWidth;
}
+ (CGFloat)minSegmentDuration;
- (void)stopBodyEditing;
- (void)continueBodyEditing;
- (void)startBodyEditing;
- (void)stopChangingCurrentValue:(CGFloat)aValue;
- (void)continueChangingCurrentValue:(CGFloat)aValue;
- (void)startChangingCurrentValue:(CGFloat)aValue;
- (void)setValueScaleSliderEnabled:(BOOL)aEnabled;
- (void)onChangeValueScale:(id)aScale;
- (void)prepareValueScaleSlider;
- (void)onMinus:(id)aMinus;
- (void)onPlus:(id)aPlus;
- (void)setupViewFrame;
- (void)setupRuler;
- (void)refreshCurrentValue;
- (void)refresh;
- (NSInteger)segmentAtX:(CGFloat)aX;
- (NSInteger)pegIndexAtValue:(double)aValue;
- (CGFloat)xForValue:(double)aValue;
- (double)valueForX:(CGFloat)aX;
- (double)firstPrimaryValue;
- (NSUInteger)secondaryCount;
- (double)primaryInterval;
- (void)setScale:(CGFloat)aScale;
- (CGFloat)scale;
- (void)setSelectedSegments:(NSRange)aSegments;
- (NSRange)selectedSegments;
- (void)setCurrentValue:(double)aValue;
- (double)currentValue;
- (double)totalDuration;
- (void)setPegValue:(double)aValue atIndex:(NSUInteger)aIndex;
- (double)pegValueAtIndex:(NSUInteger)aIndex;
- (NSUInteger)pegCount;
- (void)setStartValue:(double)aValue;
- (double)startValue;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)setDataSource:(id)aSource;
- (id)dataSource;
- (id)initWithFrame:(NSRect)aFrame;
@end

