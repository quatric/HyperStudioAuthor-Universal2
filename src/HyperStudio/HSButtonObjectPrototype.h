#import "HyperStudioPrefix.h"


@interface HSButtonObjectPrototype : HSButtonObject
{
    NSSize _restrictingSize;
}
+ (id)buttonObjetcPrototypeFromButtonObject:(id)aObject restrictedBySize:(NSSize)aSize;
+ (id)buttonObjetcPrototypeFromButtonObject:(id)aObject;
- (id)queryNewHyperInterface:(id)aInterface;
- (void)setBackgroundStyle:(id)aStyle;
- (void)setIconPosition:(NSUInteger)aPosition;
- (void)setIconVisible:(BOOL)aVisible;
- (void)setIconFromPath:(id)aPath;
- (void)setIcon:(id)aIcon;
- (void)setTitleFont:(id)aFont;
- (void)setTitle:(id)aTitle;
- (void)setTitleVisible:(BOOL)aVisible;
- (void)resetSize;
- (void)setRestrictingSize:(NSSize)aSize;
- (NSSize)restrictingSize;
@end

