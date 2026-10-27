#import "HyperPlayerBasePrefix.h"
#import "HSAbstractChecker.h"


@interface HSDisplayChecker : HSAbstractChecker
{
    BOOL _isBlocked;
    HSDisplayCheckerAlert *_alert;
    float _currentHeight;
    float _currentWidth;
    int _currentBitsPerPixel;
    float _minHeight;
    float _minWidth;
    int _minBitsPerPixel;
}
- (void)setMinBitsPerPixel:(NSInteger)aPixel;
- (NSInteger)minBitsPerPixel;
- (void)setMinWidth:(NSInteger)aWidth;
- (NSInteger)minWidth;
- (void)setMinHeight:(NSInteger)aHeight;
- (NSInteger)minHeight;
- (void)dealloc;
- (void)synhronise;
- (void)screenParametersDidChange:(id)aChange;
- (void)checkMinSpec;
- (id)init;
@end

