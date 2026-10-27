#import "HSAnimationSetupPickPartOfCardAssistantPane.h"

@implementation HSAnimationSetupPickPartOfCardAssistantPane

- (void)selectCardObject:(id)aObject
{
    [_delegate pickCardObjectForAssistantPane:self temporaryObject:_temporaryObject];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    id renderer = [HSAssistantLargeButtonBackgroundRenderer sharedBackgroundRenderer];
    [[_selectSquireCardPartButton cell] setBackgroundRenderer:renderer];
    [[_selectCircleCardPartButton cell] setBackgroundRenderer:renderer];
    [[_selectCardPartUsingLassoButton cell] setBackgroundRenderer:renderer];
    [[_selectCardObjectButton cell] setBackgroundRenderer:renderer];
}

- (BOOL)requiresDarkBottomArea
{
    return YES;
}

- (BOOL)assistantShouldBeKeyWindow
{
    return NO;
}

- (id)initWithOptions:(id)aOptions
{
    self = [super initWithNibName:@"AnimationPickPartOfCardPane"];
    if (self != nil)
        _imageOptions = [aOptions retain];
    return self;
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [_image release];
    _image = [[[self card] imageWithVisualizationProtocol:@protocol(HSPlayerVisualization)] retain];
    [super viewWillAppear:aAppear];
}

@end
