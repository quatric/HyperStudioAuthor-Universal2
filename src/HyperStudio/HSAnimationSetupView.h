#import "HyperStudioPrefix.h"
#import "HSSegmentView.h"


@interface HSAnimationSetupView : HSSegmentView
{
    SMKStringRenderer *_stringRenderer;
    NSString *_emptyAnimationMessage;
    int _lastPegCount;
}
+ (CGFloat)minSegmentDuration;
- (void)stopBodyEditing;
- (void)continueBodyEditing;
- (void)startBodyEditing;
- (void)stopChangingCurrentValue:(CGFloat)aValue;
- (void)continueChangingCurrentValue:(CGFloat)aValue;
- (void)startChangingCurrentValue:(CGFloat)aValue;
- (void)refresh;
- (void)drawRect:(NSRect)aRect;
- (void)enclosingScrollViewDidChangeFrame:(id)aFrame;
- (void)awakeFromNib;
- (void)dealloc;
- (id)initWithFrame:(NSRect)aFrame;
@end

