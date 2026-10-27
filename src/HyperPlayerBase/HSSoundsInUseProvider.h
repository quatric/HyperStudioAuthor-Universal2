#import "HyperPlayerBasePrefix.h"


@interface HSSoundsInUseProvider : NSObject
{
}
+ (id)soundsInUseWithMediaUID:(id)aUID forStack:(id)aStack;
+ (id)soundsInUseForStack:(id)aStack;
+ (id)playSoundActionsInUseForStack:(id)aStack;
@end

