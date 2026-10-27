#import "HyperStudioPrefix.h"
#import "HSCommentsTextView.h"


@interface HSGraphicObjectsAssistantPane : HSObjectAssistantPane
{
    HSImportDialogController *_importGraphicDialogController;
}
- (id)mediaAttributes;
- (id)document;
- (void)runCropDialogButtonClicked:(id)aClicked;
- (void)scaleToFitCardButtonClicked:(id)aClicked;
- (void)scaleToFillCardButtonClicked:(id)aClicked;
- (void)flattenToBackgroundButtonClicked:(id)aClicked;
- (void)chooseAnotherPicture:(id)aPicture;
- (void)scaleAndRotateButtonClicked:(id)aClicked;
- (void)setSettingsForGraphicImportDialogController:(id)aController;
- (id)selectionToolTolerance;
- (void)dealloc;
- (id)init;
- (void)imageCaptureDialogDidEnd:(id)aDialog returnedCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)cropImageDialogDidEnd:(id)aDialog returnedCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)anotherImageObjectWithMedia:(id)aMedia;
- (void)importDialogDidEnd:(id)aDialog returnedCode:(NSInteger)aCode contextInfo:(void *)aInfo;
@end

