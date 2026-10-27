#import "HSRootPickSoundSourceAssistantPane.h"

@implementation HSRootPickSoundSourceAssistantPane

- (void)dismissPaneIfNeeded
{
}

// Original quirk kept: the pane passes itself (kept alive while opening) as the sender.
- (void)stopSound:(id)aSound
{
    id pane;

    [self retain];
    pane = [self playSoundActionAssistantPane];
    [self openPlaySoundActionAssistantPane];
    [pane stopSound:[self autorelease]];
}

- (void)processSoundItem:(id)aItem
{
    [self openPlaySoundActionAssistantPane];
    [[self playSoundActionAssistantPane] setSounds:[NSArray arrayWithObject:aItem]];
}

- (void)openPlaySoundActionAssistantPane
{
    id pane = [self playSoundActionAssistantPane];

    [pane setActionEvent:[self actionEvent]];
    [[self objectAssistantNavigationController] pushViewController:pane withIdentifier:nil animate:YES replacePrevious:YES];
}

- (id)playSoundActionAssistantPane
{
    if (_playSoundActionAssistantPane == nil)
        _playSoundActionAssistantPane = [[HSPlaySoundActionAssistantPane alloc] init];
    return _playSoundActionAssistantPane;
}

- (void)dealloc
{
    [_playSoundActionAssistantPane release];
    [super dealloc];
}

@end
