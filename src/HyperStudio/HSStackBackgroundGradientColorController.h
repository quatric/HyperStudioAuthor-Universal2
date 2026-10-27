#import "HyperStudioPrefix.h"


@interface HSStackBackgroundGradientColorController : NSObject <HSStackBackgroundController, NSObject>
{
    NSView *_controlledView;
    HSGradientColorWell *_gradientColor;
    SMKGridControl *_gradientsGridControl;
    id _delegate;
    HSPresentationAssistantPaneApplier *_applier;
    BOOL _didInitOnce;
    BOOL _shouldActivateColorWell;
}
+ (id)gradientPresets;
- (void)selectionDidChangeInGridControl:(id)aControl;
- (void)synchronizeColorWellColorWithSelectedInGridControl:(id)aControl;
- (id)gridControl:(id)aControl additionalInfoForItemAt:(NSInteger)aAt;
- (id)gridControl:(id)aControl imageForItemAt:(NSInteger)aAt;
- (id)gridControl:(id)aControl titleForItemAt:(NSInteger)aAt;
- (NSInteger)numberOfItemsInGridControl:(id)aControl;
- (Class)cellClass;
- (void)gradientColorChanged:(id)aChanged;
- (id)defaultGradientColor;
- (void)setupLinearGradientControl;
- (void)setShouldActivateColorWellOnMount:(BOOL)aMount;
- (BOOL)deactivatedColorWellOnUnmount;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)validateUIElements;
- (void)apply;
- (id)contentView;
- (void)setApplier:(id)aApplier;
- (void)dealloc;
@end

