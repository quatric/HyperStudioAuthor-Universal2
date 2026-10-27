#import "HSMagnifyingToolSettingsViewController.h"

@implementation HSMagnifyingToolSettingsViewController

- (void)cardSizeDidChange:(id)aChange
{
    [[self parent] changeDrawerHeightTo:[[self cardNavigatorView] frameHeightAccordingToCardProporsions]];
    [[self cardNavigatorView] setFrameSizeAccordingToCardProporsions];
}

- (void)cardDidChange:(id)aChange
{
    [[self cardNavigatorView] setCard:[[self toolView] card]];
    [[self cardNavigatorView] setNeedsDisplay:YES];
}

- (void)visibleRectDidChange:(id)aChange
{
    [[self cardNavigatorView] setNeedsDisplay:YES];
}

- (id)cardViewForCardNavigatorView:(id)aView
{
    return [self toolView];
}

- (void)scrollCardViewToRect:(NSRect)aRect cardNavigatorView:(id)aView
{
    [(NSView *)[self toolView] scrollRectToVisible:aRect];
}

- (NSRect)userVisibleCardRectForCardNavigatorView:(id)aView
{
    return [[[[self toolView] enclosingScrollView] contentView] bounds];
}

- (void)willUnMount
{
    id navigatorView = [self cardNavigatorView];
    [navigatorView setCard:nil];
    if ([navigatorView delegate] == self)
        [navigatorView setDelegate:nil];
    [[[[[self toolView] card] stack] attributeObservingController] removeObserver:self selector:@selector(cardSizeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSStackCardSizeAttribute)];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)willMount
{
    HSCardNavigatorView *navigatorView = [self cardNavigatorView];
    id toolView = [self toolView];
    id card = [toolView card];
    [navigatorView setCard:card];
    [navigatorView setDelegate:self];
    NSClipView *contentView = [[toolView enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(visibleRectDidChange:) name:NSViewBoundsDidChangeNotification object:contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(visibleRectDidChange:) name:NSViewFrameDidChangeNotification object:contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(visibleRectDidChange:) name:@"HSEditorCardViewDidChangeZoomFactorNotification" object:toolView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cardDidChange:) name:HSCurrentCardInCardViewDidChange object:toolView];
    [[[card stack] attributeObservingController] addObserver:self selector:@selector(cardSizeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSStackCardSizeAttribute) withPriority:-0.25f];
    [navigatorView setNeedsDisplay:YES];
}

- (id)cardNavigatorView
{
    return [self toolSettingsView];
}

- (id)nibName
{
    return @"MagnifyingToolSettings";
}

- (void)dealloc
{
    id navigatorView = [self cardNavigatorView];
    [navigatorView setCard:nil];
    if ([navigatorView delegate] == self)
        [navigatorView setDelegate:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)validateUserInterface
{
    [super validateUserInterface];
    id navigator = [self cardNavigatorView];
    id toolView = [self toolView];
    id card = [toolView card];
    if (card == [navigator card])
        return;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
    [[[[navigator card] stack] attributeObservingController] removeObserver:self selector:@selector(cardSizeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSStackCardSizeAttribute)];
    [navigator setCard:card];
    [navigator setDelegate:self];
    id contentView = [[toolView enclosingScrollView] contentView];
    [center addObserver:self selector:@selector(visibleRectDidChange:) name:NSViewBoundsDidChangeNotification object:contentView];
    [center addObserver:self selector:@selector(visibleRectDidChange:) name:NSViewFrameDidChangeNotification object:contentView];
    [center addObserver:self selector:@selector(visibleRectDidChange:) name:HSCardViewDidChangeZoomFactorNotification object:toolView];
    [center addObserver:self selector:@selector(cardDidChange:) name:HSCurrentCardInCardViewDidChange object:toolView];
    [[[card stack] attributeObservingController] addObserver:self selector:@selector(cardSizeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSStackCardSizeAttribute) withPriority:-0.25];
    [navigator setNeedsDisplay:YES];
}

@end
