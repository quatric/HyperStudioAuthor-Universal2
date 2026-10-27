#import "HyperEditorBasePrefix.h"


@interface HSControlBackgroundRenderer : NSObject <SMKBackgroundRenderer, NSObject>
{
    float _leftCapWidth;
    float _rightCapWidth;
    float _segmentHeight;
    BOOL _sizesValid;
    NSImage * _images[32];
    unsigned int _imageInitAttempts;
}
+ (void)controlTintDidChange:(id)aChange;
+ (NSUInteger)currentControlTint;
+ (NSUInteger)getCurrentControlTint;
+ (id)sharedBackgroundRenderer;
+ (id)sharedBackgroundRendererForClass:(Class)aClass createIfNeeded:(BOOL)aNeeded;
- (id)loadImageForTag:(NSInteger)aTag;
- (NSInteger)tagByStrippingFlagsForAbsentResources:(NSInteger)aResources;
- (id)imageForSeparatorSelected:(BOOL)aSelected;
- (void)drawSeparatorWithBounds:(NSRect)aBounds selected:(BOOL)aSelected;
- (void)drawBackgroundImageForObject:(id)aObject bounds:(NSRect)aBounds style:(NSUInteger)aStyle;
- (struct _SMKInset)contentInsetForObject:(id)aObject;
- (struct _SMKInset)defaultContentInset;
- (CGFloat)segmentHeightForObject:(id)aObject;
- (void)drawFill:(NSUInteger)aFill client:(id)aClient withBounds:(NSRect)aBounds drawSeparator:(BOOL)aSeparator;
- (void)drawRightCap:(NSUInteger)aCap client:(id)aClient withBounds:(NSRect *)aBounds;
- (void)drawLeftCap:(NSUInteger)aCap client:(id)aClient withBounds:(NSRect *)aBounds;
- (CGFloat)rightCapWidthForObject:(id)aObject;
- (CGFloat)leftCapWidthForObject:(id)aObject;
- (void)initSizes;
- (id)imageForTag:(NSInteger)aTag;
- (void)dealloc;
- (id)init;
- (id)initPrimitive;
@end

@interface HSShortcutsPaletteButtonBackgroundRenderer : HSControlBackgroundRenderer
{
}
- (id)loadImageForTag:(NSInteger)aTag;
@end

@interface HSLayoutPaletteButtonBackgroundRenderer : HSControlBackgroundRenderer
{
}
- (id)loadImageForTag:(NSInteger)aTag;
@end

@interface HSLayoutPaletteTitleButtonBackgroundRenderer : HSControlBackgroundRenderer
{
}
- (id)loadImageForTag:(NSInteger)aTag;
@end

@interface HSObjectBrowserToolbarButtonBackgroundRenderer : HSControlBackgroundRenderer
{
}
- (id)loadImageForTag:(NSInteger)aTag;
@end

@interface HSAssistantButtonBackgroundRenderer : HSControlBackgroundRenderer
{
}
- (id)loadImageForTag:(NSInteger)aTag;
@end

@interface HSAssistantLargeButtonBackgroundRenderer : HSControlBackgroundRenderer
{
}
- (id)loadImageForTag:(NSInteger)aTag;
@end

@interface HSAssistantSegmentedControlControlBackgroundRenderer : HSControlBackgroundRenderer
{
}
- (id)loadImageForTag:(NSInteger)aTag;
@end

@interface HSAssistantPaneControlBackgroundRenderer : HSControlBackgroundRenderer
{
}
- (id)loadImageForTag:(NSInteger)aTag;
@end

@interface HSAssistantSegmentedControlBackgroundRenderer : HSControlBackgroundRenderer
{
}
- (id)loadImageForTag:(NSInteger)aTag;
@end

@interface HSCustomTabViewBackgroundRenderer : HSControlBackgroundRenderer
{
}
- (BOOL)supportsGraphiteAppearance;
- (BOOL)supportsInactiveBackground;
- (BOOL)supportsDisabledBackground;
- (struct _SMKInset)defaultContentInset;
- (id)loadImageForTag:(NSInteger)aTag;
@end

@interface HSPopUpButtonBackgroundRender : HSControlBackgroundRenderer
{
}
- (BOOL)supportsSelectedBackground;
- (BOOL)supportsGraphiteAppearance;
- (BOOL)supportsInactiveBackground;
- (BOOL)supportsDisabledBackground;
- (struct _SMKInset)defaultContentInset;
- (id)loadImageForTag:(NSInteger)aTag;
@end

@interface HSButtonBackgroundRenderer : HSControlBackgroundRenderer
{
}
- (BOOL)supportsSelectedBackground;
- (BOOL)supportsGraphiteAppearance;
- (BOOL)supportsInactiveBackground;
- (BOOL)supportsDisabledBackground;
- (struct _SMKInset)defaultContentInset;
- (id)loadImageForTag:(NSInteger)aTag;
@end

@interface HSActionsPaneButtonBackgroundRenderer : HSButtonBackgroundRenderer
{
    BOOL _drawsEmptyBorder;
}
- (void)drawBackgroundImageForObject:(id)aObject bounds:(NSRect)aBounds style:(NSUInteger)aStyle;
- (struct _SMKInset)contentInsetForObject:(id)aObject;
- (void)setDrawsEmptyBorder:(BOOL)aBorder;
- (BOOL)drawsEmptyBorder;
@end

@interface HSObjectAssistantsToolbarControlBackgroundRenderer : HSControlBackgroundRenderer
{
}
- (id)loadImageForTag:(NSInteger)aTag;
@end

@interface HSAnimationOptionsControlBackgroundRenderer : HSControlBackgroundRenderer
{
}
- (id)loadImageForTag:(NSInteger)aTag;
@end

@interface HSToolSettingsBigControlBackgroundRenderer : HSControlBackgroundRenderer
{
}
- (id)loadImageForTag:(NSInteger)aTag;
@end

@interface HSToolSettingsControlBackgroundRenderer : HSControlBackgroundRenderer
{
}
- (id)loadImageForTag:(NSInteger)aTag;
- (struct _SMKInset)contentInsetForObject:(id)aObject;
- (struct _SMKInset)defaultContentInset;
@end

@interface HSCardNavigationControlBackgroundRenderer : HSControlBackgroundRenderer
{
}
- (id)loadImageForTag:(NSInteger)aTag;
- (CGFloat)segmentHeightForObject:(id)aObject;
@end

@interface HSLibraryOptionsButtonBackgroundRenderer : HSControlBackgroundRenderer
{
}
- (id)loadImageForTag:(NSInteger)aTag;
@end

@interface HSLibraryPlusButtonBackgroundRenderer : HSControlBackgroundRenderer
{
}
- (id)loadImageForTag:(NSInteger)aTag;
@end

@interface HSLibraryPanelControlBackgroundRenderer : HSControlBackgroundRenderer
{
}
- (id)loadImageForTag:(NSInteger)aTag;
@end

@interface HSSmallControlBackgroundRenderer : HSControlBackgroundRenderer
{
}
- (id)loadImageForTag:(NSInteger)aTag;
@end

@interface HSToolsControlBackgroundRenderer : HSControlBackgroundRenderer
{
}
- (id)loadImageForTag:(NSInteger)aTag;
@end

