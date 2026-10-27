#import "HyperStudioPrefix.h"
#import "HSDiskPublisher.h"


@interface HSiBooksAuthorPublisher : HSDiskPublisher
{
    HSiBooksAuthorFinishWindowController *_windowController;
}
- (id)finishWindow;
- (void)dealloc;
@end

