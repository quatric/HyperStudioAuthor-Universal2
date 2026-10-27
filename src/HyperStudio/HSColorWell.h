#import "HyperStudioPrefix.h"


@interface HSColorWell : NSColorWell
{
}
+ (BOOL)hasActiveColorWell;
+ (void)load;
- (void)drawWellInside:(NSRect)aInside;
- (void)setColor:(id)aColor;
- (BOOL)isPatternSupportEnabled;
- (BOOL)isGradientSupportEnabled;
- (void)deactivate;
- (void)activate:(BOOL)aActivate;
- (void)decrementCounter;
- (void)incrementCounter;
- (void)dealloc;
@end

