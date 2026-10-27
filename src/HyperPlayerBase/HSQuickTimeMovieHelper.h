#import "HyperPlayerBasePrefix.h"


@interface HSQuickTimeMovieHelper : NSObject
{
}
+ (NSInteger)convertMovie:(id)aMovie frameSize:(NSSize)aSize ofType:(NSInteger)aType toFile:(id)aFile progressCallback:(void *)aCallback sender:(id)aSender;
+ (NSInteger)addArtworkImage:(id)aImage inMovie:(id)aMovie ofType:(NSInteger)aType;
@end

