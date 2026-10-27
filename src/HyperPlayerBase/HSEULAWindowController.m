#import "HSEULAWindowController.h"
@implementation HSEULAWindowController
- (void)setEULAAttributedString:(id)aString
{
    NSTextStorage *storage = [_eulaTextView textStorage];
    [storage replaceCharactersInRange:NSMakeRange(0, [storage length]) withAttributedString:aString];
}
- (void)setEULATitle:(id)aTitle
{
    [_eulaTitleField setStringValue:aTitle];
}
- (void)setEULAWindowTitle:(id)aTitle
{
    [[self window] setTitle:aTitle];
}
// The window runs modally: the buttons end the session with 0 / 1.
- (void)disagree:(id)aDisagree
{
    if ([NSApp modalWindow] == [self window]) {
        [[self window] close];
        [NSApp stopModalWithCode:0];
    }
}
- (void)agree:(id)aAgree
{
    if ([NSApp modalWindow] == [self window]) {
        [[self window] close];
        [NSApp stopModalWithCode:1];
    }
}
- (id)windowNibName
{
    return @"EULAWindow";
}
@end
