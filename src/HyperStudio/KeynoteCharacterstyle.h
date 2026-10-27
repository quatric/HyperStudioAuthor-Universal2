#import "HyperStudioPrefix.h"
#import "KeynoteStyle.h"


@interface KeynoteCharacterstyle : KeynoteStyle
{
    KeynoteStyle *_paragraphStyle;
}
- (id)deepStringAttributes;
- (id)paragraphStyle;
- (void)setParagraphStyle:(id)aStyle;
@end

