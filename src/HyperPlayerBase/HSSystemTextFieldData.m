#import "HSSystemTextFieldData.h"
#import "HSVisualSystemViewLoader.h"

@implementation HSSystemTextFieldData

+ (id)nodeDataKeysToNodeKeysMap
{
    id map = [super nodeDataKeysToNodeKeysMap];
    [map setObject:@"textColor" forKey:[@"textColor" extraKeyForMultiRepresentations]];
    [map setObject:@"backgroundColor" forKey:[@"backgroundColor" extraKeyForMultiRepresentations]];
    return map;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraStoringWithCodingContext:aContext]];
    [keys addObject:@"borderType"];
    [keys addObject:@"placeholderString"];
    [keys addObject:@"stringValue"];
    [keys addObject:@"font"];
    [keys addObject:[@"textColor" extraKeyForMultiRepresentations]];
    [keys addObject:[@"backgroundColor" extraKeyForMultiRepresentations]];
    [keys addObject:@"bezelStyle"];
    [keys addObject:@"textAlignment"];
    [keys addObject:@"controlSize"];
    [keys addObject:@"selectable"];
    [keys addObject:@"editable"];
    return keys;
}

- (void)setEditable:(BOOL)aEditable
{
    [(NSTextField *)[self systemTextFieldForSetAccessor] setEditable:aEditable];
}

- (BOOL)isEditable
{
    return [(NSTextField *)[self systemTextFieldForGetAccessor] isEditable];
}

- (void)setSelectable:(BOOL)aSelectable
{
    [(NSTextField *)[self systemTextFieldForSetAccessor] setSelectable:aSelectable];
}

- (BOOL)isSelectable
{
    return [(NSTextField *)[self systemTextFieldForGetAccessor] isSelectable];
}

- (void)setControlSize:(NSUInteger)aSize
{
    [[(NSTextField *)[self systemTextFieldForSetAccessor] cell] setControlSize:(NSControlSize)aSize];
}

- (NSUInteger)controlSize
{
    return (NSUInteger)[[(NSTextField *)[self systemTextFieldForGetAccessor] cell] controlSize];
}

- (void)setTextAlignment:(NSUInteger)aAlignment
{
    [[(NSTextField *)[self systemTextFieldForSetAccessor] cell] setAlignment:(NSTextAlignment)aAlignment];
}

- (NSUInteger)textAlignment
{
    return (NSUInteger)[[(NSTextField *)[self systemTextFieldForGetAccessor] cell] alignment];
}

- (void)setBezelStyle:(NSUInteger)aStyle
{
    [(NSTextField *)[self systemTextFieldForSetAccessor] setBezelStyle:(NSTextFieldBezelStyle)aStyle];
}

- (NSUInteger)bezelStyle
{
    return (NSUInteger)[(NSTextField *)[self systemTextFieldForGetAccessor] bezelStyle];
}

- (void)setBackgroundColor:(id)aColor
{
    [(NSTextField *)[self systemTextFieldForSetAccessor] setBackgroundColor:aColor];
}

- (id)backgroundColor
{
    return [(NSTextField *)[self systemTextFieldForGetAccessor] backgroundColor];
}

- (void)setTextColor:(id)aColor
{
    [(NSTextField *)[self systemTextFieldForSetAccessor] setTextColor:aColor];
}

- (id)textColor
{
    return [(NSTextField *)[self systemTextFieldForGetAccessor] textColor];
}

- (void)setFont:(id)aFont
{
    [(NSTextField *)[self systemTextFieldForSetAccessor] setFont:aFont];
}

- (id)font
{
    return [(NSTextField *)[self systemTextFieldForGetAccessor] font];
}

- (void)setStringValue:(id)aValue
{
    [(NSTextField *)[self systemTextFieldForSetAccessor] setStringValue:aValue];
}

- (id)stringValue
{
    return [(NSTextField *)[self systemTextFieldForGetAccessor] stringValue];
}

- (void)setPlaceholderString:(id)aString
{
    [[(NSTextField *)[self systemTextFieldForSetAccessor] cell] setPlaceholderString:aString];
}

- (id)placeholderString
{
    return [[(NSTextField *)[self systemTextFieldForGetAccessor] cell] placeholderString];
}

- (void)setTextFieldSizes:(id)aSizes
{
    [aSizes retain];
    [_textFieldSizes release];
    _textFieldSizes = aSizes;
}

- (id)textFieldSizes
{
    return _textFieldSizes;
}

- (void)setTextFieldBorderTypes:(id)aTypes
{
    [aTypes retain];
    [_textFieldBorderTypes release];
    _textFieldBorderTypes = aTypes;
}

- (id)textFieldBorderTypes
{
    return _textFieldBorderTypes;
}

- (void)setBorderType:(NSUInteger)aType
{
    _borderType = (unsigned int)aType;
}

- (NSUInteger)borderType
{
    return _borderType;
}

- (id)systemTextFieldForSetAccessor
{
    return [self systemViewForSetAccessor];
}

- (id)systemTextFieldForGetAccessor
{
    return [self systemViewForGetAccessor];
}

- (void)dealloc
{
    [_textFieldSizes release];
    [_textFieldBorderTypes release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil)
        _borderType = 0;
    return self;
}

- (id)templateCocoaView
{
    return [HSVisualSystemViewLoader cocoaViewWithNibName:@"VisualSystemTextField"];
}

@end
