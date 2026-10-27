#import "KeynoteParagraph.h"

@implementation KeynoteParagraph

// Prefixes the paragraph with its list bullet and three spaces per indent level.
- (void)applyListLevel:(NSInteger)aLevel withStringAttributes:(id)aAttributes toMutableAttributedString:(id)aString
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:aAttributes];
    id listStyle;
    NSMutableString *indent;
    NSInteger i;

    [attributes setObject:[NSNumber numberWithInt:0] forKey:@"alignment"];
    listStyle = [aAttributes objectForKey:@"listStyle"];
    if (listStyle != nil) {
        [listStyle setTopicsInfo:[self topicsInfo]];
        [listStyle applyTo:aString withStringAttributes:attributes listLevel:aLevel];
    }
    indent = [NSMutableString string];
    for (i = aLevel; i > 0; i--)
        [indent appendString:@"   "];
    [aString insertAttributedString:[KeynoteTools attributedStringFromString:indent withStringAttributes:attributes] atIndex:0];
}

- (id)attributedText
{
    NSMutableAttributedString *text = [[[NSMutableAttributedString alloc] initWithString:@""] autorelease];
    id attributes = [[self style] deepStringAttributes];
    NSEnumerator *e = [[self children] objectEnumerator];
    id child;

    while ((child = [e nextObject]) != nil) {
        NSString *string = nil;
        NSString *name = [(KeynoteNode *)child name];
        id linkAttributes = nil;

        if ([child isKindOfClass:[KeynoteParagraph class]]) {
            [child setStylesheet:[self stylesheet]];
            [text appendAttributedString:[child attributedText]];
            continue;
        }
        if ([child isKindOfClass:[KeynoteText class]]) {
            string = [child text];
        } else if ([name isEqualToString:@"br"] || [name isEqualToString:@"intratopicbr"] || [name isEqualToString:@"lnbr"]) {
            string = @"\n";
        } else if ([name hasPrefix:@"#x"]) {
            unichar character = [[name substringFromIndex:[@"#x" length]] hyperUnicharValue];
            string = [NSString stringWithCharacters:&character length:1];
        } else if ([name isEqualToString:@"link"]) {
            string = [[child nodeAttributes] objectForKey:@"href"];
            linkAttributes = [[[self stylesheet] styleById:[[[child firstKeynoteObjectForXMLPath:@"./span"] nodeAttributes] objectForKey:@"style"]] deepStringAttributes];
        }
        if (string == nil)
            continue;

        id piece = [KeynoteTools attributedStringFromString:string withStringAttributes:attributes];
        if (linkAttributes != nil)
            piece = [KeynoteTools attributedStringFromString:string withStringAttributes:linkAttributes];
        if (piece != nil)
            [text appendAttributedString:piece];
    }

    id level = [[self nodeAttributes] objectForKey:@"list-level"];
    [self applyListLevel:level != nil ? [level intValue] : 0 withStringAttributes:attributes toMutableAttributedString:text];
    return text;
}

- (void)setTopicsInfo:(id)aInfo
{
    _topicsInfo = aInfo;
}

- (id)topicsInfo
{
    return _topicsInfo;
}

- (id)style
{
    return [_stylesheet styleById:[[self nodeAttributes] objectForKey:@"style"]];
}

- (id)stylesheet
{
    return _stylesheet;
}

- (void)setStylesheet:(id)aStylesheet
{
    _stylesheet = aStylesheet;
}

@end
