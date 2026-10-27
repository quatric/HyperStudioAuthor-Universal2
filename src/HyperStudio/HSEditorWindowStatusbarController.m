#import "HSEditorWindowStatusbarController.h"

// The percentage is whole when it equals its floor within a relative 0.0005.
static BOOL HSIsWholePercent(float aPercent)
{
    float whole = floorf(aPercent);
    float scale = MAX(whole != 0.0f ? fabsf(whole) : 1.0f, aPercent != 0.0f ? fabsf(aPercent) : 1.0f);

    return !(scale * 0.0005f < fabsf(whole - aPercent));
}

@implementation HSEditorWindowStatusbarController

- (void)didLoadNib
{
    [super didLoadNib];
    [_zoomToActualSizeCell setBackgroundRenderer:[HSCardNavigationControlBackgroundRenderer sharedBackgroundRenderer]];
}

- (void)setZoomControlsEnabled:(BOOL)aEnabled
{
    [super setZoomControlsEnabled:aEnabled];
    [_zoomPopUpButton setEnabled:aEnabled];
    [_zoomToActualSizeCell setEnabled:aEnabled];
    [_zoomToMinButton setEnabled:aEnabled];
    [_zoomToMaxButton setEnabled:aEnabled];
}

// Lists every zoom step, then "Fit In Window" (NaN); the slider's current zoom is selected.
- (void)setupScalePopUpButton
{
    const float tolerance = 0.0049f;
    float zoomFactor = 0.0f, nextFactor = 0.0f;
    BOOL isSelected = NO;

    while (1) {
        [HSEditorZoomController nextZoomOutFactor:NULL zoomInFactor:&nextFactor forZoomFactor:zoomFactor];
        if (isnan(nextFactor))
            break;
        float percent = nextFactor * 100.0f;
        NSString *format = HSIsWholePercent(percent) ? @"%.0f%%" : @"%.1f%%";
        NSMenuItem *item;

        [_zoomPopUpButton addItemWithTitle:[NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:format value:@"" table:nil], percent]];
        item = [_zoomPopUpButton lastItem];
        [item setRepresentedObject:[NSNumber numberWithFloat:nextFactor]];
        zoomFactor = nextFactor;
        if (fabsf(nextFactor - [_zoomSlider floatValue]) <= tolerance) {
            [_zoomPopUpButton selectItem:item];
            isSelected = YES;
        }
    }
    [[_zoomPopUpButton menu] addItem:[NSMenuItem separatorItem]];
    [_zoomPopUpButton addItemWithTitle:[[NSBundle mainBundle] localizedStringForKey:@"Fit In Window" value:@"" table:nil]];
    [[_zoomPopUpButton lastItem] setRepresentedObject:[NSNumber numberWithFloat:NAN]];
    if (!isSelected)
        [_zoomPopUpButton selectItem:[_zoomPopUpButton lastItem]];
    [self updateScalePopUpButtonTarget];
    [_zoomPopUpButton setAction:@selector(onScalePopUp:)];
    [_zoomPopUpButton setShouldRestorePreviousValue:YES];
}

- (void)updateScalePopUpButtonTarget
{
    if ([[self delegate] respondsToSelector:@selector(targetForScalePopUpButton:inStatusbarController:)])
        [_zoomPopUpButton setTarget:[[self delegate] targetForScalePopUpButton:_zoomPopUpButton inStatusbarController:self]];
}

- (void)setZoomFactor:(CGFloat)aFactor
{
    float percent = aFactor * 100.0f;

    [super setZoomFactor:HSLinearValueForSliderFromNonLinear(_zoomSlider, aFactor)];
    [_zoomPopUpButton setStringValue:[NSString stringWithFormat:HSIsWholePercent(percent) ? @"%1.0f%%" : @"%1.1f%%", (double)percent]];
}

- (id)nibName
{
    return @"EditorStatusbar";
}

@end
