#import "HyperStudioPrefix.h"
#import "HSAssistantPaneApplier.h"
#import "HSCommentsTextView.h"


@interface HSScaleAndRotateAssistantPane : HSObjectAssistantPane
{
    SMKAngleSlider *_rotationSlider;
    NSStepper *_rotationStepper;
    NSTextField *_rotationTextField;
    HSBlueTriangleSlider *_scaleFactorSlider;
    NSStepper *_scaleFactorStepper;
    NSTextField *_scaleFactorTextField;
    NSButton *_flipHorizontalButton;
    NSButton *_flipVerticalButton;
    BOOL _userMadeTheDecision;
    BOOL _isApplayed;
    HSScaleAndRotateApplier *_applier;
    HSObjectAssistantNavigationPaneSwitcher *_paneSwitcher;
}
+ (CGFloat)angleInRadiansFromClockwiseDegrees:(CGFloat)aDegrees;
+ (CGFloat)angleInClockwiseDegreesFromRadians:(CGFloat)aRadians;
- (void)validateUI;
- (void)validateUIWithNotification:(id)aNotification;
- (void)flipVertical:(id)aVertical;
- (void)flipHorizontal:(id)aHorizontal;
- (void)scaleFactorChanged:(id)aChanged;
- (void)rotationChanged:(id)aChanged;
- (id)helpTopicKey;
- (id)imageObjectAttributes;
- (id)geometryAttributes;
- (void)paneDidCancel:(id)aCancel;
- (void)paneDidOK:(id)aOK;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)viewDidLoad;
- (id)navigationPaneSwitcher;
- (id)applier;
- (void)setApplier:(id)aApplier;
- (void)dealloc;
- (id)init;
@end

@interface HSScaleAndRotateApplier : HSAssistantPaneApplier
{
    CGAffineTransform _initialAffineTransform;
    float _initialWidthScale;
    float _initialHeightScale;
    float _initialAngle;
    BOOL _initialIsFlippedHorizontally;
    BOOL _initialIsFlippedVertically;
    CGAffineTransform _affineTransform;
    float _widthScale;
    float _heightScale;
    float _angle;
    BOOL _isFlippedHorizontally;
    BOOL _isFlippedVertically;
    BOOL _userMadeTheDecision;
    HSGeometryBehaviorApplier *_geometryApplier;
}
- (BOOL)userMadeTheDecision;
- (void)setUserMadeTheDecision:(BOOL)aDecision;
- (id)imageObjectAttributes;
- (id)geometryAttributes;
- (BOOL)isFlippedVertically;
- (void)setIsFlippedVertically:(BOOL)aVertically;
- (BOOL)isFlippedHorizontally;
- (void)setIsFlippedHorizontally:(BOOL)aHorizontally;
- (CGFloat)angle;
- (void)setAngle:(CGFloat)aAngle;
- (BOOL)hasUniformScale;
- (CGFloat)heightScale;
- (CGFloat)widthScale;
- (CGFloat)scale;
- (void)setScale:(CGFloat)aScale;
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)getCurrentSettingsFromObject;
- (id)undoActionName;
- (void)dealloc;
- (id)initWithObject:(id)aObject;
@end

