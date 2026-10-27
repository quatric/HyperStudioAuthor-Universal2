#import "HyperPlayerBasePrefix.h"


@interface HSStreamRenderer : NSObject
{
    id _delegate;
    BOOL _isEnabled;
}
+ (void)initialize;
- (void)setEnabled:(BOOL)aEnabled;
- (BOOL)isEnabled;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
@end

