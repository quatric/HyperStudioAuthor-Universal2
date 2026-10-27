#import "HSSegmentScrollView.h"

@implementation HSSegmentScrollView

+ (id)valueScaleSliderBorderColor
{
    static NSColor *sBorderColor = nil;

    if (sBorderColor == nil)
        sBorderColor = [[NSColor colorWithCalibratedWhite:0.56f alpha:1.0f] retain];
    return sBorderColor;
}

+ (NSSize)valueScaleSliderSize
{
    return NSMakeSize(80.0f, 17.0f);
}

- (void)drawRect:(NSRect)aRect
{
    [super drawRect:aRect];

    CGFloat height = [[self horizontalScroller] frame].size.height;
    NSSize sliderSize = [[self class] valueScaleSliderSize];
    CGFloat y = [[self horizontalScroller] frame].origin.y;
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect(1.5f, y - 0.5f, sliderSize.width - 2.0f, height + 1.0f)];

    [[NSColor colorWithCalibratedWhite:0.9f alpha:1.0f] set];
    [path fill];
    [(NSColor *)[[self class] valueScaleSliderBorderColor] set];
    [path stroke];
}

// The horizontal scroller gives up its left part to the value scale slider.
- (void)tile
{
    [super tile];

    NSScroller *scroller = [self horizontalScroller];
    NSRect frame = [scroller frame];

    frame.origin.x = [[self class] valueScaleSliderSize].width;
    frame.size.width = [self frame].size.width - [[self class] valueScaleSliderSize].width;
    [scroller setFrame:frame];
}

- (void)awakeFromNib
{
    NSRect frame = [[self horizontalScroller] frame];
    NSSize size = [[self class] valueScaleSliderSize];

    _valueScaleSlider = [[NSSlider alloc] initWithFrame:NSMakeRect(frame.origin.x + 10.0f, frame.origin.y, size.width - 20.0f, size.height)];
    [[_valueScaleSlider cell] setControlSize:NSMiniControlSize];
    [_valueScaleSlider setMinValue:0.0];
    [_valueScaleSlider setMaxValue:1.0];
    [_valueScaleSlider setTarget:[self documentView]];
    [_valueScaleSlider setAction:@selector(onChangeValueScale:)];
    [self addSubview:_valueScaleSlider];
}

- (id)valueScaleSlider
{
    return _valueScaleSlider;
}

- (void)dealloc
{
    [_valueScaleSlider release];
    [super dealloc];
}

@end
