#import "HyperStudioPrefix.h"


@interface HSStackBackgroundImageController : NSObject <HSStackBackgroundController, NSObject>
{
    NSView *_controlledView;
    NSButton *_changeImageButton;
    NSPopUpButton *_fillImageStylePopUpButton;
    NSImageView *_imageFillPreview;
    HSPresentationAssistantPaneApplier *_applier;
    BOOL _didInitOnce;
}
- (void)setImageFromPasteboard:(id)aPasteboard;
- (void)hyperImageView:(id)aView didAcceptedDropWithDraggingInfo:(id)aInfo;
- (void)hyperImageViewDidPasted:(id)aPasted;
- (void)chooseBackgroundImage:(id)aImage;
- (void)changeImagePreview:(id)aPreview;
- (void)chooseBackgroundFillStyle:(id)aStyle;
- (void)setShouldActivateColorWellOnMount:(BOOL)aMount;
- (BOOL)deactivatedColorWellOnUnmount;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)validateUIElements;
- (void)apply;
- (void)setApplier:(id)aApplier;
- (id)contentView;
- (void)awakeFromNib;
- (void)dealloc;
@end

