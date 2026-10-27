#import "HSSpinButton.h"

@implementation HSSpinButton

+ (Class)cellClass
{
    return [HSSpinCell class];
}

+ (void)initialize
{
    if ([HSSpinButton class] == self)
        [self setCellClass:[HSSpinCell class]];
}

- (void)performClick:(id)aClick
{
    [[self cell] performClick:aClick];
}

- (void)moveDown:(id)aDown
{
    [[self cell] moveDown:aDown];
}

- (void)moveUp:(id)aUp
{
    [[self cell] moveUp:aUp];
}

- (void)moveLeft:(id)aLeft
{
    [[self cell] moveLeft:aLeft];
}

- (void)moveRight:(id)aRight
{
    [[self cell] moveRight:aRight];
}

- (id)initWithCoder:(id)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self != nil) {
        NSCell *oldCell = [[self cell] retain];
        HSSpinCell *cell = [[HSSpinCell allocWithZone:[self zone]] init];
        [self setCell:cell];
        [cell setTarget:[oldCell target]];
        [cell setAction:[oldCell action]];
        [oldCell release];
        [cell release];
    }
    return self;
}

@end
