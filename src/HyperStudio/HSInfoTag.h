#import "HyperStudioPrefix.h"


@interface HSInfoTag : NSObject <NSWindowDelegate, NSObject, NSTextViewDelegate, NSTextDelegate>
{
    NSWindow *_window;
    id _backgroundView;
    NSTextView *_tagView;
    NSTextStorage *_tagStorage;
    NSWindow *_ownersWindow;
}
+ (void)setDefaultColor:(id)aColor;
+ (id)defaultColor;
+ (void)setDefaultFont:(id)aFont;
+ (id)defaultFont;
+ (id)sharedInstance;
- (void)windowDidResignKey:(id)aKey;
- (void)windowDidUpdate:(id)aUpdate;
- (void)setBorderColor:(id)aColor;
- (id)borderColor;
- (void)setBackgroundColor:(id)aColor;
- (id)backgroundColor;
- (void)hideWithFadeOutEffect;
- (void)hide;
- (void)showTaggedToRightSideOfRect:(NSRect)aRect inView:(id)aView;
- (void)showWithAlignRelativeToRect:(NSRect)aRect inView:(id)aView;
- (void)showWithTopLeft:(NSPoint)aLeft attributedTitle:(id)aTitle;
- (void)showWithTopLeft:(NSPoint)aLeft title:(id)aTitle;
- (void)showWithTopLeft:(NSPoint)aLeft inView:(id)aView;
- (void)showWithTopLeft:(NSPoint)aLeft;
- (BOOL)isVisible;
- (void)sizeToWidth:(CGFloat)aWidth;
- (void)sizeToMaxWidth:(CGFloat)aWidth;
- (void)sizeToFit;
- (void)setSize:(NSSize)aSize;
- (NSSize)size;
- (id)window;
- (void)setAttributedTitle:(id)aTitle;
- (id)attributedTitle;
- (void)setTitle:(id)aTitle;
- (id)title;
- (id)_window;
- (id)_backgroundView;
- (id)_tagView;
- (id)_tagStorage;
- (void)_sizeWindowToFitContent;
- (NSSize)contentSizeForMaxWidth:(CGFloat)aWidth;
- (void)dealloc;
- (id)init;
@end

