#import "HSCustomPopUpButton.h"

@implementation HSCustomPopUpButton

+ (Class)cellClass
{
    return [HSCustomPopUpButtonCell class];
}

- (void)setShouldRestorePreviousValue:(BOOL)aValue
{
    [[self cell] setShouldRestorePreviousValue:aValue];
}

- (BOOL)shouldRestorePreviousValue
{
    return [[self cell] shouldRestorePreviousValue];
}

- (void)customizeCell
{
    [self setCell:[[[HSCustomPopUpButtonCell alloc] initWithPopUpButtonCell:[self cell]] autorelease]];
}

- (void)setStringValue:(id)aValue
{
    [super setStringValue:aValue];
    [self updateCell:[self cell]];
}

- (id)initWithCoder:(id)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self != nil)
        [self customizeCell];
    return self;
}

@end
