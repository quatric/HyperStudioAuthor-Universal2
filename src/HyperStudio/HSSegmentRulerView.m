#import "HSSegmentRulerView.h"

@interface NSObject (HSSegmentRulerViewDataSource)
- (BOOL)shouldAllowInteraction;
@end

static BOOL HSSegmentRulerLess(float a, float b)
{
    float tolerance = MAX(a != 0.0f ? fabsf(a) : 1.0f, b != 0.0f ? fabsf(b) : 1.0f) * 0.0005f;
    return a < b - tolerance;
}

@implementation HSSegmentRulerView

+ (id)minusImage
{
    static NSImage *minusImage;
    if (minusImage == nil)
        minusImage = [[NSImage imageNamed:@"AnimationEditingMinus"] retain];
    return minusImage;
}

+ (id)plusImage
{
    static NSImage *plusImage;
    if (plusImage == nil)
        plusImage = [[NSImage imageNamed:@"AnimationEditingPlus"] retain];
    return plusImage;
}

- (void)refreshPlusMinus
{
    BOOL visible = [self arePlusMinusVisible];
    [_leftPlusMinusButton setHidden:!visible];
    [_rightPlusMinusButton setHidden:!visible];
    if (visible) {
        [_leftPlusMinusButton setFrame:[self leftPlusMinusFrame]];
        [_rightPlusMinusButton setFrame:[self rightPlusMinusFrame]];
    }
}

- (NSRect)rightPlusMinusFrame
{
    NSRect frame = [self leftPlusMinusFrame];
    frame.origin.x += 16.0;
    return frame;
}

- (NSRect)leftPlusMinusFrame
{
    NSRange selection = [_segmentView selectedSegments];
    float x = floorf([_segmentView xForValue:[_segmentView pegValueAtIndex:selection.location]]);
    NSRect bounds = [self bounds];
    return NSMakeRect(x + 0.5f, bounds.size.height - 1.0f - 14.0f, 16.0, 14.0);
}

- (BOOL)arePlusMinusVisible
{
    return [_segmentView selectedSegments].length != 0;
}

- (void)createPlusMinusButton:(id *)aButton image:(id)aImage action:(SEL)aAction
{
    NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(0.0, 0.0, 16.0, 14.0)];
    *aButton = button;
    [button setHidden:YES];
    [button setBordered:NO];
    [button setButtonType:NSButtonTypeMomentaryChange];
    [button setImagePosition:NSImageOnly];
    [button setImage:aImage];
    [button setContinuous:YES];
    [button setAction:aAction];
    [button setTarget:_segmentView];
    [self addSubview:button];
}

- (void)drawRect:(NSRect)aRect
{
    [[NSColor colorWithCalibratedWhite:0.9 alpha:1.0] set];
    NSRectFill(aRect);
    double value = [_segmentView firstPrimaryValue];
    double interval = [_segmentView primaryInterval];
    double scale = [_segmentView scale];
    NSUInteger secondaryCount = [_segmentView secondaryCount];
    NSBezierPath *path = [NSBezierPath bezierPath];
    float firstX = [_segmentView xForValue:[_segmentView firstPrimaryValue]];
    NSRect bounds = [self bounds];
    float majorStep = (float)(interval * scale);
    float minorStep = majorStep / (float)secondaryCount;
    float x = firstX;
    while (x >= NSMinX(bounds))
        x -= minorStep;
    for (; x < NSMaxX(bounds); x += minorStep) {
        if (x < NSMinX(bounds) || HSSegmentRulerLess(x, firstX))
            continue;
        float tickX = floorf(x) + 0.5f;
        float remainder = (float)fmod(x - firstX, majorStep);
        if (fabsf(remainder) <= 0.001f || fabsf(fabsf(remainder) - majorStep) <= 0.001f) {
            double rounded = trunc(value * 1000.0 + (value >= 0.0 ? 0.0005 : -0.0005)) / 1000.0;
            [path moveToPoint:NSMakePoint(tickX, aRect.origin.y)];
            [path lineToPoint:NSMakePoint(tickX, 10.0)];
            [[[NSNumber numberWithDouble:rounded] stringValue] drawAtPoint:NSMakePoint(tickX + 1.0f, 10.0) withAttributes:[self textAttributes]];
            value += [_segmentView primaryInterval];
        } else {
            [path moveToPoint:NSMakePoint(tickX, aRect.origin.y)];
            [path lineToPoint:NSMakePoint(tickX, 5.0)];
        }
    }
    [[NSColor colorWithCalibratedWhite:0.5 alpha:1.0] set];
    [path stroke];
}

- (id)textAttributes
{
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:8.0], NSFontAttributeName, nil];
}

- (void)refreshCurrentValue
{
    [_currentValueSlider setDoubleValue:[_segmentView currentValue]];
}

- (void)refresh
{
    float start = (float)[_segmentView startValue];
    float end = (float)([_segmentView startValue] + [_segmentView totalDuration]);
    float knob = (float)[_currentValueSlider knobThickness];
    float startX = [_segmentView xForValue:start];
    float width = roundf([_segmentView xForValue:end] - [_segmentView xForValue:start] + knob);
    if (HSSegmentRulerLess(width, 17.0f))
        width = 18.0f;
    [_currentValueSlider setFrame:NSMakeRect(startX - knob * 0.5f, NSZeroRect.origin.y, width, 17.0)];
    [_currentValueSlider setMinValue:start];
    [_currentValueSlider setMaxValue:end];
    [_currentValueSlider setDoubleValue:[_segmentView currentValue]];
    [_currentValueSlider setEnabled:[[_segmentView dataSource] shouldAllowInteraction]];
    [self refreshPlusMinus];
}

- (void)setupSlider
{
    if (_currentValueSlider != nil)
        return;
    HSSegmentViewSliderCell *cell = [[HSSegmentViewSliderCell new] autorelease];
    [cell setControlSize:NSControlSizeSmall];
    [cell setNumberOfTickMarks:1];
    [cell setContinuous:YES];
    [cell setDelegate:_segmentView];
    float knob = (float)[cell knobThickness];
    float width = [self bounds].size.width + knob;
    if (HSSegmentRulerLess(width, 20.0f))
        width = 21.0f;
    _currentValueSlider = [[[NSSlider alloc] initWithFrame:NSMakeRect(knob * -0.5f, 0.0, width, 20.0)] autorelease];
    [_currentValueSlider setCell:cell];
    [self addSubview:_currentValueSlider];
}

- (void)dealloc
{
    [_leftPlusMinusButton release];
    [_rightPlusMinusButton release];
    [super dealloc];
}

- (id)initWithFrame:(NSRect)aFrame segmentView:(id)aView
{
    self = [super initWithFrame:aFrame];
    if (self != nil) {
        _segmentView = aView;
        [self setupSlider];
        [self createPlusMinusButton:&_leftPlusMinusButton image:[[self class] plusImage] action:@selector(onPlus:)];
        [self createPlusMinusButton:&_rightPlusMinusButton image:[[self class] minusImage] action:@selector(onMinus:)];
    }
    return self;
}

@end
