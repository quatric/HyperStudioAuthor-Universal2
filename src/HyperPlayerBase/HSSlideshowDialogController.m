#import "HSSlideshowDialogController.h"
// The slideshow options: loop or stop at the end, advance after a delay or
// on a key.
@implementation HSSlideshowDialogController
- (void)applyChanges
{
    HSSlideshowAttributes *attributes = [self slideshowAttributes];
    if ([[_advanceRuleMatrix selectedCell] tag] == 0) {
        [attributes setStartsNextSlideAutomatically:YES];
        [attributes setUseKeystrokeOnExitCard:NO];
        [attributes setDurationBetweenSlides:[_delayTextField floatValue]];
    } else {
        [attributes setStartsNextSlideAutomatically:NO];
        [attributes setUseKeystrokeOnExitCard:YES];
    }
    [attributes setStopsAfterEnd:[[_loopModeMatrix selectedCell] tag] == 0];
}
// The text field and the stepper follow each other.
- (void)delayDidChange:(id)aChange
{
    if (aChange == _delayTextField)
        [_delayStepper setFloatValue:[_delayTextField floatValue]];
    else if (aChange == _delayStepper || aChange == [_delayStepper cell])
        [_delayTextField setFloatValue:[_delayStepper floatValue]];
}
- (void)advanceRuleDidChange:(id)aChange
{
    [_delayTextField setEnabled:[[_advanceRuleMatrix selectedCell] tag] == 0];
    [_delayStepper setEnabled:[[_advanceRuleMatrix selectedCell] tag] == 0];
}
- (void)willShowWindow
{
    HSSlideshowAttributes *attributes = [self slideshowAttributes];
    [_loopModeMatrix selectCellWithTag:![attributes stopsAfterEnd]];
    [_advanceRuleMatrix selectCellWithTag:[attributes useKeystrokeOnExitCard] ? 1 : 0];
    float delay = [attributes durationBetweenSlides];
    [_delayTextField setFloatValue:delay];
    [_delayStepper setFloatValue:delay];
    BOOL automatic = [[_advanceRuleMatrix selectedCell] tag] == 0;
    [_delayTextField setEnabled:automatic];
    [_delayStepper setEnabled:automatic];
}
// A copy is edited.
- (void)setDefaultSlideshowAttributesToBeCustomized:(id)aCustomized
{
    [_slideshowAttributes autorelease];
    _slideshowAttributes = [[HSSlideshowAttributes objectWithExtraDictionary:[aCustomized extraDictionaryRepresentation]] retain];
}
- (id)slideshowAttributes
{
    return _slideshowAttributes;
}
- (id)nibName
{
    return @"SlideshowOptions";
}
- (void)dealloc
{
    [_slideshowAttributes release];
    [super dealloc];
}
@end
