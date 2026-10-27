#import "HyperStudioPrefix.h"


@interface HSStopWatchView : NSView
{
    float _seconds;
    NSImage *_backgroundClockImage;
    NSImage *_colonClockImage;
    NSSize _digitImageSize;
    NSString *_accessibilityRoleDescriptionString;
}
+ (NSSize)stopWatchViewSize;
- (id)accessibilityFocusedUIElement;
- (BOOL)accessibilityIsIgnored;
- (BOOL)accessibilityIsAttributeSettable:(id)aSettable;
- (id)accessibilityAttributeNames;
- (id)accessibilityHitTest:(NSPoint)aTest;
- (id)accessibilityAttributeValue:(id)aValue;
- (id)accessibilityRoleDescriptionString;
- (void)setAccessibilityRoleDescriptionString:(id)aString;
- (void)sizeToFit;
- (id)digitImageNameAtIndex:(NSUInteger)aIndex;
- (NSUInteger)lowDigitOfSeconds;
- (NSUInteger)highDigitOfSeconds;
- (NSUInteger)lowDigitOfMinutes;
- (NSUInteger)highDigitOfMinutes;
- (NSUInteger)minutesForDigit;
- (NSUInteger)secondsForDigit;
- (CGFloat)clockTimeInSeconds;
- (void)setClockTimeInSeconds:(CGFloat)aSeconds;
- (void)drawDigitWithName:(id)aName toPoint:(NSPoint)aPoint;
- (void)drawRect:(NSRect)aRect;
- (void)dealloc;
- (id)initWithFrame:(NSRect)aFrame;
- (BOOL)isFlipped;
@end

