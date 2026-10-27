#import "HyperPlayerBasePrefix.h"
#import "HSNewMediaAccessor.h"


@interface HSMediaSaver : NSObject
{
}
+ (id)pathToFlattenMediaForData:(id)aData;
+ (id)pathToFlattenMediaAtPath:(id)aPath;
+ (struct MovieType **)movieAtPath:(id)aPath;
+ (BOOL)saveMediaForDocument:(id)aDocument resourcesWrapper:(id)aWrapper;
@end

@interface HSNewMediaAccessor (OldFormatEx)
- (void)resetAllStorageRetains;
@end

