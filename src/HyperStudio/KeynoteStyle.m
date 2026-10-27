#import "KeynoteStyle.h"

@implementation KeynoteStyle

- (id)deepStringAttributes
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    KeynoteStyle *style = self;
    id stylesheet = [self stylesheet];
    do {
        NSMutableDictionary *styleAttributes = [NSMutableDictionary dictionaryWithDictionary:[style stringAttributes]];
        if (styleAttributes != nil) {
            [styleAttributes addEntriesFromDictionary:attributes];
            attributes = styleAttributes;
        }
        stylesheet = [stylesheet parentStylesheet];
        style = [style parentStyle];
    } while (stylesheet != nil && style != nil);
    return attributes;
}

- (void)createStringAttributes
{
    _stringAttributes = [NSMutableDictionary new];
    NSArray *properties = [[self keynoteObjectForXMLPath:@"./property-map"] children];
    if ([properties count] == 0)
        return;
    NSEnumerator *enumerator = [properties objectEnumerator];
    id property;
    while ((property = [enumerator nextObject]) != nil) {
        NSString *name = [(KeynoteNode *)property name];
        NSDictionary *attributes = [[[property children] lastObject] nodeAttributes];
        id value = nil;
        if ([name isEqualToString:@"fontName"])
            value = [attributes objectForKey:@"string"];
        else if ([name isEqualToString:@"fontSize"])
            value = attributes != nil ? [attributes objectForKey:@"number"] : [NSNumber numberWithFloat:12.0f];
        else if ([name isEqualToString:@"fontColor"])
            value = [(KeynoteColor *)[property keynoteObjectForXMLPath:@"./color"] color];
        else if ([name isEqualToString:@"alignment"])
            value = attributes != nil ? [attributes objectForKey:@"number"] : [NSNumber numberWithInt:0];
        else if ([name isEqualToString:@"lineSpacing"])
            value = [[property keynoteObjectForXMLPath:@"./linespacing"] nodeAttributes];
        else if ([name isEqualToString:@"spaceBefore"] || [name isEqualToString:@"spaceAfter"] || [name isEqualToString:@"tracking"] || [name isEqualToString:@"underline"] || [name isEqualToString:@"bold"] || [name isEqualToString:@"italic"] || [name isEqualToString:@"firstTopicNumber"])
            value = [[[property keynoteObjectForXMLPath:@"./number"] nodeAttributes] objectForKey:@"number"];
        else if ([name isEqualToString:@"listStyle"]) {
            value = [property keynoteObjectForXMLPath:@"./liststyle"];
            if (value == nil) {
                id reference = [property keynoteObjectForXMLPath:@"./liststyle-ref"];
                if (reference != nil)
                    value = [[self stylesheet] styleById:[[reference nodeAttributes] objectForKey:@"IDREF"]];
            }
        }
        if (value != nil)
            [_stringAttributes setObject:value forKey:[(KeynoteNode *)property name]];
    }
}

- (id)deepStyleChildForXMLPath:(id)aPath
{
    KeynoteStyle *style = self;
    do {
        id child = [style keynoteObjectForXMLPath:aPath];
        if (child != nil)
            return child;
        style = [style parentStyle];
    } while (style != nil);
    return nil;
}

- (id)parentStyle
{
    id parent = nil;
    id stylesheet = [self stylesheet];
    while (parent == nil) {
        stylesheet = [stylesheet parentStylesheet];
        if (stylesheet == nil)
            break;
        parent = [stylesheet styleByIdent:[self nodeParentIdent]];
    }
    return parent;
}

- (id)stylesheet
{
    id rootNode = [self rootNode];
    id node = self;
    do {
        if (node == rootNode)
            return nil;
        node = [node keynoteObjectForXMLPath:@".."];
    } while (![[(KeynoteNode *)node name] isEqualToString:@"stylesheet"]);
    return node;
}

- (void)setStringAttributes:(id)aAttributes
{
    if (_stringAttributes != aAttributes) {
        [_stringAttributes release];
        _stringAttributes = [aAttributes retain];
    }
}

- (id)stringAttributes
{
    if (_stringAttributes == nil)
        [self createStringAttributes];
    return _stringAttributes;
}

- (void)didInitFromParser
{
    [super didInitFromParser];
    [[self stylesheet] addStyle:self];
}

- (void)dealloc
{
    [_stringAttributes release];
    [super dealloc];
}

@end
