#import "HyperStudioPrefix.h"
#import "HSCommentsTextView.h"


@interface HSLiveObjectAppearanceAssistantPane : HSObjectAssistantPane
{
    NSTextField *_nameTextField;
    NSButton *_playButton;
    NSPopUpButton *_cameraListPopUp;
    NSView *_groupView;
    NSButton *_shadowSwitch;
    NSButton *_shadowButton;
    NSSlider *_opacitySlider;
    NSTextField *_opacityTextField;
    NSStepper *_opacityStepper;
    NSButton *_mirrorSwitch;
    NSImage *_playImage;
    NSImage *_stopImage;
    NSImage *_pressedPlayImage;
    NSImage *_pressedStopImage;
    HSCaptureDeviceList *_captureDeviceList;
    QTCaptureDevice *_selectedCaptureDevice;
}
- (void)setOriginalObjectOpacity:(CGFloat)aOpacity;
- (void)updateOpacity:(CGFloat)aOpacity;
- (void)updateMirror;
- (void)updateShadow;
- (void)validateUI;
- (void)validateMirrorWithNotification:(id)aNotification;
- (void)validateOpacityAttributesWithNotification:(id)aNotification;
- (void)validateShadowAttributesWithNotification:(id)aNotification;
- (void)validateUIWithNotification:(id)aNotification;
- (void)observeValueForKeyPath:(id)aPath ofObject:(id)aObject change:(id)aChange context:(void *)aContext;
- (void)HSLiveObjectAppearanceAssistantPane_captureDeviceDidChangeState:(id)aState;
- (void)setMirror:(id)aMirror;
- (void)opacityChanged:(id)aChanged;
- (void)editShadow:(id)aShadow;
- (void)setShadow:(id)aShadow;
- (void)showShadowPane;
- (void)playInEditor:(id)aEditor;
- (void)cameraListChanged:(id)aChanged;
- (void)setName:(id)aName;
- (void)setUpStopButton;
- (void)setUpPlayButton;
- (void)HSLiveObjectAppearanceAssistantPane_captureDeviceListDidUpdate:(id)aUpdate;
- (id)opacityAttributes;
- (id)geometryAttributes;
- (id)shadowAttributes;
- (id)playableObjectAttributes;
- (id)liveObjectAttributes;
- (id)nameTextfField;
- (id)initialKeyView;
- (BOOL)isEditingTextAttribute;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)dealloc;
- (void)viewDidLoad;
- (id)init;
- (void)HSLiveObjectAppearanceAssistantPane_cameraListPopUpDidUpdate;
- (void)HSLiveObjectAppearanceAssistantPane_updateSelectedCaptureDevice:(id)aDevice;
@end

