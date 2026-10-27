#import "HyperStudioPrefix.h"


@interface HSCardIndexScrollView : NSScrollView
{
}
- (void)scrollDownAction:(id)aAction;
- (void)scrollUpAction:(id)aAction;
- (id)mediaStripView;
- (void)customizeAppearance;
- (id)initWithFrame:(NSRect)aFrame;
@end

