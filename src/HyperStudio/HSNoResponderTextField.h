#import "HyperStudioPrefix.h"


@interface HSNoResponderTextField : NSTextField
{
}
- (id)undoManagerForTextView:(id)aView;
- (BOOL)textView:(id)aView shouldHyperDocumentBackgroundColor:(id)aColor;
- (BOOL)textView:(id)aView shouldHyperChangeAttributes:(id)aAttributes;
- (BOOL)textView:(id)aView shouldHyperChangeFont:(id)aFont;
- (BOOL)textView:(id)aView shouldHyperChangeColor:(id)aColor;
- (BOOL)becomeFirstResponder;
@end

