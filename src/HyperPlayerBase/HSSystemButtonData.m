#import "HSSystemButtonData.h"

@implementation HSSystemButtonData
+ (id)nodeDataKeysToNodeKeysMap
{
    NSMutableDictionary *map = [super nodeDataKeysToNodeKeysMap];
    [map setObject:@"titleFont" forKey:[@"font" extraKeyForMultiRepresentations]];
    return map;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraStoringWithCodingContext:aContext]];
    [keys addObject:@"title"];
    [keys addObject:[@"font" extraKeyForMultiRepresentations]];
    [keys addObject:@"controlSize"];
    [keys addObject:@"bordered"];
    [keys addObject:@"transparent"];
    [keys addObject:@"enabled"];
    [keys addObject:@"selected"];
    [keys addObject:@"continuous"];
    return keys;
}
- (void)setContinuous:(BOOL)aValue
{
    [[self systemButtonForSetAccessor] setContinuous:aValue];
}
- (BOOL)isContinuous
{
    return [[self systemButtonForGetAccessor] isContinuous];
}
- (void)setSelected:(BOOL)aValue
{
    [[self systemButtonForSetAccessor] setState:aValue];
}
- (BOOL)isSelected
{
    return [[self systemButtonForGetAccessor] state] ? YES : NO;
}
- (void)setEnabled:(BOOL)aValue
{
    [[self systemButtonForSetAccessor] setEnabled:aValue];
}
- (BOOL)isEnabled
{
    return [[self systemButtonForGetAccessor] isEnabled];
}
- (void)setTransparent:(BOOL)aValue
{
    [[self systemButtonForSetAccessor] setTransparent:aValue];
}
- (BOOL)isTransparent
{
    return [[self systemButtonForGetAccessor] isTransparent];
}
- (void)setBordered:(BOOL)aValue
{
    [[self systemButtonForSetAccessor] setBordered:aValue];
}
- (BOOL)isBordered
{
    return [[self systemButtonForGetAccessor] isBordered];
}
- (void)setControlSize:(NSUInteger)aSize
{
    [[[self systemButtonForSetAccessor] cell] setControlSize:aSize];
}
- (NSUInteger)controlSize
{
    return [[[self systemButtonForGetAccessor] cell] controlSize];
}
- (void)setFont:(id)aFont
{
    [[self systemButtonForSetAccessor] setFont:aFont];
}
- (id)font
{
    return [[self systemButtonForGetAccessor] font];
}
- (void)setTitle:(id)aTitle
{
    [[self systemButtonForSetAccessor] setTitle:aTitle];
}
- (id)title
{
    NSString *title = [[self systemButtonForGetAccessor] title];
    return title ? title : [NSString string];
}
- (id)systemButtonForSetAccessor
{
    return [self systemViewForSetAccessor];
}
- (id)systemButtonForGetAccessor
{
    return [self systemViewForGetAccessor];
}
@end
