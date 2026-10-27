#import "HyperStudioPrefix.h"
#import "HSAssistantPaneApplier.h"
#import "HSCommentsTextView.h"


@interface HSTransparentColorAssistantPane : HSObjectAssistantPaneWithApplier <HSTransparentColorAssistantPaneApplierDelegate>
{
    NSColorWell *_transparentColorWell;
    NSButton *_transparentColorPicker;
    NSTextField *_sensitivityLabel;
    HSBlueTriangleSlider *_hueSensitivitySlider;
    HSBlueTriangleSlider *_chromaSensitivitySlider;
    HSBlueTriangleSlider *_lightnessSensitivitySlider;
    HSCheckBox *_linkSlidersSwitch;
    HSObjectAssistantNavigationPaneSwitcher *_paneSwitcher;
    id<HSTransparentColorAttributes> _transparentColorAttributes;
    BOOL _needRemoveObserving;
    unsigned int _isTransparentColorBeingUndoneOrRedone:1;
    unsigned int _isTransparentColorHueToleranceBeingUndoneOrRedone:1;
    unsigned int _isTransparentColorChromaToleranceBeingUndoneOrRedone:1;
    unsigned int _isTransparentColorLightnessToleranceBeingUndoneOrRedone:1;
}
- (void)paneDidOK:(id)aOK;
- (void)activateColorPickingMode:(id)aMode;
- (void)changeLightnessSensitivity:(id)aSensitivity;
- (void)changeChromaSensitivity:(id)aSensitivity;
- (void)changeHueSensitivity:(id)aSensitivity;
- (void)changeTransparentColor:(id)aColor;
- (void)colorPickingDidFinishWithColor:(id)aColor;
- (void)HSTransparentColorAssistantPane_objectsWillChange:(id)aChange;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)transparentColorAttributes;
- (void)awakeFromNib;
- (void)HSTransparentColorAssistantPane_transparentColorLightnessToleranceWasUndoneOrRedone:(id)aRedone;
- (void)HSTransparentColorAssistantPane_transparentColorLightnessToleranceWillBeUndoneOrRedone:(id)aRedone;
- (void)HSTransparentColorAssistantPane_transparentColorChromaToleranceWasUndoneOrRedone:(id)aRedone;
- (void)HSTransparentColorAssistantPane_transparentColorChromaToleranceWillBeUndoneOrRedone:(id)aRedone;
- (void)HSTransparentColorAssistantPane_transparentColorHueToleranceWasUndoneOrRedone:(id)aRedone;
- (void)HSTransparentColorAssistantPane_transparentColorHueToleranceWillBeUndoneOrRedone:(id)aRedone;
- (void)HSTransparentColorAssistantPane_transparentColorWasUndoneOrRedone:(id)aRedone;
- (void)HSTransparentColorAssistantPane_transparentColorWillBeUndoneOrRedone:(id)aRedone;
- (void)HSTransparentColorAssistantPane_transparentColorEnablementWasUndoneOrRedone:(id)aRedone;
- (void)HSTransparentColorAssistantPane_transparentColorEnablementWillBeUndoneOrRedone:(id)aRedone;
- (void)HSTransparentColorAssistantPane_transparentColorLightnessToleranceDidChange:(id)aChange;
- (void)HSTransparentColorAssistantPane_transparentColorChromaToleranceDidChange:(id)aChange;
- (void)HSTransparentColorAssistantPane_transparentColorHueToleranceDidChange:(id)aChange;
- (void)HSTransparentColorAssistantPane_transparentColorDidChange:(id)aChange;
- (void)HSTransparentColorAssistantPane_validateSensitivitySlider:(id)aSlider withTolerance:(double)aTolerance;
- (void)HSTransparentColorAssistantPane_validateTransparentColorWell;
- (id)windowTitle;
- (id)HSTransparentColorAssistantPane_applier;
- (Class)applierClass;
- (id)navigationPaneSwitcher;
- (void)dealloc;
- (id)init;
- (void)HSTransparentColorAssistantPane_cardsWillChange:(id)aChange;
- (void)HSTransparentColorAssistantPane_currentCardWillChange:(id)aChange;
- (void)HSTransparentColorAssistantPane_selectionDidChange:(id)aChange;
- (void)HSTransparentColorAssistantPane_toolWillChange:(id)aChange;
- (void)HSTransparentColorAssistantPane_windowDidResignMain:(id)aChange;
- (id)assistantPaneUndoManager;
- (void)paneDidCancel:(id)aCancel;
- (id)transparentColorDelegate;
@end

@interface HSTransparentColorApplier : HSAssistantPaneApplier
{
    id<HSTransparentColorAttributes> _transparentColorAttributes;
    NSColor *_initialTransparentColor;
    double _initialTransparentColorHueTolerance;
    double _initialTransparentColorChromaTolerance;
    double _initialTransparentColorLightnessTolerance;
    NSColor *_transparentColor;
    double _transparentColorHueTolerance;
    double _transparentColorChromaTolerance;
    double _transparentColorLightnessTolerance;
    unsigned int _isTransparentColorEnabledInitially:1;
    unsigned int _isTransparentColorEnabled:1;
}
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setUpInitialSettings;
- (void)setCurrentSettingsToObject;
- (void)setInitialSettingsToObject;
- (void)setTransparentColorLightnessTolerance:(double)aTolerance;
- (void)setTransparentColorChromaTolerance:(double)aTolerance;
- (void)setTransparentColorHueTolerance:(double)aTolerance;
- (void)setTransparentColorAllTolerances:(double)aTolerances;
- (void)resetTransparentColorLightnessTolerance;
- (void)restoreTransparentColorLightnessTolerance;
- (void)resetTransparentColorChromaTolerance;
- (void)restoreTransparentColorChromaTolerance;
- (void)resetTransparentColorHueTolerance;
- (void)restoreTransparentColorHueTolerance;
- (void)setTransparentColor:(id)aColor;
- (void)resetTransparentColor;
- (void)restoreTransparentColor;
- (void)setTransparentColorEnabled:(BOOL)aEnabled;
- (void)resetTransparentColorEnablement;
- (void)restoreTransparentColorEnablement;
- (id)undoActionName;
- (void)setDelegate:(id)aDelegate;
- (void)dealloc;
@end

