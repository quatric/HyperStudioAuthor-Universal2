#import "HyperStudioPrefix.h"
#import "HSAssistantPaneApplier.h"
#import "HSCommentsTextView.h"


@interface HSTextShadowAssistantPane : HSObjectAssistantPaneWithApplier
{
    NSSlider *_offsetSlider;
    NSTextField *_offsetTextField;
    NSStepper *_offsetStepper;
    NSSlider *_blurSlider;
    NSTextField *_blurTextField;
    NSStepper *_blurStepper;
    NSControl *_angleSlider;
    NSTextField *_angleTextField;
    NSStepper *_angleStepper;
    HSObjectAssistantNavigationPaneSwitcher *_paneSwitcher;
    id<HSSystemTextViewAttributes> _observedTextViewAttributes;
    id<HSMutableShadowAttributes> _observedMutableShadowAttributes;
    id<HSButtonObjectAttributes> _observedButtonObjectAttributes;
}
- (void)validateUI;
- (void)validateUIWithNotification:(id)aNotification;
- (void)angleChanged:(id)aChanged;
- (void)blurChanged:(id)aChanged;
- (void)offsetChanged:(id)aChanged;
- (id)helpTopicKey;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)setObservedMutableShadowAttributes:(id)aAttributes;
- (void)setObservedButtonObjectAttributes:(id)aAttributes;
- (void)setObservedTextViewAttributes:(id)aAttributes;
- (id)applier;
- (Class)applierClass;
- (id)navigationPaneSwitcher;
- (void)dealloc;
- (id)init;
@end

@interface HSShadowApplier : HSAssistantPaneApplier
{
    BOOL _initialShadowEnabled;
    float _initialOffset;
    float _initialBlur;
    float _initialAngle;
    BOOL _shadowEnabled;
    float _offset;
    float _blur;
    float _angle;
}
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setUpInitialSettings;
- (void)setCurrentSettingsToObject;
- (void)setInitialSettingsToObject;
- (void)setAngle:(CGFloat)aAngle;
- (void)setBlur:(CGFloat)aBlur;
- (void)setOffset:(CGFloat)aOffset;
- (void)setShadowEnabled:(BOOL)aEnabled;
- (id)undoActionName;
- (id)shadowAttributes;
@end

