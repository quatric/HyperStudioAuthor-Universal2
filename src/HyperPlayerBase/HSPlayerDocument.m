#import "HSPlayerDocument.h"
// A stack opened in the player.
@implementation HSPlayerDocument
- (void)loadCardPreviewImagesWrapper:(id)aWrapper
{
}
- (id)cardPreviewImagesWrapper
{
    return nil;
}
// Execution contexts start active in the player.
- (id)newActionExecutionContext
{
    id context = [super newActionExecutionContext];
    [context activate];
    return context;
}
// Revert only for edited native documents outside animation/presentation
// mode. Save is allowed when the document allows it, or for a native document
// whose ".stack" twin doesn't exist yet.
- (BOOL)validateUserInterfaceItem:(id)aItem
{
    BOOL valid = [super validateUserInterfaceItem:aItem];
    SEL action = [(id<NSValidatedUserInterfaceItem>)aItem action];
    BOOL animating = NO;
    if (action == @selector(revertDocumentToSaved:)) {
        if (animating || !valid || [self isInPresentationMode] || ![self isDocumentEdited])
            return NO;
        return [[self fileType] isEqualToString:@"HSAiBADocumentType"];
    }
    if (action != @selector(saveDocument:))
        return valid;
    if (valid)
        return YES;
    if (![[self fileType] isEqualToString:@"HSNativeDocumentType"])
        return NO;
    NSString *stackPath = [[[[self fileURL] path] stringByDeletingPathExtension] stringByAppendingPathExtension:@"stack"];
    return ![[NSFileManager defaultManager] fileExistsAtPath:stackPath];
}
- (void)setPlayerView:(id)aView
{
    if (_playerView != aView) {
        [_playerView release];
        _playerView = [aView retain];
    }
}
- (id)playerView
{
    if (_playerView == nil)
        [self setPlayerView:[[self mainWindowController] playerView]];
    return _playerView;
}
// A page setup change doesn't make the player's document edited (2 is
// NSChangeCleared, as in the original).
- (void)setPrintInfo:(id)aInfo
{
    [super setPrintInfo:aInfo];
    [self updateChangeCount:NSChangeCleared];
}
- (Class)navigationControllerClass
{
    return [HSPlayerNavigationController class];
}
- (Class)mainWindowControllerClass
{
    return [HSPlayerWindowController class];
}
- (void)dealloc
{
    [self destoryModelIfNeeded];
    [_playerView release];
    [super dealloc];
}
@end
