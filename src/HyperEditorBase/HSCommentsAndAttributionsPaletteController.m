#import "HSCommentsAndAttributionsPaletteController.h"

// The comments and attributions palette: the stack's (tag 1: its own and
// every card's), the current card's objects' (tag 2) or the card's own
// (tag 3) comments, kept current while the palette shows.

@implementation HSCommentsAndAttributionsPaletteController

- (void)filterChanged:(id)aChanged
{
    [self HSCommentsAndAttributionsPaletteController_refreshTextView:nil];
}

- (void)willCloseWindow
{
    [self HSCommentsAndAttributionsPaletteController_unsubscribeFromAllCommentNotification];
    [super willCloseWindow];
}

- (void)willShowWindow
{
    [super willShowWindow];
    [self HSCommentsAndAttributionsPaletteController_subscribeToAllCommentNotifications];
    [self HSCommentsAndAttributionsPaletteController_refreshTextView:nil];
}

- (void)HSCommentsAndAttributionsPaletteController_cardDidChange:(id)aChange
{
    NSInteger tag = [_filterControl selectedTag];
    if (tag == 2 || tag == 3)
        [self HSCommentsAndAttributionsPaletteController_refreshTextView:nil];
}

- (void)HSCommentsAndAttributionsPaletteController_unsubscribeFromAllCommentNotification
{
    id container = [[_dataProvider currentActiveStack] queryHyperInterface:@protocol(HSNodeContainer)];
    id cardView = [_dataProvider cardView];
    if (container == nil || cardView == nil)
        return;
    SEL refresh = @selector(HSCommentsAndAttributionsPaletteController_refreshTextView:);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSCurrentCardInCardViewDidChange object:cardView];
    [[container attributeObservingController] removeObserver:self selector:refresh ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSCommentsAttribute)];
    [container removeObserver:self selector:refresh ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSCommentsAttribute) ofChildrenInDepthRange:NSMakeRange(0, 2)];
    [[container attributeObservingController] removeObserver:self selector:refresh ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
    [container removeObserver:self selector:refresh ofChanges:HSActualDidAttributeChanges ofChildrenAttribute:@protocol(HSNodeContainerChildrenAttribute)];
}

- (void)HSCommentsAndAttributionsPaletteController_subscribeToAllCommentNotifications
{
    id container = [[_dataProvider currentActiveStack] queryHyperInterface:@protocol(HSNodeContainer)];
    id cardView = [_dataProvider cardView];
    if (container == nil || cardView == nil)
        return;
    SEL refresh = @selector(HSCommentsAndAttributionsPaletteController_refreshTextView:);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSCommentsAndAttributionsPaletteController_cardDidChange:) name:HSCurrentCardInCardViewDidChange object:cardView];
    [[container attributeObservingController] addObserver:self selector:refresh ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSCommentsAttribute) withPriority:-0.25f];
    [container addObserver:self selector:refresh ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSCommentsAttribute) ofChildrenInDepthRange:NSMakeRange(0, 2) withPriority:-0.25f];
    [[container attributeObservingController] addObserver:self selector:refresh ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.25f];
    [container addObserver:self selector:refresh ofChanges:HSActualDidAttributeChanges ofChildrenAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.25f];
}

- (void)HSCommentsAndAttributionsPaletteController_refreshTextView:(id)aView
{
    NSMutableString *text = [NSMutableString string];
    id provider = [self dataProvider];
    id stack = [provider currentActiveStack];
    id card = [provider currentActiveCard];
    if (provider != nil && stack != nil && card != nil) {
        NSInteger tag = [_filterControl selectedTag];
        if (tag == 1) {
            [text appendString:[[stack queryHyperInterface:@protocol(HSCommentsAttributes)] hyperComments]];
            NSEnumerator *enumerator = [[stack queryHyperInterface:@protocol(HSNodeContainer)] hyperEnumerator];
            id child;
            while ((child = [enumerator nextObject])) {
                NSString *comments = [self commentsForCard:[child queryHyperInterface:@protocol(HSNodeContainer)]];
                if ([comments length] == 0)
                    continue;
                // Two blank lines between cards.
                if ([text length] != 0) {
                    while (![text hasSuffix:@"\n\n\n"])
                        [text appendString:@"\n"];
                }
                [text appendString:comments];
            }
        } else if (tag == 2) {
            [text appendString:[[card queryHyperInterface:@protocol(HSCommentsAttributes)] childrenComments]];
        } else if (tag == 3) {
            [text appendString:[[card queryHyperInterface:@protocol(HSCommentsAttributes)] hyperComments]];
        }
    }
    NSAttributedString *string = [text hyperAttributedStringWithRecognizedLinks];
    if (string != nil) {
        NSTextStorage *storage = [_textView textStorage];
        [storage replaceCharactersInRange:NSMakeRange(0, [storage length]) withAttributedString:string];
    }
    [_textView setNeedsDisplay:YES];
}

// Only the height zooms.
- (NSRect)windowWillUseStandardFrame:(id)aFrame defaultFrame:(NSRect)aFrame2
{
    if ([self window] == aFrame) {
        NSRect frame = [(NSWindow *)aFrame frame];
        aFrame2.origin.x = frame.origin.x;
        aFrame2.size.width = frame.size.width;
    }
    return aFrame2;
}

- (BOOL)paletteShouldBecomeKeyOnlyWhenNeeded
{
    return YES;
}

- (void)didLoadNib
{
    [super didLoadNib];
    [_filterControl setBackgroundRenderer:[HSAssistantSegmentedControlBackgroundRenderer sharedBackgroundRenderer]];
    [_textView setPlaceholderString:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"No comments or attributions added." value:@"" table:@"HyperPlayerBase"]];
}

- (id)commentsForCard:(id)aCard
{
    return [[aCard queryHyperInterface:@protocol(HSCommentsAttributes)] deepComments];
}

- (void)setDataProvider:(id)aProvider
{
    if (_dataProvider == aProvider)
        return;
    if ([self isPaletteVisible])
        [self HSCommentsAndAttributionsPaletteController_unsubscribeFromAllCommentNotification];
    _dataProvider = aProvider;
    if ([self isPaletteVisible]) {
        [self HSCommentsAndAttributionsPaletteController_subscribeToAllCommentNotifications];
        [self HSCommentsAndAttributionsPaletteController_refreshTextView:nil];
    }
}

- (id)dataProvider
{
    return _dataProvider;
}

- (id)nibName
{
    return @"CommentsAndAttributionsPalette";
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
