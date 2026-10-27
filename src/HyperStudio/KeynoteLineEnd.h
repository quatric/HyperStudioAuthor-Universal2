#import "HyperStudioPrefix.h"
#import "KeynoteObject.h"


@interface KeynoteLineEnd : KeynoteObject
{
    BOOL _isCalculated;
    BOOL _isFilled;
    NSBezierPath *_bezierPath;
    NSPoint _endPoint;
}
- (void)setEndPoint:(NSPoint)aPoint;
- (NSPoint)endPoint;
- (void)setBezierPath:(id)aPath;
- (id)bezierPath;
- (void)setIsFilled:(BOOL)aFilled;
- (BOOL)isFilled;
- (void)dealloc;
- (void)calculate;
@end

