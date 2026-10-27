#import "HyperStudioPrefix.h"
#import "HSCropImageDialogController.h"


@protocol HSImageCropViewDelegate <NSObject>
@optional
- (void)selectionDidUpdateInView:(id)aView;
- (void)scaleFactorDidChangeInView:(id)aView;
- (void)mouseEntered:(id)aEvent inView:(id)aView;
@end

@interface HSWebAppIconEditorDialogController : HSCropImageDialogController <HSImageCropViewDelegate>
{
    NSTextField *_infoLabel;
    HSTintedView *_cardIndexContainerView;
    HSCardIndexScrollView *_stripScrollView;
    HSWebAppIconShadowView *_shadowView;
    HSWebAppIconPreviewView *_webAppIconPreviewView;
    NSArray *_cards;
    NSArray *_cardImages;
}
- (id)init;
- (id)windowNibName;
- (void)awakeFromNib;
- (id)defaultCropTool;
- (id)contentBackgroundPattern;
- (id)contentBackgroundColor;
- (id)webAppIcon;
- (void)setCards:(id)aCards;
- (id)cardImages;
- (void)setCardImages:(id)aImages;
- (void)selectCardWithIndex:(NSUInteger)aIndex;
- (void)updateShadowPath;
- (void)selectionDidUpdateInView:(id)aView;
- (void)scaleFactorDidChangeInView:(id)aView;
- (void)mouseEntered:(id)aEvent inView:(id)aView;
- (void)openHelp:(id)aSender;
- (NSUInteger)numberOfRowsInMediaStrip:(id)aStrip;
- (NSSize)mediaStrip:(id)aStrip imageSizeForItemAtIndex:(NSUInteger)aIndex;
- (id)mediaStrip:(id)aStrip imageForItemAtIndex:(NSUInteger)aIndex;
- (id)mediaStrip:(id)aStrip labelForItemAtIndex:(NSUInteger)aIndex;
- (void)mediaStrip:(id)aStrip clickedOnItemAtIndex:(NSUInteger)aIndex insideImage:(BOOL)aInside;
- (void)mediaStrip:(id)aStrip doubleClickedOnItemAtIndex:(NSUInteger)aIndex insideImage:(BOOL)aInside modifiers:(NSUInteger)aModifiers;
- (void)windowDidResize:(id)aNotification;
- (void)dealloc;
@end
