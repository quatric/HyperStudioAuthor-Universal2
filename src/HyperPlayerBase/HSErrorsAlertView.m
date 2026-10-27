#import "HSErrorsAlertView.h"
// An alert's accessory view listing script errors. Each error is shown from a
// template (StandardTemplate.rtf in the simple view, else
// WarningTemplate.rtfd) whose <<…>> placeholders are filled in; every other
// error is highlighted. The text view's scroll view is shown and hidden by
// the expand button, growing the view downwards.
@implementation HSErrorsAlertView
- (void)setSimpleView:(BOOL)aView
{
    _isSimpleView = aView;
}
- (void)setScriptErrors:(id)aErrors
{
    if (_scriptErrors == aErrors)
        return;
    [_scriptErrors release];
    _scriptErrors = [aErrors retain];
    _errorsNumber = (unsigned int)[_scriptErrors count];
    [self setupOutput];
}
- (id)scriptErrors
{
    return _scriptErrors;
}
- (id)pathForResource:(id)aResource
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *name = [NSString stringWithString:aResource];
    return [bundle pathForResource:[name stringByDeletingPathExtension] ofType:[name pathExtension]];
}
// The placeholder's range; an exception counts as not found.
static NSRange HSErrorsAlertViewPlaceholderRange(NSAttributedString *aText, NSString *aPlaceholder)
{
    NSRange range = NSMakeRange(NSNotFound, 0);
    @try {
        range = [[aText string] rangeOfString:aPlaceholder];
    } @catch (NSException *exception) {
    }
    return range;
}
static BOOL HSErrorsAlertViewFound(NSRange aRange)
{
    return aRange.location != NSNotFound && aRange.length != 0;
}
// An error is a string (shown as the description only) or a script error,
// whose source code's first line goes in <<ContentLine1>> and the rest in
// <<ContentLine2>> (removed when there's no more; ended with a newline but
// for the last error). The original reads the template by its bare name
// (relative to the working directory) for script errors; it is always looked
// up in the bundle here.
- (void)setupOutput
{
    NSString *details = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Details" value:@"" table:@"Alerts"];
    [self setTitleText:[NSString stringWithFormat:details, _errorsNumber]];
    NSMutableArray *highlightedRanges = [NSMutableArray array];
    NSMutableAttributedString *text = [[NSMutableAttributedString new] autorelease];
    NSString *template = _isSimpleView ? @"StandardTemplate.rtf" : @"WarningTemplate.rtfd";
    for (NSUInteger i = 0; i < _errorsNumber; i++) {
        id error = [_scriptErrors objectAtIndex:i];
        BOOL isString = [error isKindOfClass:[NSString class]];
        NSMutableAttributedString *part = [[NSMutableAttributedString alloc] initWithPath:[self pathForResource:template] documentAttributes:NULL];
        NSRange range = HSErrorsAlertViewPlaceholderRange(part, @"<<#>>");
        if (HSErrorsAlertViewFound(range))
            [part replaceCharactersInRange:range withString:[NSString stringWithFormat:@"%d", (int)i + 1]];
        range = HSErrorsAlertViewPlaceholderRange(part, @"<<Reason>>");
        if (!isString && HSErrorsAlertViewFound(range))
            [part replaceCharactersInRange:range withString:[error levelString]];
        range = HSErrorsAlertViewPlaceholderRange(part, @"<<Error>>");
        if (!isString && HSErrorsAlertViewFound(range)) {
            NSString *message = [error shortMessage];
            [part replaceCharactersInRange:range withString:message != nil ? message : @""];
        }
        range = HSErrorsAlertViewPlaceholderRange(part, @"<<Description>>");
        if (HSErrorsAlertViewFound(range)) {
            NSString *message = isString ? error : [error message];
            [part replaceCharactersInRange:range withString:message != nil ? message : @""];
        }
        range = HSErrorsAlertViewPlaceholderRange(part, @"<<LineNumber>>");
        if (!isString && HSErrorsAlertViewFound(range))
            [part replaceCharactersInRange:range withString:[NSString stringWithFormat:@"%d", (int)[error line]]];
        range = HSErrorsAlertViewPlaceholderRange(part, @"<<ContentLine1>>");
        if (!isString && HSErrorsAlertViewFound(range)) {
            NSString *source = [error sourceCode];
            NSArray *lines = [source != nil ? source : @"" componentsSeparatedByString:@"\n"];
            [part replaceCharactersInRange:range withString:[lines objectAtIndex:0]];
            range = HSErrorsAlertViewPlaceholderRange(part, @"<<ContentLine2>>");
            if (HSErrorsAlertViewFound(range)) {
                if ([lines count] >= 2) {
                    NSMutableArray *rest = [NSMutableArray arrayWithArray:lines];
                    [rest removeObjectAtIndex:0];
                    if (i + 1 < _errorsNumber)
                        [rest addObject:@""];
                    [part replaceCharactersInRange:range withString:[rest componentsJoinedByString:@"\n"]];
                } else {
                    [part deleteCharactersInRange:range];
                }
            }
        }
        // the simple template's trailing newline isn't highlighted
        if (i & 1) {
            NSUInteger length = [part length];
            if (_isSimpleView)
                length--;
            [highlightedRanges addObject:[NSValue valueWithRange:NSMakeRange([text length], length)]];
        }
        [text appendAttributedString:part];
        [part release];
    }
    [[_textView textStorage] setAttributedString:text];
    [_textView setHighlitedRanges:highlightedRanges];
}
- (void)showTextView
{
    NSRect frame = [self frame];
    CGFloat height = _viewExpandedSize.height + 8.0;
    frame.origin.y -= height;
    frame.size.height += height;
    [self setFrame:frame];
    [self addSubview:_scrollView];
    _viewExpandedSize.width = frame.size.width - 8.0;
    [_scrollView setFrameSize:NSMakeSize(frame.size.width - 8.0, _viewExpandedSize.height)];
    [(id)[self superview] layoutAll];
}
- (void)hideTextView
{
    [_scrollView removeFromSuperview];
    NSRect frame = [self frame];
    CGFloat height = _viewExpandedSize.height + 8.0;
    frame.origin.y += height;
    frame.size.height -= height;
    [self setFrame:frame];
    [(id)[self superview] layoutAll];
}
- (void)setTitleText:(id)aText
{
    [_title setStringValue:aText];
}
- (id)titleText
{
    return [_title stringValue];
}
// Starts collapsed, remembering the scroll view's size. The scroll view is
// kept while out of the view (released in dealloc; the original retains it
// each time the view moves to a window, which only happens once for an
// alert).
- (void)viewWillMoveToWindow:(id)aWindow
{
    if (aWindow == nil)
        return;
    _viewExpandedSize = [_scrollView frame].size;
    [_scrollView retain];
    [self hideTextView];
}
- (void)dealloc
{
    [_scrollView release];
    [_scriptErrors release];
    [super dealloc];
}
@end
@implementation HSErrorsAlertView (IBActions)
- (void)onExpand:(id)aExpand
{
    if ([aExpand state] != NSOffState)
        [self showTextView];
    else
        [self hideTextView];
}
@end
