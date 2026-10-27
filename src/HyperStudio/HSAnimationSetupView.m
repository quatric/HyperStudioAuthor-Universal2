#import "HSAnimationSetupView.h"

@interface NSObject (HSAnimationSetupViewDataSource)
- (BOOL)shouldShowTrajectory;
@end

@implementation HSAnimationSetupView

+ (CGFloat)minSegmentDuration
{
    return kAnimationMinTimeIntervalBetweenKeyFrames;
}

- (void)stopBodyEditing
{
    if ([_delegate respondsToSelector:@selector(stopEditingAnimation)])
        [_delegate stopEditingAnimation];
}

- (void)continueBodyEditing
{
    if ([_delegate respondsToSelector:@selector(continueEditingAnimation)])
        [_delegate continueEditingAnimation];
}

- (void)startBodyEditing
{
    if ([_delegate respondsToSelector:@selector(startEditingAnimation)])
        [_delegate startEditingAnimation];
}

- (void)stopChangingCurrentValue:(CGFloat)aValue
{
    if ([_delegate respondsToSelector:@selector(stopChangingAnimationCurrentTime:)])
        [_delegate stopChangingAnimationCurrentTime:aValue];
    [self refresh];
}

- (void)continueChangingCurrentValue:(CGFloat)aValue
{
    if ([_delegate respondsToSelector:@selector(continueChangingAnimationCurrentTime:)])
        [_delegate continueChangingAnimationCurrentTime:aValue];
    [self refresh];
}

- (void)startChangingCurrentValue:(CGFloat)aValue
{
    if ([_delegate respondsToSelector:@selector(startChangingAnimationCurrentTime:)])
        [_delegate startChangingAnimationCurrentTime:aValue];
    [self refresh];
}

- (void)refresh
{
    BOOL showTrajectory = [[self dataSource] shouldShowTrajectory];
    for (NSView *subview in [self subviews])
        [subview setHidden:!showTrajectory];
    [self setValueScaleSliderEnabled:showTrajectory];
    [super refresh];
}

// Without a trajectory the view shows a centered hint instead of the segments.
- (void)drawRect:(NSRect)aRect
{
    if (![[self dataSource] shouldShowTrajectory]) {
        [[NSColor colorWithCalibratedWhite:0.85f alpha:1.0f] set];
        [[NSBezierPath bezierPathWithRect:aRect] fill];
        [_stringRenderer setContainerWidth:[self visibleRect].size.width];
        CGFloat height = [self bounds].size.height;
        NSRect textRect = [_stringRenderer boundingRectOfString:_emptyAnimationMessage];
        [_stringRenderer drawString:_emptyAnimationMessage atPoint:NSMakePoint(0.0, (height - textRect.size.height) * 0.5f) withColor:[NSColor darkGrayColor]];
        [(NSColor *)[HSSegmentScrollView valueScaleSliderBorderColor] set];
        NSRectFill(NSMakeRect(0.0, 0.0, [HSSegmentScrollView valueScaleSliderSize].width - 1.0f, 1.0));
    }
    [super drawRect:aRect];
}

- (void)enclosingScrollViewDidChangeFrame:(id)aFrame
{
    [self refresh];
}

- (void)awakeFromNib
{
    NSScrollView *scrollView = [self enclosingScrollView];
    if (scrollView != nil)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enclosingScrollViewDidChangeFrame:) name:NSViewFrameDidChangeNotification object:scrollView];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_emptyAnimationMessage release];
    [_stringRenderer release];
    [super dealloc];
}

- (id)initWithFrame:(NSRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self != nil) {
        _stringRenderer = [[SMKStringRenderer alloc] init];
        [_stringRenderer setAlignment:NSTextAlignmentCenter];
        [_stringRenderer setFont:[NSFont boldSystemFontOfSize:[NSFont systemFontSize]]];
        _emptyAnimationMessage = [[NSString alloc] initWithString:[[NSBundle mainBundle] localizedStringForKey:@"Click the card to start custom trajectory" value:@"" table:nil]];
        _lastPegCount = -1;
    }
    return self;
}

@end
