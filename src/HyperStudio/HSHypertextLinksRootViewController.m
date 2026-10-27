#import "HSHypertextLinksRootViewController.h"

@implementation HSHypertextLinksRootViewController

- (void)objectLockedStateDidChange:(id)aChange
{
    [[HSObjectAssistantController sharedAssistantController] setSelectedInModelObject:_initialObject];
}

- (void)notifyViewWillDisappear:(BOOL)aDisappear
{
    [super notifyViewWillDisappear:aDisappear];
    if (_initialObject != nil)
        [_initialObject removeObserver:self selector:@selector(objectLockedStateDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSCardObjectLockedAttribute)];
}

- (void)notifyViewWillAppear:(BOOL)aAppear
{
    [super notifyViewWillAppear:aAppear];
    if (_initialObject != nil)
        [_initialObject addObserver:self selector:@selector(objectLockedStateDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSCardObjectLockedAttribute) withPriority:-0.25];
}

- (void)setInitialObject:(id)aObject
{
    if (_initialObject != aObject) {
        [_initialObject release];
        _initialObject = [aObject retain];
    }
}

- (void)dealloc
{
    [_initialObject removeObserver:self selector:@selector(objectLockedStateDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSCardObjectLockedAttribute)];
    [_initialObject release];
    [super dealloc];
}

@end
