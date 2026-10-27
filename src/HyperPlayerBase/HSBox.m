#import "HSBox.h"
@implementation HSBox
// Title positions are only NSNoTitle or NSAtTop. An old style box
// (NSBoxOldStyle) keeps its title hidden while remembering the choice;
// line-bordered boxes can't toggle it.
- (BOOL)canToggleTitleVisibility
{
    return [self borderType] != NSLineBorder;
}
- (void)setTitlePosition:(NSUInteger)aPosition
{
    NSBoxType type = [self boxType];
    if (aPosition == NSAtTop)
        _titleVisible = YES;
    else if (aPosition == NSNoTitle)
        _titleVisible = NO;
    else
        return;
    if (type != NSBoxOldStyle)
        [super setTitlePosition:aPosition];
}
- (void)setBoxType:(NSUInteger)aType
{
    [super setBoxType:aType];
    [super setTitlePosition:aType == NSBoxOldStyle ? NSNoTitle : (_titleVisible ? NSAtTop : NSNoTitle)];
}
// NSNoBorder and NSGrooveBorder make a secondary box, NSLineBorder an old
// style one, anything else (NSBezelBorder) a primary one.
- (void)setBorderType:(NSUInteger)aType
{
    [super setBorderType:aType];
    NSUInteger type;
    if (aType == 0 || aType == 3)
        type = 1;
    else if (aType == 1)
        type = 3;
    else
        type = 0;
    [self setBoxType:type];
}
- (void)awakeFromNib
{
    _titleVisible = [self titlePosition] == NSAtTop;
}
@end
