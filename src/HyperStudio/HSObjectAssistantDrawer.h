#import "HyperStudioPrefix.h"
#import "HSObjectAssistant.h"


@interface HSObjectAssistantDrawer : NSObject
{
    NSPanel *_window;
    NSView *_containerView;
    NSView *_contentView;
    HSObjectAssistant *_objectAssistant;
}
- (void)toggle:(id)aToggle;
- (void)close:(id)aClose;
- (void)open:(id)aOpen;
- (NSRect)standByFrame;
- (NSInteger)preferredSide;
- (void)setContentView:(id)aView;
- (id)contentView;
- (id)window;
- (void)setObjectAssistant:(id)aAssistant;
- (id)objectAssistant;
- (void)dealloc;
- (id)initWithContentView:(id)aView objectAssistant:(id)aAssistant;
- (void)hideContent;
- (void)showContent;
@end

@interface HSObjectAssistant (HSObjectAssistantDrawerSupport)
- (void)setDrawer:(id)aDrawer;
@end

