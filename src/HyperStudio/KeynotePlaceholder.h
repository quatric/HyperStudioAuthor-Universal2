#import "HyperStudioPrefix.h"
#import "KeynoteItem.h"


@interface KeynotePlaceholder : KeynoteItem <KeynoteTextContainer, NSObject>
{
    NSAttributedString *_text;
}
- (id)textBackgroundColor;
- (id)textBody;
- (id)createText;
- (NSUInteger)verticalAlignment;
- (id)text;
- (BOOL)exportsText;
- (id)geometry;
- (id)slideStyle;
- (id)style;
- (void)dealloc;
@end

