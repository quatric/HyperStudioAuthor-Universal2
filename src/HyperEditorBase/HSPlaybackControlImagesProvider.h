#import "HyperEditorBasePrefix.h"


@interface HSPlaybackControlImagesProvider : NSObject
{
    NSMutableDictionary *_imagesCache;
}
+ (id)allocWithZone:(NSZone *)aZone;
+ (id)sharedPlaybackControlsImagesProvider;
- (id)playbackImageOfType:(id)aType state:(id)aState size:(id)aSize tint:(id)aTint;
- (id)imagesCache;
- (id)autorelease;
- (void)release;
- (NSUInteger)retainCount;
- (id)retain;
- (id)copyWithZone:(NSZone *)aZone;
@end

