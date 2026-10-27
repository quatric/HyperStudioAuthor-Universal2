#import "HyperStudioPrefix.h"
#import "KeynoteObject.h"


@interface KeynoteItem : KeynoteObject
{
    NSString *_styleIdRef;
}
- (void)setStyleIdRef:(id)aRef;
- (id)styleIdRef;
- (id)hyperlink;
- (BOOL)isLocked;
- (id)themeStyle;
- (id)masterStyle;
- (id)style;
- (id)geometry;
- (id)slide;
- (id)slideStylesheet;
- (void)didDetail;
- (void)dealloc;
@end

