#import "HyperStudioPrefix.h"


@interface HSPopUpButtonCell : NSPopUpButtonCell <SMKBackgroundRendererClient>
{
    NSImage *_backgroundImage;
    NSImage *_pushedBackgroundImage;
    id<SMKBackgroundRenderer> _backgroundRenderer;
    BOOL _isMenuAttached;
    BOOL _drawsText;
    NSTextFieldCell *_textFieldCell;
}
- (NSUInteger)displayedImagePosition;
- (BOOL)isEnabled;
- (BOOL)isSelected;
- (BOOL)isRightCap;
- (BOOL)isLeftCap;
- (NSRect)titleRectForCellFrame:(NSRect)aFrame;
- (id)newBackgroundImage;
- (id)pushedBackgroundImage;
- (id)backgroundImage;
- (id)textFieldCell;
- (void)loadDefaultImages;
- (void)setupTextFieldCell;
- (void)applyDefaultSettings;
- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView;
- (void)drawWithFrame:(NSRect)aFrame inView:(id)aView;
- (void)setTitle:(id)aTitle;
- (void)setAlignment:(NSUInteger)aAlignment;
- (void)setFormatter:(id)aFormatter;
- (void)dismissPopUp;
- (void)attachPopUpWithFrame:(NSRect)aFrame inView:(id)aView;
- (id)textRenderCell;
- (void)setDrawsText:(BOOL)aText;
- (BOOL)drawsText;
- (void)setBackgroundRenderer:(id)aRenderer;
- (id)backgroundRenderer;
- (void)dealloc;
- (id)initWithCoder:(id)aCoder;
@end

