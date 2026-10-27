#import "HSGradientColorWell.h"

@implementation HSGradientColorWell

- (BOOL)isPatternSupportEnabled
{
    return _isPatternSupportEnabled;
}

- (void)setPatternSupportEnabled:(BOOL)aEnabled
{
    if (_isPatternSupportEnabled != aEnabled) {
        _isPatternSupportEnabled = aEnabled;
        if ([self isActive])
            [[HSPatternPicker sharedPatternPicker] setIsDisabled:!aEnabled];
    }
}

- (BOOL)isGradientSupportEnabled
{
    return _isGradientSupportEnabled;
}

- (void)setGradientSupportEnabled:(BOOL)aEnabled
{
    if (_isGradientSupportEnabled != aEnabled) {
        _isGradientSupportEnabled = aEnabled;
        if ([self isActive])
            [[HSGradientPicker sharedGradienPicker] setIsDisabled:!aEnabled];
    }
}

- (id)initWithCoder:(id)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self != nil) {
        _isPatternSupportEnabled = YES;
        _isGradientSupportEnabled = YES;
    }
    return self;
}

@end
