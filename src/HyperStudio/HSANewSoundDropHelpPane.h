#import "HyperStudioPrefix.h"
#import "HSNewActionDropHelpPane.h"


@interface HSANewSoundDropHelpPane : HSNewActionDropHelpPane
{
    NSString *_coachingHintButtonName;
}
- (id)initWithNibName:(id)aName informativeText:(id)aText didEndDelegate:(id)aDelegate didDoneSelector:(SEL)aSelector contextInfo:(void *)aInfo;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)dealloc;
@end
