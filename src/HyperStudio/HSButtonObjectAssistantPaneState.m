#import "HSButtonObjectAssistantPaneState.h"

@implementation HSButtonObjectAssistantPaneState

- (void)setHighlight:(BOOL)aHighlight
{
    if (_highlight != aHighlight)
        _highlight = aHighlight;
}

- (BOOL)highlight
{
    return _highlight;
}

- (void)setTitleVisible:(BOOL)aVisible
{
    if (_titleVisible != aVisible)
        _titleVisible = aVisible;
}

- (BOOL)titleVisible
{
    return _titleVisible;
}

- (void)setBackgrounStyle:(id)aStyle withButtonType:(id)aType
{
    [self setBackgroundStyle:aStyle];
    [self setButtonType:aType];
}

- (void)setButtonType:(id)aType
{
    if (_buttonType != aType) {
        [_buttonType release];
        _buttonType = [aType retain];
    }
}

- (id)buttonType
{
    return _buttonType;
}

- (void)setBackgroundStyle:(id)aStyle
{
    if (_backgroundStyle != aStyle) {
        [_backgroundStyle release];
        _backgroundStyle = [aStyle retain];
    }
}

- (id)backgroundStyle
{
    return _backgroundStyle;
}

- (id)copyWithZone:(NSZone *)aZone
{
    HSButtonObjectAssistantPaneState *copy = [[[self class] allocWithZone:aZone] init];
    [copy setBackgroundStyle:[self backgroundStyle]];
    [copy setButtonType:[self buttonType]];
    [copy setTitleVisible:[self titleVisible]];
    [copy setHighlight:[self highlight]];
    return copy;
}

- (void)dealloc
{
    [_backgroundStyle release];
    [_buttonType release];
    [super dealloc];
}

@end
