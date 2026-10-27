#import "HyperStudioPrefix.h"


@interface HSCustomPopUpButton : NSPopUpButton
{
}
+ (Class)cellClass;
- (void)setShouldRestorePreviousValue:(BOOL)aValue;
- (BOOL)shouldRestorePreviousValue;
- (void)customizeCell;
- (void)setStringValue:(id)aValue;
- (id)initWithCoder:(id)aCoder;
@end

