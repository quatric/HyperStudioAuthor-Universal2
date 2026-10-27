#import "HyperStudioPrefix.h"


@interface HSControlWebCamView : HSControlObjectView
{
    id<HSRenderer> _renderer;
    NSButtonCell *_buttonCell;
    NSRect _buttonRect;
    NSImage *_previewImage;
    BOOL _isEnabled;
    BOOL _isPlaying;
    BOOL _isPreviewChanged;
    id<HSControlWebCamViewDelegateProtocol> _webCamViewDelegate;
}
- (void)mouseDragged:(id)aDragged;
- (void)mouseDown:(id)aDown;
- (BOOL)trackButtonCell:(id)aCell inRect:(NSRect)aRect withEvent:(id)aEvent;
- (void)drawQuartzRect:(NSRect)aRect;
- (id)objectImage;
- (BOOL)isOpaque;
- (BOOL)isFlipped;
- (void)videoStreamDidChange:(id)aChange;
- (void)unsubscribeFromNotifications;
- (void)subscribeToNotifications;
- (void)initializeRenderNode:(id)aNode;
- (id)renderer;
- (NSRect)buttonRect;
- (id)buttonCell;
- (id)webCamViewDelegate;
- (void)setWebCamViewDelegate:(id)aDelegate;
- (void)stopPlaying;
- (void)startPlaying;
- (BOOL)isPlaying;
- (void)setEnabled:(BOOL)aEnabled;
- (BOOL)isEnabled;
- (void)togglePlay:(id)aPlay;
- (void)setIdentifier:(id)aIdentifier;
- (id)identifier;
- (void)setURL:(id)aURL;
- (id)URL;
- (void)setPreviewImage:(id)aImage;
- (id)previewImage;
- (id)objectClassName;
- (void)dealloc;
@end

