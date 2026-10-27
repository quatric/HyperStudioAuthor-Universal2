#import "HyperStudioPrefix.h"


@interface HSToolPaletteColorViewController : NSObject
{
    NSView *_colorView;
    NSView *_containerView;
    NSView *_previewView;
    id<HSToolPaletteColorViewControllerDelegate> _delegate;
    HSGradientColorWell *_crayonsColorWell;
    HSGradientColorWell *_gradientsColorWell;
    HSGradientColorWell *_texturesColorWell;
    HSCustomTabView *_tabView;
    HSCrayonsView *_crayonsView;
    NSView *_crayonsContainerView;
    NSView *_gradientsView;
    NSView *_texturesView;
    NSView *_crayonsPreview;
    NSView *_gradientPreview;
    NSView *_texturePreview;
    SMKGridControl *_gradientsGridControl;
    SMKGridControl *_texturesGridControl;
    NSButton *_colorPickingActivateButton;
    NSView *_eraserColorView;
    NSButton *_eraserButton;
    NSView *_eraserPreviewView;
    NSView *_eraserContainerView;
    NSView *_eraserSuperContainerView;
    HSColorWell *_workColorWell;
    struct HyperStudio_anon5 _toolPaletteColorViewControllerFlags;
    NSColor *_color;
    BOOL _isInLiveChanging;
}
- (void)selectedTabDidChangeInCustomTabView:(id)aView;
- (void)selectionDidChangeInGridControl:(id)aControl;
- (void)synchronizeColorWellColorWithSelectedInGridControl:(id)aControl;
- (id)gridControl:(id)aControl imageForItemAt:(NSInteger)aAt;
- (id)gridControl:(id)aControl additionalInfoForItemAt:(NSInteger)aAt;
- (id)gridControl:(id)aControl titleForItemAt:(NSInteger)aAt;
- (NSInteger)numberOfItemsInGridControl:(id)aControl;
- (Class)cellClass;
- (void)colorPickingDidFinishWithColor:(id)aColor;
- (void)validateUserInterface;
- (void)eraseBackground:(id)aBackground;
- (void)activateColorPickingMode:(id)aMode;
- (void)colorChanged:(id)aChanged;
- (id)newColorFromColor:(id)aColor withAlphaComponent:(CGFloat)aComponent;
- (void)orderFrontColorPanel:(id)aPanel;
- (BOOL)isPatternSupportEnabled;
- (void)setPatternSupportEnabled:(BOOL)aEnabled;
- (BOOL)isGradientSupportEnabled;
- (void)setGradientSupportEnabled:(BOOL)aEnabled;
- (void)setShouldShowsAlphaInActivePanel:(BOOL)aPanel;
- (BOOL)shouldShowsAlphaInActivePanel;
- (id)color;
- (void)setColor:(id)aColor;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (id)crayonsView;
- (id)eraserColorView;
- (id)colorView;
- (void)awakeFromNib;
- (void)dealloc;
- (void)HSToolPaletteColorViewController_setupColorViewWithColorsContainer:(id)aContainer previewContainer:(id)aContainer2;
- (void)HSToolPaletteColorViewController_setupGradientsAndPattersViewsWithColorsContainer:(id)aContainer;
@end

@interface HSToolPaletteColorViewController (PresetsLoading)
+ (id)texturePresets;
+ (id)gradientPresets;
+ (void)addItemsFromFolder:(id)aFolder to:(id)aTo;
+ (id)allTexturePaths;
+ (id)colorViewPresets;
@end

