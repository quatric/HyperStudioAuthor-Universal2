#import "HyperStudioPrefix.h"


@interface HSDefaultWindowsLayoutManager : NSObject
{
    NSMutableDictionary *_defaults;
    NSRect _screenFrame;
    NSRect _visibleScreenFrame;
    NSSize _idealLayoutSize;
    NSSize _idealLayoutToScreenOffset;
    float _leftPalettesMinX;
    float _rightPalettesMinX;
    float _rightPalettesMaxX;
    NSRect _mainWindowFrame;
    NSMutableDictionary *_pallettesFrameValuesDictionary;
    NSMutableArray *_leftPalettesFrameValues;
    NSMutableArray *_rightPalettesFrameValues;
}
+ (id)windowsLayoutManagerWithDefaults:(id)aDefaults;
- (id)defaults;
- (void)applySmartDefaultWindowsLayout;
- (void)synchronizeWithDefaults;
- (void)applySmartLayoutCorrectionsToMainWindow;
- (void)applySmartLayoutCorrectionsToPalettes;
- (void)shiftRightPalettesToRespectMainWindowIfCan;
- (void)shiftLeftPalettesOnCardIndexWidthIfCan;
- (CGFloat)resultLayoutHorizontalOffset;
- (BOOL)canCenterLayout;
- (BOOL)canOffsetRightPalettes;
- (BOOL)canOffsetLeftPalettes;
- (BOOL)shouldUseMainWindowCenteringHorizontalOffset;
- (CGFloat)mainWindowCenteringHorizontalOffset;
- (void)setMainWindowFrame:(NSRect)aFrame;
- (NSRect)mainWindowFrame;
- (NSRect)defaultMainWindowFrame;
- (CGFloat)rightFreeVisibleScreenWidth;
- (CGFloat)rightPalettesMaxX;
- (CGFloat)rightPalettesMinX;
- (CGFloat)leftPalettesMinX;
- (void)invalidateCachedValues;
- (id)rightPalettesFrameValues;
- (id)leftPalettesFrameValues;
- (void)dividePaletteFrameValuesToLeftAndRightRelativeToIdealLayoutCenter;
- (id)pallettesFrameValuesDictionary;
- (CGFloat)idealLayoutHalfWidth;
- (NSSize)idealLayoutToScreenOffset;
- (NSSize)idealLayoutSize;
- (void)mergeDefaultsWithResolutionDependentDefaults;
- (id)resolutionDependentDefaults;
- (id)keyForResolutionDependentDefaults;
- (BOOL)isCardIndexOpened;
- (CGFloat)cardIndexHalfOffset;
- (id)palettesAutoSaveNamesEnumerator;
- (void)setVisibleScreenFrame:(NSRect)aFrame;
- (NSRect)visibleScreenFrame;
- (void)setScreenFrame:(NSRect)aFrame;
- (NSRect)screenFrame;
- (void)dealloc;
- (id)initWithDefaults:(id)aDefaults;
@end

