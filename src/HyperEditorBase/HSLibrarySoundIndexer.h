#import "HyperEditorBasePrefix.h"


@interface HSLibrarySoundIndexer : NSObject
{
    NSMutableDictionary *_soundPathToDurationMap;
    BOOL _hasChanges;
}
+ (id)allocWithZone:(NSZone *)aZone;
+ (id)sharedLibrarySoundIndexing;
- (void)synchronize;
- (void)setDuration:(id)aDuration forLibrarySoundAtPath:(id)aPath;
- (id)durationForLibrarySoundAtPath:(id)aPath;
- (id)init;
- (void)dealloc;
- (id)autorelease;
- (void)release;
- (NSUInteger)retainCount;
- (id)retain;
- (id)copyWithZone:(NSZone *)aZone;
@end

