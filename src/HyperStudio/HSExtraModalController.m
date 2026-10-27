#import "HSExtraModalController.h"

@implementation HSExtraModalController

- (id)document
{
    return [_context document];
}

- (id)stack
{
    return [_context stack];
}

- (id)card
{
    return [_context card];
}

- (void)dealloc
{
    [_context release];
    [super dealloc];
}

- (id)initWithContext:(id)aContext
{
    self = [super init];
    if (self != nil)
        _context = [aContext retain];
    return self;
}

@end
