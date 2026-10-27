#import "HyperPlayerBasePrefix.h"


@interface HSSystemUI : NSObject
{
    unsigned int _oldUIMode;
    unsigned int _oldUIOptions;
    BOOL _isUIModeSet;
}
+ (id)allocWithZone:(NSZone *)aZone;
+ (id)sharedSystemUI;
- (BOOL)menuBarVisible;
- (void)revertChanges;
- (void)setupWithMode:(NSUInteger)aMode options:(NSUInteger)aOptions;
- (void)dealloc;
- (id)autorelease;
- (void)release;
- (NSUInteger)retainCount;
- (id)retain;
- (id)copyWithZone:(NSZone *)aZone;
@end

