#import "HyperPlayerBasePrefix.h"


@interface HSGoToSpecificCardController : NSObject
{
    NSWindow *_panel;
    NSButton *_okButton;
    NSTextField *_cardIndexField;
    NSNumberFormatter *_formatter;
    HSStack *_stack;
    unsigned int _cardCount;
    unsigned int _cardIndex;
    id _delegate;
    void *_context;
}
- (void)controlTextDidChange:(id)aChange;
- (void)updatePanelUI;
- (void)goToCard:(id)aCard;
- (void)cancel:(id)aCancel;
- (void)goToCardPanelSheetDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)runModalForWindow:(id)aWindow;
- (void)awakeFromNib;
- (void)setCardIndex:(NSUInteger)aIndex;
- (NSUInteger)cardIndex;
- (void)setCardCount:(NSUInteger)aCount;
- (NSUInteger)cardCount;
- (void)setContext:(void *)aContext;
- (void *)context;
- (void)dealloc;
- (id)initWithDelegate:(id)aDelegate cardCount:(NSUInteger)aCount cardIndex:(NSUInteger)aIndex context:(void *)aContext;
@end

