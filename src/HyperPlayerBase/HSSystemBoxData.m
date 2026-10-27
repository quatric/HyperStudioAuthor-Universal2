#import "HSSystemBoxData.h"
// A system box (NSBox from the "VisualSystemBox" nib): title, title font
// and position, and border type, stored on the box view itself.
@implementation HSSystemBoxData
+ (id)nodeDataKeysToNodeKeysMap
{
    id map = [super nodeDataKeysToNodeKeysMap];
    [map setObject:@"titleFont" forKey:[@"titleFont" extraKeyForMultiRepresentations]];
    return map;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraStoringWithCodingContext:aContext]];
    [keys addObject:@"title"];
    [keys addObject:[@"titleFont" extraKeyForMultiRepresentations]];
    [keys addObject:@"boxTitlePosition"];
    [keys addObject:@"borderType"];
    return keys;
}
// (The original also uses the get accessor's box for these setters.)
- (void)setBorderType:(NSUInteger)aType
{
    [(NSBox *)[self systemBoxForGetAccessor] setBorderType:aType];
}
- (NSUInteger)borderType
{
    return [(NSBox *)[self systemBoxForGetAccessor] borderType];
}
- (void)setBoxTitlePosition:(NSUInteger)aPosition
{
    [(NSBox *)[self systemBoxForGetAccessor] setTitlePosition:aPosition];
}
- (NSUInteger)boxTitlePosition
{
    return [(NSBox *)[self systemBoxForGetAccessor] titlePosition];
}
- (void)setTitleFont:(id)aFont
{
    [(NSBox *)[self systemBoxForGetAccessor] setTitleFont:aFont];
}
- (id)titleFont
{
    return [(NSBox *)[self systemBoxForGetAccessor] titleFont];
}
- (void)setTitle:(id)aTitle
{
    [(NSBox *)[self systemBoxForSetAccessor] setTitle:aTitle];
}
- (id)title
{
    id title = [(NSBox *)[self systemBoxForGetAccessor] title];
    return title != nil ? title : [NSString string];
}
- (id)systemBoxForSetAccessor
{
    return [self systemViewForSetAccessor];
}
- (id)systemBoxForGetAccessor
{
    return [self systemViewForGetAccessor];
}
- (id)templateCocoaView
{
    return [HSVisualSystemViewLoader cocoaViewWithNibName:@"VisualSystemBox"];
}
@end
