#import "HSMovieExportAccessoryViewController.h"

@implementation HSMovieExportAccessoryViewController

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [_exporter setExportSettingsValue:[NSNumber numberWithDouble:[self fixedFramesPerSecondLimitForValue:[_framesPerSecondLimitField doubleValue]]] forKey:HSVideoExportFramesPerSecondKey];
    [_slideDelayTextField sendAction:[_slideDelayTextField action] to:[_slideDelayTextField target]];
    [super viewWillDisappear:aDisappear];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (![[_exporter exportSettingsValueForKey:HSVideoExportAllowsNarrationKey] boolValue]) {
        [_transitionsPopUpButton setEnabled:YES];
        [_slideDelayTextField setEnabled:YES];
        [_slideDelayStepper setEnabled:YES];
    }
    double limit = [[_exporter exportSettingsValueForKey:HSVideoExportFramesPerSecondKey] doubleValue];
    [_framesPerSecondLimitField setDoubleValue:limit];
    [_framesPerSecondLimitStepper setDoubleValue:limit];
    id attributes = [HSSlideshowAttributes defaultSlideshowAttributes];
    [_transitionsPopUpButton removeAllItems];
    id provider = [HSTransitionEffectProvider sharedTransitionEffectProvider];
    NSArray *names = [provider transitionEffectNames];
    if (names != nil) {
        NSMenu *menu = [_transitionsPopUpButton menu];
        NSUInteger count = [names count];
        for (NSUInteger i = 0; i < count; i++) {
            id name = [names objectAtIndex:i];
            NSString *displayName = [provider displayNameForTransitionEffectWithName:name];
            if (displayName != nil) {
                NSMenuItem *item = [menu addItemWithTitle:displayName action:NULL keyEquivalent:@""];
                if (item != nil)
                    [item setRepresentedObject:name];
            }
        }
        id transitionName = [[attributes transition] transitionName];
        if (transitionName != nil) {
            [_transitionsPopUpButton selectItemAtIndex:[menu indexOfItemWithRepresentedObject:transitionName]];
            [_exporter setExportSettingsValue:transitionName forKey:HSVideoExportTransitionKey];
        }
    }
    float delay = [attributes durationBetweenSlides];
    [_slideDelayTextField setFloatValue:delay];
    [_slideDelayStepper setFloatValue:delay];
    [_exporter setExportSettingsValue:[NSNumber numberWithFloat:delay] forKey:HSVideoExportCardDelayKey];
}

- (void)changeSlideDelayByStepper:(id)aStepper
{
    float delay = [_slideDelayStepper floatValue];
    [_slideDelayTextField setFloatValue:delay];
    [_exporter setExportSettingsValue:[NSNumber numberWithFloat:delay] forKey:HSVideoExportCardDelayKey];
}

- (void)changeSlideDelay:(id)aDelay
{
    float delay = fmaxf([_slideDelayTextField floatValue], 0.1f);
    [_slideDelayTextField setFloatValue:delay];
    [_slideDelayStepper setFloatValue:delay];
    [_exporter setExportSettingsValue:[NSNumber numberWithFloat:delay] forKey:HSVideoExportCardDelayKey];
}

- (void)changeTransition:(id)aTransition
{
    [_exporter setExportSettingsValue:[[_transitionsPopUpButton selectedItem] representedObject] forKey:HSVideoExportTransitionKey];
}

- (void)changeFramesPerSecondLimitByStepper:(id)aStepper
{
    double limit = [self fixedFramesPerSecondLimitForValue:[_framesPerSecondLimitStepper doubleValue]];
    [_framesPerSecondLimitField setDoubleValue:limit];
    [_exporter setExportSettingsValue:[NSNumber numberWithDouble:limit] forKey:HSVideoExportFramesPerSecondKey];
}

- (void)controlTextDidChange:(id)aChange
{
    if ([aChange object] == _framesPerSecondLimitField) {
        double limit = [self fixedFramesPerSecondLimitForValue:[_framesPerSecondLimitField doubleValue]];
        [_framesPerSecondLimitField setDoubleValue:limit];
        [_exporter setExportSettingsValue:[NSNumber numberWithDouble:limit] forKey:HSVideoExportFramesPerSecondKey];
        [_framesPerSecondLimitStepper setDoubleValue:limit];
    }
}

- (double)fixedFramesPerSecondLimitForValue:(double)aValue
{
    if (aValue < 1.0)
        return 1.0;
    return aValue <= 30.0 ? aValue : 30.0;
}

- (void)changeMovieSize:(id)aSize
{
}

- (void)toggleExportOption:(id)aOption
{
    NSInteger option = [[_exportOptionMatrix selectedCell] tag];
    BOOL enabled = option == 0;
    [_transitionsPopUpButton setEnabled:enabled];
    [_slideDelayTextField setEnabled:enabled];
    [_slideDelayStepper setEnabled:enabled];
    [_exporter setExportSettingsValue:[NSNumber numberWithInt:option] forKey:HSVideoExportOptionKey];
}

@end
