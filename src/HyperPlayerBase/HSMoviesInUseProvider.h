#import "HyperPlayerBasePrefix.h"


@interface HSMoviesInUseProvider : NSObject
{
}
+ (id)moviesInUseForStack:(id)aStack;
+ (id)playMovieObjectsInStack:(id)aStack;
+ (id)playMovieActionsInUseForStack:(id)aStack;
+ (id)mergePlayableObjects:(id)aObjects withPlayableObjects:(id)aObjects2;
+ (id)availableObjectsInStack:(id)aStack forProtocol:(id)aProtocol;
+ (id)availableMovieObjectsForPlayMovieAction:(id)aAction;
@end

