#import "HyperStudioPrefix.h"
#import "HSPickMovieSourceAssistantPane.h"


@interface HSRootPickMovieSourceAssistantPane : HSPickMovieSourceAssistantPane
{
    HSPlayMovieActionAssistantPane *_playMovieActionAssistantPane;
    id<HSPlayMovieActionAttributes> _playMovieActionAttributes;
}
- (void)dismissPaneIfNeeded;
- (void)processLiveObject:(id)aObject;
- (void)processMovieObject:(id)aObject isInUse:(BOOL)aUse;
- (void)openPlayMovieActionAssistantPane;
- (id)playMovieActionAssistantPane;
- (void)dealloc;
@end

