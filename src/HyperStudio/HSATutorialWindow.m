#import "HSATutorialWindow.h"

@implementation HSATutorialWindow

- (BOOL)canBecomeMainWindow
{
    return NO;
}

// The tutorial window never takes the key view itself: commands go to the document's responder chain.
- (id)nextResponder
{
    return [[[[[HSEditorController sharedDocumentController] currentDocument] currentWindowController] window] firstResponder];
}

- (void)setWindowController:(id)aController
{
    [self setNextResponder:aController];
    [super setWindowController:aController];
}

- (id)supplementalTargetForAction:(SEL)aAction sender:(id)aSender
{
    if (aAction == @selector(zoomIn:) || aAction == @selector(zoomOut:) || aAction == @selector(zoomToActualSize:)) {
        return [self windowController];
    }
    return [super supplementalTargetForAction:aAction sender:aSender];
}

@end
