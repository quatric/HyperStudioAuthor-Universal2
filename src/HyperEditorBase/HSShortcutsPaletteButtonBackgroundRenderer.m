#import "HSShortcutsPaletteButtonBackgroundRenderer.h"
#import "HSControlslImageProvider.h"

// Image tags: bits 0-1 pick the piece (0 fill, 1 left cap, 2 right cap,
// 3 separator), 4 marks the pressed state, 8 graphite and 0x10 disabled.

static BOOL sCachedTintValid;
static BOOL sTintChecked;
static BOOL sUseCachedTint;
static NSUInteger sCachedTint;
static NSMapTable *sSharedRenderers;

@implementation HSControlBackgroundRenderer

+ (void)controlTintDidChange:(id)aChange
{
    sCachedTintValid = NO;
}

+ (NSUInteger)currentControlTint
{
    if (!sTintChecked) {
        if (![NSColor respondsToSelector:@selector(currentControlTint)]) {
            sUseCachedTint = YES;
            sCachedTintValid = NO;
            sCachedTint = [self getCurrentControlTint];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(controlTintDidChange:)
                                                         name:NSControlTintDidChangeNotification
                                                       object:nil];
        }
        sTintChecked = YES;
    }
    if (sUseCachedTint != YES)
        return [NSColor currentControlTint];
    if (sCachedTintValid != YES) {
        sCachedTint = [self getCurrentControlTint];
        sCachedTintValid = YES;
    }
    return sCachedTint;
}

+ (NSUInteger)getCurrentControlTint
{
    id variant = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleAquaColorVariant"];
    NSString *string = [NSString stringWithFormat:@"%@", variant];
    if (string == nil)
        return NSBlueControlTint;
    return [string intValue];
}

+ (id)sharedBackgroundRenderer
{
    return [self sharedBackgroundRendererForClass:self createIfNeeded:YES];
}

+ (id)sharedBackgroundRendererForClass:(Class)aClass createIfNeeded:(BOOL)aNeeded
{
    if (sSharedRenderers == NULL)
        sSharedRenderers = NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks, NSObjectMapValueCallBacks, 3);
    id renderer = NSMapGet(sSharedRenderers, aClass);
    if (renderer == nil && aNeeded) {
        renderer = [[aClass alloc] initPrimitive];
        NSMapInsertKnownAbsent(sSharedRenderers, aClass, renderer);
        [renderer release];
    }
    return renderer;
}

- (id)loadImageForTag:(NSInteger)aTag
{
    NSString *name;
    switch (aTag) {
    case 0: name = @"bt_center"; break;
    case 1: name = @"bt_left"; break;
    case 2: name = @"bt_right"; break;
    case 3: name = @"bt_divider"; break;
    case 4: name = @"bt_centeractive"; break;
    case 5: name = @"bt_leftactive"; break;
    case 6: name = @"bt_rightactive"; break;
    case 7: name = @"bt_divideractive"; break;
    case 0xc: name = @"bt_center_graphite"; break;
    case 0xd: name = @"bt_left_graphite"; break;
    case 0xe: name = @"bt_right_graphite"; break;
    case 0xf: name = @"bt_divider_graphite"; break;
    default: return nil;
    }
    return [NSImage imageNamed:name];
}

- (NSInteger)tagByStrippingFlagsForAbsentResources:(NSInteger)aResources
{
    if (aResources & 8)
        return (aResources & ~0x1c) + 0xc;
    return aResources & ~0x10;
}

- (id)imageForSeparatorSelected:(BOOL)aSelected
{
    NSInteger tag;
    if (!aSelected)
        tag = 3;
    else if ([HSControlBackgroundRenderer currentControlTint] == NSGraphiteControlTint)
        tag = 0xf;
    else
        tag = 7;
    return [self imageForTag:tag];
}

- (void)drawSeparatorWithBounds:(NSRect)aBounds selected:(BOOL)aSelected
{
    NSUInteger tag;
    if (!aSelected)
        tag = 0;
    else if ([HSControlBackgroundRenderer currentControlTint] == NSGraphiteControlTint)
        tag = 0xc;
    else
        tag = 4;
    [self drawFill:tag client:nil withBounds:aBounds drawSeparator:YES];
}

- (void)drawBackgroundImageForObject:(id)aObject bounds:(NSRect)aBounds style:(NSUInteger)aStyle
{
    NSUInteger tag;
    if (![aObject isSelected])
        tag = 0;
    else if ([HSControlBackgroundRenderer currentControlTint] == NSGraphiteControlTint)
        tag = 0xc;
    else
        tag = 4;
    if (![aObject isEnabled])
        tag |= 0x10;
    if ([aObject isLeftCap])
        [self drawLeftCap:tag client:aObject withBounds:&aBounds];
    if ([aObject isRightCap])
        [self drawRightCap:tag client:aObject withBounds:&aBounds];
    [self drawFill:tag client:aObject withBounds:aBounds drawSeparator:NO];
}

- (struct _SMKInset)contentInsetForObject:(id)aObject
{
    struct _SMKInset inset = [self defaultContentInset];
    if ([aObject isLeftCap])
        inset.left = [self leftCapWidthForObject:aObject];
    if ([aObject isRightCap])
        inset.right = [self rightCapWidthForObject:aObject];
    return inset;
}

- (struct _SMKInset)defaultContentInset
{
    return (struct _SMKInset){6.0f, 2.0f, 4.0f, 2.0f};
}

- (CGFloat)segmentHeightForObject:(id)aObject
{
    if (!_sizesValid)
        [self initSizes];
    return _segmentHeight;
}

- (void)drawFill:(NSUInteger)aFill client:(id)aClient withBounds:(NSRect)aBounds drawSeparator:(BOOL)aSeparator
{
    NSImage *separator = aSeparator ? [self imageForTag:aFill | 3] : nil;
    CGFloat x = aBounds.origin.x;
    CGFloat width = aBounds.size.width;
    if (separator != nil) {
        CGFloat separatorWidth = MIN([separator size].width, aBounds.size.width);
        [separator drawInRect:NSMakeRect(aBounds.origin.x, aBounds.origin.y, separatorWidth, aBounds.size.height)
                     fromRect:NSZeroRect
                    operation:NSCompositingOperationSourceOver
                     fraction:1.0];
        x = aBounds.origin.x + separatorWidth;
        width = NSMaxX(aBounds) - x;
    }
    if (width > 0.0) {
        NSImage *fill = [self imageForTag:aFill];
        [fill drawInRect:NSMakeRect(x, aBounds.origin.y, width, aBounds.size.height)
                fromRect:NSZeroRect
               operation:NSCompositingOperationSourceOver
                fraction:1.0];
    }
}

- (void)drawRightCap:(NSUInteger)aCap client:(id)aClient withBounds:(NSRect *)aBounds
{
    NSImage *image = [self imageForTag:aCap | 2];
    CGFloat capWidth = [self rightCapWidthForObject:aClient];
    [image drawInRect:NSMakeRect(NSMaxX(*aBounds) - capWidth, aBounds->origin.y, capWidth, aBounds->size.height)
             fromRect:NSZeroRect
            operation:NSCompositingOperationSourceOver
             fraction:1.0];
    aBounds->size.width -= capWidth;
}

- (void)drawLeftCap:(NSUInteger)aCap client:(id)aClient withBounds:(NSRect *)aBounds
{
    NSImage *image = [self imageForTag:aCap | 1];
    CGFloat capWidth = [self leftCapWidthForObject:aClient];
    [image drawInRect:NSMakeRect(aBounds->origin.x, aBounds->origin.y, capWidth, aBounds->size.height)
             fromRect:NSZeroRect
            operation:NSCompositingOperationSourceOver
             fraction:1.0];
    aBounds->origin.x += capWidth;
    aBounds->size.width -= capWidth;
}

- (CGFloat)rightCapWidthForObject:(id)aObject
{
    if (!_sizesValid)
        [self initSizes];
    return _rightCapWidth;
}

- (CGFloat)leftCapWidthForObject:(id)aObject
{
    if (!_sizesValid)
        [self initSizes];
    return _leftCapWidth;
}

- (void)initSizes
{
    if (_sizesValid)
        return;
    NSImage *image = [self imageForTag:1];
    _leftCapWidth = image ? [image size].width : 0.0f;
    image = [self imageForTag:2];
    _rightCapWidth = image ? [image size].width : 0.0f;
    image = [self imageForTag:0];
    _segmentHeight = image ? [image size].height : 0.0f;
    _sizesValid = YES;
}

- (id)imageForTag:(NSInteger)aTag
{
    if ((NSUInteger)aTag >= 32)
        return nil;
    if (!(_imageInitAttempts & (1u << aTag))) {
        NSInteger tag = [self tagByStrippingFlagsForAbsentResources:aTag];
        _images[aTag] = [[self loadImageForTag:tag] retain];
        _imageInitAttempts |= 1u << aTag;
    }
    return _images[aTag];
}

- (void)dealloc
{
    for (int i = 0; i < 32; i++)
        [_images[i] release];
    [super dealloc];
}

- (id)init
{
    id renderer = [[[self class] sharedBackgroundRendererForClass:[self class] createIfNeeded:YES] retain];
    [self release];
    return renderer;
}

- (id)initPrimitive
{
    return [super init];
}

@end

@implementation HSShortcutsPaletteButtonBackgroundRenderer

- (id)loadImageForTag:(NSInteger)aTag
{
    NSString *name;
    switch (aTag) {
    case 0: name = @"SP_BG_Center"; break;
    case 1: name = @"SP_BG_Left"; break;
    case 2: name = @"SP_BG_Right"; break;
    case 4: case 0xc: name = @"SP_BG_Center_Press"; break;
    case 5: case 0xd: name = @"SP_BG_Left_Press"; break;
    case 6: case 0xe: name = @"SP_BG_Right_Press"; break;
    default: return nil;
    }
    return [NSImage imageNamed:name];
}

@end

@implementation HSLayoutPaletteButtonBackgroundRenderer

- (id)loadImageForTag:(NSInteger)aTag
{
    if (aTag == 0xc || aTag == 4)
        return [NSImage imageNamed:@"LP_SButton_pressed"];
    if (aTag != 0)
        return nil;
    return [NSImage imageNamed:@"LP_SButton"];
}

@end

@implementation HSLayoutPaletteTitleButtonBackgroundRenderer

- (id)loadImageForTag:(NSInteger)aTag
{
    if (aTag == 0xc || aTag == 4)
        return [NSImage imageNamed:@"LP_BButton_pressed"];
    if (aTag != 0)
        return nil;
    return [NSImage imageNamed:@"LP_BButton"];
}

@end

@implementation HSObjectBrowserToolbarButtonBackgroundRenderer

- (id)loadImageForTag:(NSInteger)aTag
{
    if (aTag == 0xc || aTag == 4)
        return [NSImage imageNamed:@"OB_BG_Button_Pressed"];
    if (aTag != 0)
        return nil;
    return [NSImage imageNamed:@"OB_BG_Button_Notmal"];
}

@end

@implementation HSAssistantButtonBackgroundRenderer

- (id)loadImageForTag:(NSInteger)aTag
{
    NSString *name;
    switch (aTag) {
    case 0: name = @"AVB_Small_Center"; break;
    case 1: name = @"AVB_Small_Left"; break;
    case 2: name = @"AVB_Small_Right"; break;
    case 4: case 0xc: name = @"AVB_Small_Center_Selected"; break;
    case 5: case 0xd: name = @"AVB_Small_Left_Selected"; break;
    case 6: case 0xe: name = @"AVB_Small_Right_Selected"; break;
    default: return nil;
    }
    return [NSImage imageNamed:name];
}

@end

@implementation HSAssistantLargeButtonBackgroundRenderer

- (id)loadImageForTag:(NSInteger)aTag
{
    NSString *name;
    switch (aTag) {
    case 0: name = @"AVB_Center"; break;
    case 1: name = @"AVB_Left"; break;
    case 2: name = @"AVB_Right"; break;
    case 4: case 0xc: name = @"AVB_Center_Press"; break;
    case 5: case 0xd: name = @"AVB_Left_Press"; break;
    case 6: case 0xe: name = @"AVB_Right_Press"; break;
    default: return nil;
    }
    return [NSImage imageNamed:name];
}

@end

@implementation HSAssistantSegmentedControlControlBackgroundRenderer

- (id)loadImageForTag:(NSInteger)aTag
{
    NSString *name;
    switch (aTag) {
    case 0: name = @"small_tools_buttonFill"; break;
    case 1: name = @"small_tools_buttonLeft"; break;
    case 2: name = @"small_tools_buttonRight"; break;
    case 3: case 7: case 0xf: name = @"small_tools_divider"; break;
    case 4: case 0xc: name = @"small_tools_buttonFillPress"; break;
    case 5: case 0xd: name = @"small_tools_buttonLeftPress"; break;
    case 6: case 0xe: name = @"small_tools_buttonRightPress"; break;
    default: return nil;
    }
    return [NSImage imageNamed:name];
}

@end

@implementation HSAssistantPaneControlBackgroundRenderer

- (id)loadImageForTag:(NSInteger)aTag
{
    NSString *name;
    switch (aTag) {
    case 0: name = @"tools_buttonFill"; break;
    case 1: name = @"tools_buttonLeft"; break;
    case 2: name = @"tools_buttonRight"; break;
    case 3: case 7: case 0xf: name = @"tools_divider"; break;
    case 4: case 0xc: name = @"tools_buttonFillPressed"; break;
    case 5: case 0xd: name = @"tools_buttonLeftPressed"; break;
    case 6: case 0xe: name = @"tools_buttonRightPressed"; break;
    default: return nil;
    }
    return [NSImage imageNamed:name];
}

@end

@implementation HSAssistantSegmentedControlBackgroundRenderer

- (id)loadImageForTag:(NSInteger)aTag
{
    NSString *name;
    switch (aTag) {
    case 0: name = @"Small_PanelSegm_Center"; break;
    case 3: name = @"Small_PanelSegm_Separ"; break;
    case 4: case 0xc: name = @"Small_PanelSegm_Center_on"; break;
    case 7: case 0xf: name = @"Small_PanelSegm_Separ_on"; break;
    default: return nil;
    }
    return [NSImage imageNamed:name];
}

@end

@implementation HSCustomTabViewBackgroundRenderer

- (BOOL)supportsGraphiteAppearance
{
    return NO;
}

- (BOOL)supportsInactiveBackground
{
    return NO;
}

- (BOOL)supportsDisabledBackground
{
    return NO;
}

- (struct _SMKInset)defaultContentInset
{
    return (struct _SMKInset){2.0f, 0.0f, 2.0f, 0.0f};
}

- (id)loadImageForTag:(NSInteger)aTag
{
    NSString *name;
    switch (aTag) {
    case 0: name = @"Tab_Center_Normal"; break;
    case 1: name = @"Tab_Left_Normal"; break;
    case 2: name = @"Tab_Right_Normal"; break;
    case 3: case 7: case 0xf: name = @"Tab_Separ"; break;
    case 4: case 0xc: name = @"Tab_Center_Press"; break;
    case 5: case 0xd: name = @"Tab_Left_Press"; break;
    case 6: case 0xe: name = @"Tab_Right_Press"; break;
    default: return nil;
    }
    NSBundle *bundle = [NSBundle bundleForClass:[HSCustomTabViewBackgroundRenderer class]];
    NSString *path = [bundle pathForResource:name ofType:@"pdf"];
    return [[[NSImage alloc] initWithContentsOfFile:path] autorelease];
}

@end

@implementation HSPopUpButtonBackgroundRender

- (BOOL)supportsSelectedBackground
{
    return YES;
}

- (BOOL)supportsGraphiteAppearance
{
    return NO;
}

- (BOOL)supportsInactiveBackground
{
    return NO;
}

- (BOOL)supportsDisabledBackground
{
    return YES;
}

- (struct _SMKInset)defaultContentInset
{
    return (struct _SMKInset){0.0f, 4.0f, 0.0f, 0.0f};
}

- (id)loadImageForTag:(NSInteger)aTag
{
    HSControlslImageProvider *provider = [HSControlslImageProvider sharedImageProvider];
    switch (aTag) {
    case 0: return [provider popUpButtonFillImage];
    case 1: return [provider popUpButtonLeftCapImage];
    case 2: return [provider popUpButtonRightCapImage];
    case 4: case 0xc: return [provider popUpButtonFillPressedImage];
    case 5: case 0xd: return [provider popUpButtonLeftCapPressedImage];
    case 6: case 0xe: return [provider popUpButtonRightCapPressedImage];
    case 0x10: return [provider popUpButtonFillDisabledImage];
    case 0x11: return [provider popUpButtonLeftCapDisabledImage];
    case 0x12: return [provider popUpButtonRightCapDisabledImage];
    default: return nil;
    }
}

@end

@implementation HSButtonBackgroundRenderer

- (BOOL)supportsSelectedBackground
{
    return YES;
}

- (BOOL)supportsGraphiteAppearance
{
    return NO;
}

- (BOOL)supportsInactiveBackground
{
    return NO;
}

- (BOOL)supportsDisabledBackground
{
    return YES;
}

- (struct _SMKInset)defaultContentInset
{
    return (struct _SMKInset){0.0f, 0.0f, 0.0f, 0.0f};
}

- (id)loadImageForTag:(NSInteger)aTag
{
    HSControlslImageProvider *provider = [HSControlslImageProvider sharedImageProvider];
    switch (aTag) {
    case 0: return [provider buttonFillImage];
    case 1: return [provider buttonLeftCapImage];
    case 2: return [provider buttonRightCapImage];
    case 4: case 0xc: return [provider buttonFillPressedImage];
    case 5: case 0xd: return [provider buttonLeftCapPressedImage];
    case 6: case 0xe: return [provider buttonRightCapPressedImage];
    case 0x10: return [provider buttonFillDisabledImage];
    case 0x11: return [provider buttonLeftCapDisabledImage];
    case 0x12: return [provider buttonRightCapDisabledImage];
    default: return nil;
    }
}

@end

@implementation HSActionsPaneButtonBackgroundRenderer

- (void)drawBackgroundImageForObject:(id)aObject bounds:(NSRect)aBounds style:(NSUInteger)aStyle
{
    if (![self drawsEmptyBorder])
        [super drawBackgroundImageForObject:aObject bounds:aBounds style:aStyle];
}

- (struct _SMKInset)contentInsetForObject:(id)aObject
{
    return (struct _SMKInset){-2.0f, 0.0f, -2.0f, 0.0f};
}

- (void)setDrawsEmptyBorder:(BOOL)aBorder
{
    _drawsEmptyBorder = aBorder;
}

- (BOOL)drawsEmptyBorder
{
    return _drawsEmptyBorder;
}

@end

@implementation HSObjectAssistantsToolbarControlBackgroundRenderer

- (id)loadImageForTag:(NSInteger)aTag
{
    NSString *name;
    switch (aTag) {
    case 0: case 1: case 2: name = @"SOTS_toolbar_normal"; break;
    case 4: case 0xc: name = @"SOTS_toolbar_pressed"; break;
    case 5: case 6: name = @"SOTS_toolbar_separator"; break;
    default: return nil;
    }
    return [NSImage imageNamed:name];
}

@end

@implementation HSAnimationOptionsControlBackgroundRenderer

- (id)loadImageForTag:(NSInteger)aTag
{
    NSString *name;
    switch (aTag) {
    case 0: name = @"PanelSegm_Center"; break;
    case 3: name = @"PanelSegm_Separ"; break;
    case 4: name = @"PanelSegm_Center_on"; break;
    case 7: name = @"PanelSegm_Separ_on"; break;
    case 0xc: name = @"PanelSegm_Center_Graphite"; break;
    case 0xf: name = @"PanelSegm_Separ_Graphite"; break;
    default: return nil;
    }
    return [NSImage imageNamed:name];
}

@end

@implementation HSToolSettingsBigControlBackgroundRenderer

- (id)loadImageForTag:(NSInteger)aTag
{
    NSString *name;
    switch (aTag) {
    case 0: name = @"tp_b_buttonFill"; break;
    case 1: name = @"tp_b_buttonLeft"; break;
    case 2: name = @"tp_b_buttonRight"; break;
    case 3: case 7: case 0xf: name = @"tp_b_divider"; break;
    case 4: case 0xc: name = @"tp_b_buttonFillPressed"; break;
    case 5: case 0xd: name = @"tp_b_buttonLeftPressed"; break;
    case 6: case 0xe: name = @"tp_b_buttonRightPressed"; break;
    default: return nil;
    }
    return [NSImage imageNamed:name];
}

@end

@implementation HSToolSettingsControlBackgroundRenderer

- (id)loadImageForTag:(NSInteger)aTag
{
    NSString *name;
    switch (aTag) {
    case 0: name = @"tp_buttonFill"; break;
    case 1: name = @"tp_buttonLeft"; break;
    case 2: name = @"tp_buttonRight"; break;
    case 3: case 7: case 0xf: name = @"tp_divider"; break;
    case 4: case 0xc: name = @"tp_buttonFillPressed"; break;
    case 5: case 0xd: name = @"tp_buttonLeftPressed"; break;
    case 6: case 0xe: name = @"tp_buttonRightPressed"; break;
    default: return nil;
    }
    return [NSImage imageNamed:name];
}

- (struct _SMKInset)contentInsetForObject:(id)aObject
{
    struct _SMKInset inset = [self defaultContentInset];
    if ([aObject isLeftCap])
        inset.left = 3.0f;
    if ([aObject isRightCap])
        inset.right = [self rightCapWidthForObject:aObject];
    return inset;
}

- (struct _SMKInset)defaultContentInset
{
    return (struct _SMKInset){6.0f, 2.0f, 2.0f, 2.0f};
}

@end

@implementation HSCardNavigationControlBackgroundRenderer

- (id)loadImageForTag:(NSInteger)aTag
{
    NSString *name;
    switch (aTag) {
    case 0: name = @"MW_SegmContr_central"; break;
    case 1: name = @"MW_SegmContr_left"; break;
    case 2: name = @"MW_SegmContr_right"; break;
    case 3: case 7: case 0xf: name = @"MW_SegmContr_separ"; break;
    case 4: case 0xc: name = @"MW_SegmContr_press_central"; break;
    case 5: case 0xd: name = @"MW_SegmContr_press_left"; break;
    case 6: case 0xe: name = @"MW_SegmContr_press_right"; break;
    default: return nil;
    }
    return [NSImage imageNamed:name];
}

@end

@implementation HSLibraryOptionsButtonBackgroundRenderer

- (id)loadImageForTag:(NSInteger)aTag
{
    if (aTag == 0xc || aTag == 4)
        return [NSImage imageNamed:@"MyLibraryOptions_on"];
    if (aTag != 0)
        return nil;
    return [NSImage imageNamed:@"MyLibraryOptions"];
}

@end

@implementation HSLibraryPlusButtonBackgroundRenderer

- (id)loadImageForTag:(NSInteger)aTag
{
    if (aTag == 0xc || aTag == 4)
        return [NSImage imageNamed:@"MyLibraryPlus_on"];
    if (aTag != 0)
        return nil;
    return [NSImage imageNamed:@"MyLibraryPlus"];
}

@end

@implementation HSLibraryPanelControlBackgroundRenderer

- (id)loadImageForTag:(NSInteger)aTag
{
    NSString *name;
    switch (aTag) {
    case 0: name = @"PanelSegm_Center"; break;
    case 3: name = @"PanelSegm_Separ"; break;
    case 4: name = @"PanelSegm_Center_on"; break;
    case 7: name = @"PanelSegm_Separ_on"; break;
    case 0xc: name = @"PanelSegm_Center_Graphite"; break;
    case 0xf: name = @"PanelSegm_Separ_Graphite"; break;
    default: return nil;
    }
    return [NSImage imageNamed:name];
}

@end

@implementation HSSmallControlBackgroundRenderer

- (id)loadImageForTag:(NSInteger)aTag
{
    NSString *name;
    switch (aTag) {
    case 0: name = @"segm_Center"; break;
    case 1: name = @"segm_Left"; break;
    case 2: name = @"segm_Right"; break;
    case 3: name = @"segm_Separator"; break;
    case 4: name = @"segm_Center_on"; break;
    case 5: name = @"segm_Left_on"; break;
    case 6: name = @"segm_Right_on"; break;
    case 7: name = @"segm_Separator_on"; break;
    case 0xc: name = @"segm_Center_Graphite"; break;
    case 0xd: name = @"segm_Left_Graphite"; break;
    case 0xe: name = @"segm_Right_Graphite"; break;
    case 0xf: name = @"segm_Separator_Graphite"; break;
    default: return nil;
    }
    return [NSImage imageNamed:name];
}

@end

@implementation HSToolsControlBackgroundRenderer

- (id)loadImageForTag:(NSInteger)aTag
{
    NSString *name;
    switch (aTag) {
    case 0: name = @"LSegm_Center"; break;
    case 1: name = @"LSegm_Left"; break;
    case 2: name = @"LSegm_Right"; break;
    case 3: name = @"LSegm_Separ"; break;
    case 4: name = @"LSegm_Center_on"; break;
    case 5: name = @"LSegm_Left_on"; break;
    case 6: name = @"LSegm_Right_on"; break;
    case 7: name = @"LSegm_Separ_on"; break;
    case 0xc: name = @"LSegm_Center_Graphite"; break;
    case 0xd: name = @"LSegm_Left_Graphite"; break;
    case 0xe: name = @"LSegm_Right_Graphite"; break;
    case 0xf: name = @"LSegm_Separ_Graphite"; break;
    default: return nil;
    }
    return [NSImage imageNamed:name];
}

@end
