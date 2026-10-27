#import "HSAlertView.h"
// An alert's content: bold message, informative text, an optional custom
// view, optional bottom text and a "Don't show again" check box, stacked
// top-down. -layoutAll also resizes the window (keeping its top) to fit.
@implementation HSAlertView
// (A resize ends a pending full layout.)
- (void)setFrameSize:(NSSize)aSize
{
    [super setFrameSize:aSize];
    if (_layoutAll)
        _layoutAll = NO;
}
- (void)setDoNotShowAgainPreferenceKey:(id)aKey
{
    if (_doNotShowAgainPreferenceKey == aKey)
        return;
    if (aKey == nil) {
        [_doNotShowAgainPreferenceKey release];
        _doNotShowAgainPreferenceKey = nil;
        if (_doNotShowAgainCheckBox == nil)
            return;
        [_doNotShowAgainCheckBox removeFromSuperview];
        _doNotShowAgainCheckBox = nil;
        [self layoutAll];
        return;
    }
    if ([_doNotShowAgainPreferenceKey isEqualToString:aKey])
        return;
    NSString *key = [aKey copy];
    if (key == nil)
        return;
    [_doNotShowAgainPreferenceKey release];
    _doNotShowAgainPreferenceKey = key;
    if (_doNotShowAgainCheckBox != nil) {
        [_doNotShowAgainCheckBox setState:[[NSUserDefaults standardUserDefaults] boolForKey:_doNotShowAgainPreferenceKey]];
        return;
    }
    _doNotShowAgainCheckBox = [[NSButton allocWithZone:[self zone]] init];
    if (_doNotShowAgainCheckBox == nil)
        return;
    [_doNotShowAgainCheckBox setButtonType:NSButtonTypeSwitch];
    [_doNotShowAgainCheckBox setAutoresizingMask:NSViewMaxXMargin | NSViewMaxYMargin];
    [_doNotShowAgainCheckBox setTitle:[[NSBundle mainBundle] localizedStringForKey:@"HSDontShowAgainCheckBoxTitle" value:@"" table:@"Alerts"]];
    [_doNotShowAgainCheckBox setFrameSize:[[_doNotShowAgainCheckBox cell] cellSize]];
    [_doNotShowAgainCheckBox setTarget:self];
    [_doNotShowAgainCheckBox setAction:@selector(HSAlertView_doNotShowAgain:)];
    [self addSubview:_doNotShowAgainCheckBox];
    [_doNotShowAgainCheckBox release];
    [self layoutAll];
}
- (id)doNotShowAgainPreferenceKey
{
    return _doNotShowAgainPreferenceKey;
}
- (void)HSAlertView_doNotShowAgain:(id)aAgain
{
    if (_doNotShowAgainPreferenceKey != nil)
        [[NSUserDefaults standardUserDefaults] setBool:[aAgain state] == NSControlStateValueOn forKey:_doNotShowAgainPreferenceKey];
}
- (void)setBottomInformativeText:(id)aText
{
    if (aText == nil) {
        if (_bottomInformativeTextView == nil)
            return;
        [_bottomInformativeTextView removeFromSuperview];
        _bottomInformativeTextView = nil;
    } else {
        if (_bottomInformativeTextView == nil) {
            _bottomInformativeTextView = [[HSNonOpaqueTextView allocWithZone:[self zone]] initWithFrame:NSZeroRect];
            [self setupTextView:_bottomInformativeTextView];
            [self addSubview:_bottomInformativeTextView];
            [_bottomInformativeTextView release];
            [_bottomInformativeTextView setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
        }
        NSFont *font = [NSFont systemFontOfSize:[NSFont smallSystemFontSize]];
        if (font == nil)
            return;
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:aText attributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil]];
        [[_bottomInformativeTextView textStorage] setAttributedString:string];
        [string release];
    }
    [self layoutAll];
}
- (id)bottomInformativeText
{
    return [[_bottomInformativeTextView textStorage] string];
}
- (void)setInformativeText:(id)aText
{
    NSFont *font = [NSFont systemFontOfSize:[NSFont smallSystemFontSize]];
    if (font == nil)
        return;
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:aText attributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil]];
    [[_informativeTextView textStorage] setAttributedString:string];
    [string release];
    [self layoutAll];
}
- (id)informativeText
{
    return [[_informativeTextView textStorage] string];
}
- (void)setMessageText:(id)aText
{
    NSFont *font = [NSFont boldSystemFontOfSize:[NSFont systemFontSize]];
    if (font == nil)
        return;
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:aText attributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil]];
    [[_messageTextView textStorage] setAttributedString:string];
    [string release];
    [self layoutAll];
}
- (id)messageText
{
    return [[_messageTextView textStorage] string];
}
- (void)setCustomView:(id)aView
{
    if (_customView == aView)
        return;
    [_customView removeFromSuperview];
    [_customView release];
    _customView = [aView retain];
    [self addSubview:_customView];
    [_customView setAutoresizesSubviews:YES];
    [self layoutAll];
}
- (id)customView
{
    return _customView;
}
// Heights add up with 8-point gaps; the informative text grows to meet the
// window's minimum height. An empty custom view gets 20 points; otherwise
// (outside a full layout) it fills the rest. Only a full layout resizes the
// window, this view and the custom view.
- (void)layout
{
    NSRect frame = [self frame];
    NSSize messageSize = [self sizeForTextView:_messageTextView];
    NSRect windowFrame = [[self window] frame];
    NSSize minSize = [[self window] minSize];
    NSSize informativeSize = [self sizeForTextView:_informativeTextView];
    float informativeHeight = (float)informativeSize.height;
    float height = (float)messageSize.height + informativeHeight + 8;
    NSSize bottomSize = _bottomInformativeTextView != nil ? [self sizeForTextView:_bottomInformativeTextView] : NSZeroSize;
    if (_bottomInformativeTextView != nil)
        height += (float)bottomSize.height + 8;
    float checkBoxSpace;
    if (_doNotShowAgainCheckBox == nil)
        checkBoxSpace = 8;
    else {
        checkBoxSpace = (float)[_doNotShowAgainCheckBox frame].size.height + 8;
        height += checkBoxSpace;
    }
    float viewHeight = (float)frame.size.height;
    float windowContentHeight = ((float)windowFrame.size.height + height) - viewHeight;
    if ((float)minSize.height > windowContentHeight) {
        float extra = (float)minSize.height - windowContentHeight;
        height += extra;
        informativeHeight += extra;
    }
    NSSize customSize = NSZeroSize;
    if (_customView != nil) {
        customSize = [_customView frame].size;
        if (NSEqualSizes(customSize, NSZeroSize))
            customSize.height = 20;
        else if (!_layoutAll)
            customSize.height = viewHeight - 8;
        if ((float)informativeSize.width >= (float)customSize.width)
            customSize.width = informativeSize.width;
        height += (float)customSize.height + 8;
    }
    float top = viewHeight;
    if (_layoutAll) {
        float growth = height - viewHeight;
        windowFrame.size.height = (float)windowFrame.size.height + growth;
        windowFrame.origin.y = (float)windowFrame.origin.y - growth;
        if (_customView != nil)
            [_customView setFrame:NSMakeRect(0, (((height - (float)messageSize.height) - informativeHeight) - 8 - (float)customSize.height) - 8, customSize.width, customSize.height)];
        [[self window] setFrame:windowFrame display:YES];
        frame.size.height = height;
        [self setFrame:frame];
        top = height;
    }
    top -= (float)messageSize.height;
    [_messageTextView setFrameOrigin:NSMakePoint(0, top)];
    [_messageTextView setFrameSize:messageSize];
    top -= informativeHeight + 8;
    [_informativeTextView setFrameOrigin:NSMakePoint(0, top)];
    [_informativeTextView setFrameSize:NSMakeSize(informativeSize.width, informativeHeight)];
    if (_customView != nil)
        top -= (float)customSize.height + 8;
    if (_bottomInformativeTextView != nil) {
        top -= (float)bottomSize.height + 8;
        [_bottomInformativeTextView setFrameOrigin:NSMakePoint(0, top)];
        [_bottomInformativeTextView setFrameSize:bottomSize];
    }
    if (_doNotShowAgainCheckBox != nil)
        [_doNotShowAgainCheckBox setFrameOrigin:NSMakePoint(0, top - checkBoxSpace)];
}
- (void)layoutAll
{
    _layoutAll = YES;
    [self layout];
}
// The text's height at this view's width.
- (NSSize)sizeForTextView:(id)aView
{
    return [NSTextStorage hyperSizeForTextStorage:[aView textStorage] withWidth:[self frame].size.width fixedWidth:YES];
}
- (void)setupTextView:(id)aView
{
    [aView setUsesFindPanel:NO];
    [aView setHorizontallyResizable:NO];
    [aView setVerticallyResizable:NO];
    [aView setEditable:NO];
    [aView setSelectable:NO];
    [aView setAllowsUndo:NO];
    [aView setDelegate:self];
    [aView setDrawsBackground:NO];
    [aView setNeverDrawsBackground:YES];
    [aView setTextContainerInset:NSZeroSize];
    [aView setAlignment:NSTextAlignmentLeft];
}
- (void)dealloc
{
    [_customView release];
    [_doNotShowAgainPreferenceKey release];
    [super dealloc];
}
- (id)initWithFrame:(NSRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self == nil)
        return nil;
    _messageTextView = [[HSNonOpaqueTextView allocWithZone:[self zone]] initWithFrame:NSZeroRect];
    [self setupTextView:_messageTextView];
    [self addSubview:_messageTextView];
    [_messageTextView release];
    [_messageTextView setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
    _informativeTextView = [[HSNonOpaqueTextView allocWithZone:[self zone]] initWithFrame:NSZeroRect];
    [self setupTextView:_informativeTextView];
    [self addSubview:_informativeTextView];
    [_informativeTextView release];
    [_informativeTextView setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
    return self;
}
@end
