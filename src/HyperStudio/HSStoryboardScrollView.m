#import "HSStoryboardScrollView.h"

@implementation HSStoryboardScrollView

- (void)tile
{
    [super tile];

    NSScroller *scroller = [self horizontalScroller];
    NSRect frame = [scroller frame];
    CGFloat side = frame.size.height;
    CGFloat sliderWidth = side * -2.0f + 150.0f;

    [scroller setFrameSize:NSMakeSize(frame.size.width - 150.0f, frame.size.height)];
    [scroller setFrameOrigin:NSMakePoint(frame.origin.x + 150.0f, frame.origin.y)];

    CGFloat y = [self bounds].size.height - side;

    [[self scaleSlider] setFrame:NSInsetRect(NSMakeRect(side, y, sliderWidth, side), floorf(side * 0.5f), 0.0f)];

    if (_leftImageView == nil) {
        _leftImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 1, 1)];
        [_leftImageView setImage:[NSImage imageNamed:@"smaller"]];
        [self addSubview:_leftImageView];
    }
    [_leftImageView setFrame:NSMakeRect(0.0f, y, side, side)];

    if (_rightImageView == nil) {
        _rightImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 1, 1)];
        [_rightImageView setImage:[NSImage imageNamed:@"larger"]];
        [self addSubview:_rightImageView];
    }
    [_rightImageView setFrame:NSMakeRect(side + sliderWidth, y, side, side)];
}

- (id)scaleSlider
{
    if (_scaleSlider == nil) {
        _scaleSlider = [[NSSlider alloc] initWithFrame:NSMakeRect(0, 0, 1, 1)];
        [[_scaleSlider cell] setControlSize:NSSmallControlSize];
        [_scaleSlider setMinValue:0.1];
        [_scaleSlider setMaxValue:1.0];
        [_scaleSlider bind:@"value" toObject:[self storyboardView] withKeyPath:@"cardScaleFactor" options:nil];
        [self addSubview:_scaleSlider];
    }
    return _scaleSlider;
}

- (void)setStoryboardView:(id)aView
{
    if (_storyboardView != aView) {
        [_storyboardView release];
        _storyboardView = [aView retain];
    }
}

- (id)storyboardView
{
    return _storyboardView;
}

- (void)dealloc
{
    [_scaleSlider unbind:@"value"];
    [_scaleSlider release];
    [_storyboardView release];
    [_leftImageView release];
    [_rightImageView release];
    [super dealloc];
}

- (id)initWithFrame:(NSRect)aFrame storyboardView:(id)aView
{
    self = [super initWithFrame:aFrame];
    if (self != nil)
        [self setStoryboardView:aView];
    return self;
}

@end
