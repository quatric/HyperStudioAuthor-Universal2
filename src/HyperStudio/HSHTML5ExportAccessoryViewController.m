#import "HSHTML5ExportAccessoryViewController.h"

@implementation HSHTML5ExportAccessoryViewController

- (void)controlTextDidChange:(id)aChange
{
    int depth = [_linkedStacksDepthTextField intValue];
    if ((unsigned)(depth - 1) < 99)
        [_linkedStacksDepthStepper setIntValue:depth];
}

- (void)linkedStacksDepthChanged:(id)aChanged
{
    int depth = [aChanged intValue];
    if (aChanged == _linkedStacksDepthTextField)
        [_linkedStacksDepthStepper setIntValue:depth];
    else
        [_linkedStacksDepthTextField setIntValue:depth];
}

- (void)exportWithDepthChanged:(id)aChanged
{
    BOOL enabled = [aChanged state] == NSControlStateValueOn;
    [_linkedStacksDepthTextField setEnabled:enabled];
    [_linkedStacksDepthStepper setEnabled:enabled];
    [_explanationText setTextColor:enabled ? [NSColor controlTextColor] : [NSColor disabledControlTextColor]];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSControlTextDidChangeNotification object:_linkedStacksDepthTextField];
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlTextDidChange:) name:NSControlTextDidChangeNotification object:_linkedStacksDepthTextField];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    BOOL linkedStacks = [[NSUserDefaults standardUserDefaults] boolForKey:@"HSHTML5ExportAreLinkedStacksInDocument"];
    [_exportWithDepthCheckbox setEnabled:linkedStacks];
    [_exportWithDepthCheckbox setState:linkedStacks ? NSControlStateValueOn : NSControlStateValueOff];
    [_linkedStacksDepthTextField setEnabled:linkedStacks];
    [_linkedStacksDepthStepper setEnabled:linkedStacks];
    [_explanationText setTextColor:linkedStacks ? [NSColor controlTextColor] : [NSColor disabledControlTextColor]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (id)init
{
    return [self initWithNibName:@"ExportToHTML5AccessoryView"];
}

@end
