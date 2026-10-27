#import "HSANewSoundDropHelpPane.h"

@implementation HSANewSoundDropHelpPane

- (id)initWithNibName:(id)aName informativeText:(id)aText didEndDelegate:(id)aDelegate didDoneSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    self = [super initWithNibName:aName informativeText:aText didEndDelegate:aDelegate didDoneSelector:aSelector contextInfo:aInfo];
    if (self != nil) {
        _coachingHintButtonName = [[[HSObjectAssistantController sharedAssistantController] coachingHintDefaultButton] copy];
    }
    return self;
}

- (void)dealloc
{
    [_coachingHintButtonName release];
    [super dealloc];
}

// The text names the default button of the coaching hints, so it follows that setting.
- (void)viewWillAppear:(BOOL)aAppear
{
    id buttonName = [[HSObjectAssistantController sharedAssistantController] coachingHintDefaultButton];
    if (![_coachingHintButtonName isEqualToString:buttonName]) {
        [_coachingHintButtonName release];
        _coachingHintButtonName = [buttonName copy];
        id info = [[HSCoachingInfoProvider sharedProvider] coachingInfoForKey:[self coachingKey]];
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithPath:[[NSBundle mainBundle] pathForResource:[info objectForKey:@"informativeTextFilename"] ofType:@"rtf" inDirectory:@"Coaching"] documentAttributes:NULL];
        [text replaceOccurencesOfString:@"<defaultButtonName>" withString:_coachingHintButtonName];
        [self setInformativeText:text];
        [text release];
    }
    [super viewWillAppear:aAppear];
}

@end
