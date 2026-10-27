#import "HSRangeControl.h"
#import <objc/message.h>

// A movie range: the start and finish knobs of a range cell, moved by
// mouse or by arrow keys (up and down switch the focused knobs).

@implementation HSRangeControl

+ (Class)cellClass
{
    return [HSRangeCell class];
}

- (SEL)rightKnobClickAction
{
    return [(HSRangeCell *)[self cell] rightKnobClickAction];
}

- (void)setRightKnobClickAction:(SEL)aAction
{
    [(HSRangeCell *)[self cell] setRightKnobClickAction:aAction];
}

- (SEL)leftKnobClickAction
{
    return [(HSRangeCell *)[self cell] leftKnobClickAction];
}

- (void)setLeftKnobClickAction:(SEL)aAction
{
    [(HSRangeCell *)[self cell] setLeftKnobClickAction:aAction];
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

// The delegate's tooltip of the knob (0 left, 1 right), else the default.
- (NSString *)tooltipForKnob:(int)aKnob
{
    id delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(tooltipForKnob:)]) {
        NSString *tooltip = ((id (*)(id, SEL, int))objc_msgSend)(delegate, @selector(tooltipForKnob:), aKnob);
        if (tooltip != nil)
            return tooltip;
    }
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Drag this slider to mark the place where the movie will start or stop playing." value:@"" table:@"RangeControl"];
}

// Original quirk kept: the knob rects are in the frame, not the bounds.
- (void)setFinishTime:(double)aTime
{
    HSRangeCell *cell = [self cell];
    [cell setFinishTime:aTime];
    NSRect rect = [cell rightKnobRectInFrame:[self frame]];
    [self addToolTipRect:rect owner:[self tooltipForKnob:1] userData:NULL];
}

- (void)setStartTime:(double)aTime
{
    HSRangeCell *cell = [self cell];
    [cell setStartTime:aTime];
    NSRect rect = [cell leftKnobRectInFrame:[self frame]];
    [self removeAllToolTips];
    [self addToolTipRect:rect owner:[self tooltipForKnob:0] userData:NULL];
}

- (void)setDuration:(double)aDuration
{
    [(HSRangeCell *)[self cell] setDuration:aDuration];
}

- (double)finishTime
{
    return [(HSRangeCell *)[self cell] finishTime];
}

- (double)startTime
{
    return [(HSRangeCell *)[self cell] startTime];
}

- (double)duration
{
    return [(HSRangeCell *)[self cell] duration];
}

- (BOOL)isFlipped
{
    return YES;
}

- (BOOL)isOpaque
{
    return NO;
}

- (BOOL)needsPanelToBecomeKey
{
    return YES;
}

- (BOOL)acceptsFirstMouse:(id)aMouse
{
    return YES;
}

- (void)moveRightAndModifySelection:(id)aSelection
{
    [(HSRangeCell *)[self cell] shiftTimeBoundsForDelta:0.5];
}

- (void)moveRight:(id)aRight
{
    [(HSRangeCell *)[self cell] shiftTimeBoundsForDelta:0.05];
}

- (void)moveLeftAndModifySelection:(id)aSelection
{
    [(HSRangeCell *)[self cell] shiftTimeBoundsForDelta:-0.5];
}

- (void)moveLeft:(id)aLeft
{
    [(HSRangeCell *)[self cell] shiftTimeBoundsForDelta:-0.05];
}

// Focus goes left, right, both (1, 2, 3) and around.
- (void)moveDown:(id)aDown
{
    HSRangeCell *cell = [self cell];
    NSInteger knobs = [cell focusedKnobs];
    [cell setFocusedKnobs:knobs == 2 ? 3 : knobs == 3 ? 1 : 2];
    [self updateCellInside:cell];
}

- (void)moveUp:(id)aUp
{
    HSRangeCell *cell = [self cell];
    NSInteger knobs = [cell focusedKnobs];
    [cell setFocusedKnobs:knobs == 3 ? 2 : knobs == 1 ? 3 : 1];
    [self updateCellInside:cell];
}

// Tabs still move the focus.
- (void)doCommandBySelector:(SEL)aSelector
{
    if (aSelector != @selector(insertTab:) && aSelector != @selector(insertBacktab:))
        _didInterpretCurrentKeyDownEvent = YES;
    [super doCommandBySelector:aSelector];
}

- (void)keyDown:(id)aDown
{
    _didInterpretCurrentKeyDownEvent = NO;
    [self interpretKeyEvents:[NSArray arrayWithObject:aDown]];
    if (!_didInterpretCurrentKeyDownEvent)
        [super keyDown:aDown];
}

- (id)initWithFrame:(NSRect)aFrame
{
    if ((self = [super initWithFrame:aFrame]))
        [self setContinuous:YES];
    return self;
}

@end

@implementation HSRangeControl (Accessibility)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wdeprecated-implementations"

- (id)accessibilityAttributeValue:(id)aValue
{
    if ([aValue isEqualToString:NSAccessibilityRoleAttribute])
        return NSAccessibilityValueIndicatorRole;
    if ([aValue isEqualToString:NSAccessibilityDescriptionAttribute]) {
        unsigned int start = [[NSNumber numberWithFloat:[self startTime]] intValue];
        unsigned int finish = [[NSNumber numberWithFloat:[self finishTime]] intValue];
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *seconds = [bundle localizedStringForKey:@"seconds" value:@"" table:nil];
        NSString *to = [bundle localizedStringForKey:@"to" value:@"" table:nil];
        NSString *from = [bundle localizedStringForKey:@"From" value:@"" table:nil];
        return [NSString stringWithFormat:@"%@ %u %@ %@ %u %@", from, start, seconds, to, finish, seconds];
    }
    if ([aValue isEqualToString:NSAccessibilityRoleDescriptionAttribute])
        return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Range control" value:@"" table:@"RangeControl"];
    if ([aValue isEqualToString:NSAccessibilityTitleAttribute] || [aValue isEqualToString:NSAccessibilityHelpAttribute])
        return @"Movie Range Control";
    return [super accessibilityAttributeValue:aValue];
}

- (id)accessibilityFocusedUIElement
{
    return NSAccessibilityUnignoredAncestor(self);
}

- (id)accessibilityHitTest:(NSPoint)aTest
{
    return NSAccessibilityUnignoredAncestor(self);
}

- (BOOL)accessibilityIsIgnored
{
    return NO;
}

#pragma clang diagnostic pop

@end
