#import "HyperStudioPrefix.h"


@interface HSStoryboardImageLoader : NSObject
{
    BOOL _running;
    id _delegate;
}
- (void)cancelAllRequests;
- (void)validateInvalidItems;
- (void)loadQueuedImages:(id)aImages;
- (id)delegate;
- (void)setDelegate:(id)aDelegate;
- (id)initWithDelegate:(id)aDelegate;
- (void)dealloc;
@end

