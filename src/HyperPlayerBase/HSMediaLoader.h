#import "HyperPlayerBasePrefix.h"


@interface HSMediaLoader : NSObject
{
}
+ (id)forceLoadMediasFromPasteboard:(id)aPasteboard;
+ (id)loadResourcesWrapper:(id)aWrapper resourcesFolderPath:(id)aPath;
+ (id)loadResourcesWrapper:(id)aWrapper resourcesFolderPath:(id)aPath loadUIDs:(BOOL)aDs;
+ (id)loadResourcesWrapper:(id)aWrapper resourcesFolderPath:(id)aPath loadUIDs:(BOOL)aDs filenamesMapping:(id)aMapping;
+ (id)dataFromFileWrapper:(id)aWrapper;
@end

