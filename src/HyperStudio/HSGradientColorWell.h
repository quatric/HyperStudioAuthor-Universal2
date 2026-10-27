#import "HyperStudioPrefix.h"
#import "HSAlphaIgnoresColorWell.h"


@interface HSGradientColorWell : HSAlphaIgnoresColorWell
{
    BOOL _isGradientSupportEnabled;
    BOOL _isPatternSupportEnabled;
}
- (BOOL)isPatternSupportEnabled;
- (void)setPatternSupportEnabled:(BOOL)aEnabled;
- (BOOL)isGradientSupportEnabled;
- (void)setGradientSupportEnabled:(BOOL)aEnabled;
- (id)initWithCoder:(id)aCoder;
@end

