#import "HyperStudioPrefix.h"
#import "KeynoteObject.h"


@interface KeynoteParagraph : KeynoteObject
{
    KeynoteStylesheet *_stylesheet;
    NSDictionary *_topicsInfo;
}
- (void)applyListLevel:(NSInteger)aLevel withStringAttributes:(id)aAttributes toMutableAttributedString:(id)aString;
- (id)attributedText;
- (void)setTopicsInfo:(id)aInfo;
- (id)topicsInfo;
- (id)style;
- (id)stylesheet;
- (void)setStylesheet:(id)aStylesheet;
@end

