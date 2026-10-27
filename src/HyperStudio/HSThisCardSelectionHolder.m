#import "HSThisCardSelectionHolder.h"

@implementation HSThisCardSelectionHolder

- (void)currentCardInCardViewDidChange:(id)aChange
{
    [self noteDidChangeSelectedObject];
}

- (id)ownSelectedObject
{
    return [_cardView card];
}

- (void)setCardView:(id)aView
{
    if (_cardView == aView)
        return;
    if (_cardView != nil)
        [[NSNotificationCenter defaultCenter] removeObserver:self name:HSCurrentCardInCardViewDidChange object:_cardView];
    [_cardView release];
    _cardView = [aView retain];
    if (_cardView != nil)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentCardInCardViewDidChange:) name:HSCurrentCardInCardViewDidChange object:_cardView];
    [self noteDidChangeSelectedObject];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_cardView release];
    [super dealloc];
}

@end
