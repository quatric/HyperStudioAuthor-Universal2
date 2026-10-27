#import "KeynoteTextBody.h"

@implementation KeynoteTextBody

- (id)topicsInfo
{
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:2];

    [info setObject:[NSMutableDictionary dictionaryWithCapacity:10] forKey:@"numbers"];
    [info setObject:[NSMutableDictionary dictionaryWithCapacity:10] forKey:@"formats"];
    return info;
}

- (id)layout
{
    id layout = [self keynoteObjectForXMLPath:@"./layout"];

    return layout != nil ? layout : self;
}

- (NSUInteger)verticalAlignment
{
    id styleId = [[[self layout] nodeAttributes] objectForKey:@"style"];

    if (styleId == nil)
        styleId = [[[self keynoteObjectForXMLPath:@"./../.."] nodeAttributes] objectForKey:@"layoutstyle"];

    id alignment = [[[self stylesheet] styleById:styleId] deepStyleChildForXMLPath:@"./property-map/verticalAlignment"];
    if (alignment == nil)
        return 0;

    id number = [[[alignment keynoteObjectForXMLPath:@"./number"] nodeAttributes] objectForKey:@"number"];
    if (number == nil) {
        number = [[[alignment keynoteObjectForXMLPath:@"./decimal-number"] nodeAttributes] objectForKey:@"number"];
        if (number == nil)
            return 0;
    }
    return [number intValue];
}

- (id)attributedText
{
    NSMutableAttributedString *text = [[[NSMutableAttributedString alloc] initWithString:@""] autorelease];
    id stylesheet = [self stylesheet];
    id topicsInfo = [self topicsInfo];
    NSEnumerator *e = [[[self layout] children] objectEnumerator];
    id child;

    while ((child = [e nextObject]) != nil) {
        [child setStylesheet:stylesheet];
        [child setTopicsInfo:topicsInfo];
        [text appendAttributedString:[child attributedText]];
    }
    return text;
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
