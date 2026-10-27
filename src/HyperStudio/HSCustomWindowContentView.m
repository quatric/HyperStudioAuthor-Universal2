#import "HSCustomWindowContentView.h"

static BOOL HSMarginsEqual(float a, float b)
{
    float tolerance = MAX(a != 0.0f ? fabsf(a) : 1.0f, b != 0.0f ? fabsf(b) : 1.0f) * 0.0005f;
    return fabsf(a - b) <= tolerance;
}

@implementation HSCustomWindowContentView

- (NSRect)applyMarginsToRect:(NSRect)aRect extend:(BOOL)aExtend
{
    CGFloat left = [self leftMargin];
    CGFloat bottom = [self bottomMargin];
    CGFloat horizontal = [self leftMargin] + [self rightMargin];
    CGFloat vertical = [self bottomMargin] + [self topMargin];
    if (aExtend)
        return NSMakeRect(aRect.origin.x - left, aRect.origin.y - bottom, aRect.size.width + horizontal, aRect.size.height + vertical);
    return NSMakeRect(aRect.origin.x + left, aRect.origin.y + bottom, aRect.size.width - horizontal, aRect.size.height - vertical);
}

- (void)setBottomMargin:(CGFloat)aMargin
{
    if (HSMarginsEqual([self bottomMargin], aMargin))
        return;
    _margins[3] = aMargin;
    [[self containerView] setFrame:[self applyMarginsToRect:[self frame] extend:NO]];
}

- (CGFloat)bottomMargin
{
    return _margins[3];
}

- (void)setTopMargin:(CGFloat)aMargin
{
    if (HSMarginsEqual([self topMargin], aMargin))
        return;
    _margins[2] = aMargin;
    [[self containerView] setFrame:[self applyMarginsToRect:[self frame] extend:NO]];
}

- (CGFloat)topMargin
{
    return _margins[2];
}

- (void)setRightMargin:(CGFloat)aMargin
{
    if (HSMarginsEqual([self rightMargin], aMargin))
        return;
    _margins[1] = aMargin;
    [[self containerView] setFrame:[self applyMarginsToRect:[self frame] extend:NO]];
}

- (CGFloat)rightMargin
{
    return _margins[1];
}

- (void)setLeftMargin:(CGFloat)aMargin
{
    if (HSMarginsEqual([self leftMargin], aMargin))
        return;
    _margins[0] = aMargin;
    [[self containerView] setFrame:[self applyMarginsToRect:[self frame] extend:NO]];
}

- (CGFloat)leftMargin
{
    return _margins[0];
}

- (void)addSubview:(id)aSubview positioned:(NSInteger)aPositioned relativeTo:(id)aTo
{
    [[self containerView] addSubview:aSubview positioned:aPositioned relativeTo:aTo];
}

- (void)addSubview:(id)aSubview
{
    [[self containerView] addSubview:aSubview];
}

- (id)containerView
{
    if (_containerView == nil) {
        _containerView = [[NSView alloc] initWithFrame:[self applyMarginsToRect:[self bounds] extend:YES]];
        [_containerView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [super addSubview:_containerView];
    }
    return _containerView;
}

- (void)dealloc
{
    [_containerView release];
    [super dealloc];
}

@end
