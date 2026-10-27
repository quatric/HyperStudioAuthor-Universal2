#import "HyperStudioPrefix.h"


@interface HSStackBackgroundSolidColorController : NSObject <HSStackBackgroundController, NSObject>
{
    NSView *_controlledView;
    NSColorWell *_solidColor;
    NSMatrix *_solidColorMatrix;
    NSArray *_solidColorPreset;
    id _delegate;
    HSPresentationAssistantPaneApplier *_applier;
    BOOL _didInitOnce;
    BOOL _shouldActivateColorWell;
}
- (NSSize)solidColorMatrixCellSize;
- (id)solidColorPreset;
- (id)presetSolidColorAtIndex:(NSInteger)aIndex;
- (id)solidColorImageAtIndex:(NSInteger)aIndex;
- (void)setupSolidColortMatrix;
- (void)chooseSolidColorPreset:(id)aPreset;
- (void)solidColorChanged:(id)aChanged;
- (void)setShouldActivateColorWellOnMount:(BOOL)aMount;
- (BOOL)deactivatedColorWellOnUnmount;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)validateUIElements;
- (void)apply;
- (void)setApplier:(id)aApplier;
- (id)contentView;
- (void)dealloc;
@end

