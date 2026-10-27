#import "HyperStudioPrefix.h"
#import "KeynoteObject.h"


@interface KeynoteTextBody : KeynoteObject
{
    KeynoteStylesheet *_stylesheet;
}
- (id)topicsInfo;
- (id)layout;
- (NSUInteger)verticalAlignment;
- (id)attributedText;
- (id)stylesheet;
- (void)setStylesheet:(id)aStylesheet;
@end

