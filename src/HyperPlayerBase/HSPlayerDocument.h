#import "HyperPlayerBasePrefix.h"
#import "HSDocumentStoring.h"


@interface HSPlayerDocument : HSDocumentStoring
{
    HSPlayerView *_playerView;
}
- (void)loadCardPreviewImagesWrapper:(id)aWrapper;
- (id)cardPreviewImagesWrapper;
- (id)newActionExecutionContext;
- (BOOL)validateUserInterfaceItem:(id)aItem;
- (void)setPlayerView:(id)aView;
- (id)playerView;
- (void)setPrintInfo:(id)aInfo;
- (Class)navigationControllerClass;
- (Class)mainWindowControllerClass;
- (void)dealloc;
@end

