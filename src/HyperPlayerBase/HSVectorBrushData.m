#import "HSVectorBrushData.h"
@implementation HSVectorBrushData
- (void)setObjectKindName:(id)aName
{
    if (![_objectKindName isEqualToString:aName]) {
        [_objectKindName release];
        _objectKindName = [aName retain];
    }
}
- (id)objectKindName
{
    return _objectKindName;
}
- (void)dealloc
{
    [_objectKindName release];
    [super dealloc];
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    id keys = [super keysForExtraStoringWithCodingContext:aContext];
    if (![[aContext codingOperation] isEqualToString:@"HSObjectStyleCodingOperation"])
        keys = [keys arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:@"objectKindName", @"opacity", nil]];
    return keys;
}
@end
