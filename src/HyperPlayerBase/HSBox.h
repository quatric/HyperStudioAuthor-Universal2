#import "HyperPlayerBasePrefix.h"


@interface HSBox : NSBox
{
    BOOL _titleVisible;
}
- (BOOL)canToggleTitleVisibility;
- (void)setTitlePosition:(NSUInteger)aPosition;
- (void)setBoxType:(NSUInteger)aType;
- (void)setBorderType:(NSUInteger)aType;
- (void)awakeFromNib;
@end

