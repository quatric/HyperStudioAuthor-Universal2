#import "HSNewObjectDropHelpPane.h"

@implementation HSNewObjectDropHelpPane

- (void)setContainerForAdd:(id)aAdd
{
    if (_containerForAdd != aAdd) {
        [_containerForAdd release];
        _containerForAdd = [aAdd retain];
    }
}

- (id)containerForAdd
{
    return _containerForAdd;
}

- (void)setObjectToAdd:(id)aAdd
{
    if (_objectToAdd != aAdd) {
        [_objectToAdd release];
        _objectToAdd = [aAdd retain];
    }
}

- (id)objectToAdd
{
    return _objectToAdd;
}

- (void)paneDidCancel:(id)aCancel
{
    if (_dropDelegate != nil)
        [_dropDelegate dropHelpPaneDidEnd:self canceled:YES];
    [self dismiss:YES];
}

- (void)paneDidOK:(id)aOK
{
    if (_dropDelegate != nil)
        [_dropDelegate dropHelpPaneDidEnd:self canceled:NO];
    [[aOK navigationController] dismiss:YES];
}

- (BOOL)shouldShowCancelButtonInNavigationPaneSwitcher:(id)aSwitcher
{
    return YES;
}

- (id)dropHelpPaneIdentifier
{
    return @"HSNewObjectDropHelpPane";
}

- (void)dealloc
{
    [_objectToAdd release];
    [_containerForAdd release];
    [super dealloc];
}

- (id)initWithCoachingKey:(id)aKey dropDelegate:(id)aDelegate objectForAdd:(id)aAdd containerForAdd:(id)aAdd2
{
    self = [super initWithCoachingKey:aKey];
    if (self != nil) {
        if (aAdd2 == nil || aAdd == nil || aDelegate == nil) {
            [self release];
            return nil;
        }
        _objectToAdd = [aAdd retain];
        _containerForAdd = [aAdd2 retain];
        _dropDelegate = aDelegate;
    }
    return self;
}

@end
