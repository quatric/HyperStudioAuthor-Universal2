#import "HyperEditorBasePrefix.h"


@interface HSAttributeTextField : NSTextField
{
    BOOL _hasMultipleValues;
    NSFormatter *_storedFormatter;
    NSString *_placeholderString;
}
- (id)newPlaceholderStringFromNumberFormatter;
- (void)textDidChange:(id)aChange;
- (BOOL)sendAction:(SEL)aAction to:(id)aTo;
- (void)setHasMultipleValues:(BOOL)aValues;
- (BOOL)hasMultipleValues;
- (void)dealloc;
@end

