#import "HyperEditorBasePrefix.h"


@interface HSMediaPlaySynchronizer : NSObject
{
    NSMutableArray *_playingSounds;
}
+ (id)allocWithZone:(NSZone *)aZone;
+ (id)sharedSynchronizer;
- (void)movieDidEnd:(id)aEnd;
- (void)stopAllMedia;
- (void)playMediaSingle:(id)aSingle;
- (void)playMedia:(id)aMedia;
- (void)dealloc;
- (id)init;
- (id)autorelease;
- (void)release;
- (NSUInteger)retainCount;
- (id)retain;
- (id)copyWithZone:(NSZone *)aZone;
@end

