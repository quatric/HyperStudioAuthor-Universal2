#import "HyperStudioPrefix.h"


@interface HSURLLinkButton : NSButton
{
    NSURL *_URL;
    int _toolTipTag;
}
- (void)dealloc;
- (void)drawRect:(NSRect)aRect;
- (BOOL)sendAction:(SEL)aAction to:(id)aTo;
- (id)URL;
- (void)setURL:(id)aURL;
- (void)resetCursorRects;
- (void)setEnabled:(BOOL)aEnabled;
- (void)awakeFromNib;
@end

