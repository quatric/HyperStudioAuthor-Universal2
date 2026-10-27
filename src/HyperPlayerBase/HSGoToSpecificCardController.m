#import "HSGoToSpecificCardController.h"
// "Go to card" sheet. The field takes a card title or a card number; on
// OK the delegate is told the index of the card, or NSNotFound after an
// alert when nothing matches.

@implementation HSGoToSpecificCardController

- (void)controlTextDidChange:(id)aChange
{
    NSString *string = [[aChange object] stringValue];
    [_okButton setEnabled:string && [string length]];
}

- (void)updatePanelUI
{
    id cards = [_stack cardsForCardGroupController:[_stack cardGroupController]];
    NSString *title = [[[cards objectAtIndex:_cardIndex] queryHyperInterface:@protocol(HSCardTitleAttribute)] hyperTitle];
    if (title && [title length])
        [_cardIndexField setStringValue:title];
    else
        [_cardIndexField setIntValue:_cardIndex + 1];
    [_okButton setEnabled:YES];
}

- (void)goToCard:(id)aCard
{
    [NSApp endSheet:_panel returnCode:1];
}

- (void)cancel:(id)aCancel
{
    [NSApp endSheet:_panel returnCode:0];
}

- (void)goToCardPanelSheetDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [aEnd orderOut:self];
    if (aCode != 1)
        return;

    NSString *string = [_cardIndexField stringValue];
    id cards = [_stack cardsForCardGroupController:[_stack cardGroupController]];
    NSInteger count = [cards count];
    NSUInteger index = NSNotFound;
    for (NSInteger i = 0; i < count; i++) {
        NSString *title = [[[cards objectAtIndex:i] queryHyperInterface:@protocol(HSCardTitleAttribute)] hyperTitle];
        if ([string caseInsensitiveCompare:title] == NSOrderedSame) {
            index = i;
            break;
        }
    }
    if (index == NSNotFound) {
        NSNumber *number = [_formatter numberFromString:string];
        if (number) {
            NSInteger i = [number intValue] - 1;
            if (i >= 0 && i < count)
                index = i;
        }
    }

    if (index == NSNotFound) {
        HSAlert *alert = [HSAlert new];
        [alert setMessageText:[[NSBundle mainBundle] localizedStringForKey:@"Cannot find card" value:@"" table:@"Alerts"]];
        [alert setInformativeText:[[NSBundle mainBundle] localizedStringForKey:@"HSCardNotFoundInformativeText" value:@"" table:@"Alerts"]];
        [alert runModal];
        [alert release];
        // (The original does not check respondsToSelector: here.)
        [_delegate goToSpecificCardController:self goToCardAtIndex:NSNotFound context:_context];
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(goToSpecificCardController:goToCardAtIndex:context:)])
        [_delegate goToSpecificCardController:self goToCardAtIndex:index context:_context];
}

- (void)runModalForWindow:(id)aWindow
{
    if (!_panel)
        [NSBundle loadNibNamed:@"GoToSpecificCardPanel" owner:self];
    _stack = [[[NSDocumentController sharedDocumentController] currentDocument] stack];
    [self updatePanelUI];
    [NSApp beginSheet:_panel modalForWindow:aWindow modalDelegate:self didEndSelector:@selector(goToCardPanelSheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
}

- (void)awakeFromNib
{
    _formatter = [NSNumberFormatter new];
}

- (void)setCardIndex:(NSUInteger)aIndex
{
    _cardIndex = aIndex;
}

- (NSUInteger)cardIndex
{
    return _cardIndex;
}

- (void)setCardCount:(NSUInteger)aCount
{
    _cardCount = aCount;
}

- (NSUInteger)cardCount
{
    return _cardCount;
}

- (void)setContext:(void *)aContext
{
    _context = aContext;
}

- (void *)context
{
    return _context;
}

- (void)dealloc
{
    [_panel release];
    [_formatter release];
    [super dealloc];
}

- (id)initWithDelegate:(id)aDelegate cardCount:(NSUInteger)aCount cardIndex:(NSUInteger)aIndex context:(void *)aContext
{
    self = [super init];
    if (self) {
        _delegate = aDelegate;
        _context = aContext;
        _cardCount = aCount;
        _cardIndex = aIndex;
    }
    return self;
}

@end
