#import "HSNoResponderTextField.h"

@implementation HSNoResponderTextField

- (id)undoManagerForTextView:(id)aView
{
    if (![[self delegate] respondsToSelector:@selector(undoManagerForTextFiled:editor:)])
        return nil;
    return [(id)[self delegate] undoManagerForTextFiled:self editor:aView];
}

- (BOOL)textView:(id)aView shouldHyperDocumentBackgroundColor:(id)aColor
{
    if (![[self delegate] respondsToSelector:@selector(textField:shouldHyperDocumentBackgroundColor:)])
        return YES;
    return (BOOL)(intptr_t)[(id)[self delegate] textField:self shouldHyperDocumentBackgroundColor:aColor];
}

- (BOOL)textView:(id)aView shouldHyperChangeAttributes:(id)aAttributes
{
    if (![[self delegate] respondsToSelector:@selector(textField:shouldHyperChangeAttributes:)])
        return YES;
    return (BOOL)(intptr_t)[(id)[self delegate] textField:self shouldHyperChangeAttributes:aAttributes];
}

- (BOOL)textView:(id)aView shouldHyperChangeFont:(id)aFont
{
    if (![[self delegate] respondsToSelector:@selector(textField:shouldHyperChangeFont:)])
        return YES;
    return (BOOL)(intptr_t)[(id)[self delegate] textField:self shouldHyperChangeFont:aFont];
}

- (BOOL)textView:(id)aView shouldHyperChangeColor:(id)aColor
{
    if (![[self delegate] respondsToSelector:@selector(textField:shouldHyperChangeColor:)])
        return YES;
    return (BOOL)(intptr_t)[(id)[self delegate] textField:self shouldHyperChangeColor:aColor];
}

// Refuses focus while the field is not in a window.
- (BOOL)becomeFirstResponder
{
    if ([self window] == nil)
        return NO;
    return [super becomeFirstResponder];
}

@end
