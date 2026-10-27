#import "HSRootPickMovieSourceAssistantPane.h"

@implementation HSRootPickMovieSourceAssistantPane

- (void)dismissPaneIfNeeded
{
}

- (void)processLiveObject:(id)aObject
{
    [self openPlayMovieActionAssistantPane];
    [[self playMovieActionAssistantPane] addTemporaryLiveObject:aObject];
    if ([[aObject queryHyperInterface:@protocol(HSNodeChild)] hyperParent] == nil)
        [[self playMovieActionAssistantPane] choosePositionForTemporaryAddedObject];
}

- (void)processMovieObject:(id)aObject isInUse:(BOOL)aUse
{
    [self openPlayMovieActionAssistantPane];
    [[self playMovieActionAssistantPane] addTemporaryMovieObject:aObject isInUse:aUse];
    if ([[aObject queryHyperInterface:@protocol(HSNodeChild)] hyperParent] == nil)
        [[self playMovieActionAssistantPane] choosePositionForTemporaryAddedObject];
}

- (void)openPlayMovieActionAssistantPane
{
    id pane = [self playMovieActionAssistantPane];
    id navigationController;

    [pane setActionEvent:[self actionEvent]];
    navigationController = [self objectAssistantNavigationController];
    if ([navigationController topViewController] == self)
        [navigationController changeIdentifierForViewController:self toIdentifier:HSPickMovieSourcePane_RemoveIfOkIdentifier];
    [navigationController pushViewController:pane withIdentifier:HSPlayMovieActionPane_RemoveIfCancelIdentifier animate:NO replacePrevious:NO];
    [_playMovieActionAttributes release];
    _playMovieActionAttributes = [[pane actionAttributes] retain];
}

- (id)playMovieActionAssistantPane
{
    if (_playMovieActionAssistantPane == nil)
        _playMovieActionAssistantPane = [HSPlayMovieActionAssistantPane new];
    return _playMovieActionAssistantPane;
}

- (void)dealloc
{
    [_playMovieActionAssistantPane release];
    [_playMovieActionAttributes release];
    [super dealloc];
}

@end
