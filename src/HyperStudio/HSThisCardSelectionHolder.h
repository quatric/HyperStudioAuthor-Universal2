#import "HyperStudioPrefix.h"
#import "HSAbstractSelectionHolder.h"


@interface HSThisCardSelectionHolder : HSAbstractSelectionHolder
{
    HSCardView *_cardView;
}
- (void)currentCardInCardViewDidChange:(id)aChange;
- (id)ownSelectedObject;
- (void)setCardView:(id)aView;
- (void)dealloc;
@end

