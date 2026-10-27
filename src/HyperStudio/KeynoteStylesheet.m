#import "KeynoteStylesheet.h"

@implementation KeynoteStylesheet

- (id)parentStylesheet
{
    return [[[self rootNode] stylesheets] objectForKey:[self nodeIdRef]];
}

- (id)themeStyleById:(id)aId
{
    id parent = [[[self rootNode] stylesheets] objectForKey:[self nodeIdRef]];
    id theme = [[[self rootNode] stylesheets] objectForKey:[parent nodeIdRef]];
    return [[theme stylesById] objectForKey:aId];
}

- (id)masterSlideStyleById:(id)aId
{
    return [[[[[self rootNode] stylesheets] objectForKey:[self nodeIdRef]] stylesById] objectForKey:aId];
}

- (id)styleByIdent:(id)aIdent
{
    return [[self stylesByIdent] objectForKey:aIdent];
}

- (id)styleById:(id)aId
{
    return [[self stylesById] objectForKey:aId];
}

- (void)setStylesByIdent:(id)aIdent
{
    if (_stylesByIdent != aIdent) {
        [_stylesByIdent release];
        _stylesByIdent = [aIdent retain];
    }
}

- (id)stylesByIdent
{
    return _stylesByIdent;
}

- (void)setStylesById:(id)aId
{
    if (_stylesById != aId) {
        [_stylesById release];
        _stylesById = [aId retain];
    }
}

- (id)stylesById
{
    return _stylesById;
}

- (void)addStyle:(id)aStyle
{
    if (_stylesById == nil)
        _stylesById = [NSMutableDictionary new];
    if (_stylesByIdent == nil)
        _stylesByIdent = [NSMutableDictionary new];
    id styleId = [aStyle nodeId];
    if (styleId != nil)
        [_stylesById setObject:aStyle forKey:styleId];
    id ident = [aStyle nodeIdent];
    if (ident != nil)
        [_stylesByIdent setObject:aStyle forKey:ident];
}

- (void)didInitFromParser
{
    [super didInitFromParser];
    [self setNodeIdRef:[[self keynoteObjectForXMLPath:@"./parent-ref"] nodeIdRef]];
}

- (void)dealloc
{
    [_stylesById release];
    [_stylesByIdent release];
    [super dealloc];
}

@end
