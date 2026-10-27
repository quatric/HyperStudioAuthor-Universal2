#import "KeynotePlaceholder.h"

@implementation KeynotePlaceholder

- (id)textBackgroundColor
{
    return nil;
}

- (id)textBody
{
    return nil;
}

- (id)createText
{
    return nil;
}

- (NSUInteger)verticalAlignment
{
    id alignment = [[self style] deepStyleChildForXMLPath:@"./property-map/verticalAlignment/number"];
    if (alignment == nil)
        return [[self textBody] verticalAlignment];
    id number = [[alignment nodeAttributes] objectForKey:@"number"];
    if (number == nil)
        return 0;
    return [number intValue];
}

- (id)text
{
    if (_text == nil)
        _text = [[self createText] retain];
    return _text;
}

- (BOOL)exportsText
{
    return [[self text] length] != 0;
}

- (id)geometry
{
    return [[self style] deepStyleChildForXMLPath:@"./property-map/geometry/geometry"];
}

- (id)slideStyle
{
    id identifier = [[[self keynoteObjectForXMLPath:@"./../style-ref"] nodeAttributes] objectForKey:@"IDREF"];
    return [[self slideStylesheet] styleById:identifier];
}

- (id)style
{
    id identifier = [[[self keynoteObjectForXMLPath:@"./style/placeholder-style-ref"] nodeAttributes] objectForKey:@"IDREF"];
    return [[self slideStylesheet] styleById:identifier];
}

- (void)dealloc
{
    [_text release];
    [super dealloc];
}

@end
