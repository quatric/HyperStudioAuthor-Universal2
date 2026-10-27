#import "HSAnimationSetupEditPathAssistantPane.h"

@implementation HSAnimationSetupEditPathAssistantPane

- (void)paneDidCancel:(id)aCancel
{
    if ([_delegate respondsToSelector:@selector(goBackFromAnimationSetupEditPathAssistantPane:)])
        [_delegate goBackFromAnimationSetupEditPathAssistantPane:self];
}

- (void)viewDidLoad
{
    unichar escape = 0x1b;

    [super viewDidLoad];
    _cancelButton = [NSButton new];
    [_cancelButton setTarget:self];
    [_cancelButton setAction:@selector(paneDidCancel:)];
    [_cancelButton setFrame:NSZeroRect];
    [_cancelButton setKeyEquivalent:[NSString stringWithCharacters:&escape length:1]];
    [[self view] addSubview:_cancelButton];
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void)dealloc
{
    [_cancelButton release];
    [super dealloc];
}

@end
