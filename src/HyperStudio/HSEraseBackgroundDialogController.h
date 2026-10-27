#import "HyperStudioPrefix.h"


@interface HSEraseBackgroundDialogController : HSGenericModalController
{
    HSGradientColorWell *_solidColorWell;
    NSMatrix *_solidColorMatrix;
    HSEraseBackgroundView *_cardPreview;
    HSDocument *_originalObject;
    HSToolSettings *_toolSettings;
}
- (void)onChooseSolidColorPreset:(id)aPreset;
- (void)onSolidColor:(id)aColor;
- (void)updateCardPreview;
- (NSSize)solidColorMatrixCellSize;
- (id)solidColorPreset;
- (id)imageWithSolidColor:(id)aColor;
- (void)setupSolidColortMatrix;
- (void)dealloc;
- (void)applyChanges;
- (id)initWithOriginalObject:(id)aObject;
- (void)didLoadNib;
- (id)nibName;
@end

