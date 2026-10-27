#import "KeynotePresentation.h"

@implementation KeynotePresentation

- (id)objectOfType:(id)aType inCacheForId:(id)aId
{
    return [[_cache objectForKey:aType] objectForKey:aId];
}

- (void)addObject:(id)aObject type:(id)aType inCacheForId:(id)aId
{
    if (aId && aObject && aType) {
        if (!_cache)
            _cache = [NSMutableDictionary new];
        id typeCache = [_cache objectForKey:aType];
        if (!typeCache) {
            typeCache = [NSMutableDictionary new];
            [_cache setObject:typeCache forKey:aType];
            [typeCache release];
        }
        [typeCache setObject:aObject forKey:aId];
    }
}

- (NSInteger)soundtrackLoopMode
{
    return [[[[self firstKeynoteObjectForXMLPath:@"./soundtrack-list"] nodeAttributes] objectForKey:@"mode"] isEqualToString:@"loop"];
}

- (id)soundtrack
{
    return [self firstKeynoteObjectForXMLPath:@"./soundtrack-list/movie-media"];
}

- (void)setStylesheets:(id)aStylesheets
{
    if (_stylesheets != aStylesheets) {
        [_stylesheets release];
        _stylesheets = [aStylesheets retain];
    }
}

// Collects the stylesheets of every theme, its master slides and every slide,
// keyed by node id.
- (id)stylesheets
{
    if (!_stylesheets) {
        _stylesheets = [NSMutableDictionary new];
        NSArray *themes = [[[self rootNode] keynoteObjectForXMLPath:@"/presentation/theme-list"] children];
        NSInteger themeCount = [themes count];
        for (NSInteger i = 0; i < themeCount; i++) {
            id theme = [themes objectAtIndex:i];
            id stylesheet = [theme keynoteObjectForXMLPath:@"./stylesheet"];
            id stylesheetId = [stylesheet nodeId];
            if (stylesheet && stylesheetId)
                [_stylesheets setObject:stylesheet forKey:stylesheetId];
            NSArray *masterSlides = [[theme keynoteObjectForXMLPath:@"./master-slides"] children];
            NSInteger masterCount = [masterSlides count];
            for (NSInteger j = 0; j < masterCount; j++) {
                id masterStylesheet = [[masterSlides objectAtIndex:j] keynoteObjectForXMLPath:@"./stylesheet"];
                id masterStylesheetId = [masterStylesheet nodeId];
                if (masterStylesheet && masterStylesheetId)
                    [_stylesheets setObject:masterStylesheet forKey:masterStylesheetId];
            }
        }
        NSArray *slides = [[[self rootNode] keynoteObjectForXMLPath:@"/presentation/slide-list"] children];
        NSInteger slideCount = [slides count];
        for (NSInteger i = 0; i < slideCount; i++) {
            id slideStylesheet = [[slides objectAtIndex:i] keynoteObjectForXMLPath:@"./stylesheet"];
            id slideStylesheetId = [slideStylesheet nodeId];
            if (slideStylesheet && slideStylesheetId)
                [_stylesheets setObject:slideStylesheet forKey:slideStylesheetId];
        }
    }
    return _stylesheets;
}

- (id)masterSlides
{
    if (!_masterSlides) {
        _masterSlides = [NSMutableDictionary new];
        NSArray *themes = [[[self rootNode] keynoteObjectForXMLPath:@"/presentation/theme-list"] children];
        NSInteger themeCount = [themes count];
        for (NSInteger i = 0; i < themeCount; i++) {
            NSArray *masterSlides = [[[themes objectAtIndex:i] keynoteObjectForXMLPath:@"./master-slides"] children];
            NSInteger masterCount = [masterSlides count];
            for (NSInteger j = 0; j < masterCount; j++) {
                id masterSlide = [masterSlides objectAtIndex:j];
                id masterSlideId = [masterSlide nodeId];
                if (masterSlide && masterSlideId)
                    [_masterSlides setObject:masterSlide forKey:masterSlideId];
            }
        }
    }
    return _masterSlides;
}

- (void)setStyles:(id)aStyles
{
    if (_styles != aStyles) {
        [_styles release];
        _styles = [aStyles retain];
    }
}

- (id)styles
{
    if (!_styles)
        _styles = [NSMutableDictionary new];
    return _styles;
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
    if (!_stylesByIdent)
        _stylesByIdent = [NSMutableDictionary new];
    return _stylesByIdent;
}

- (NSSize)size
{
    return [(KeynoteSize *)[self childForName:@"size"] size];
}

- (id)slides
{
    return [[self childForClass:[KeynoteSlideList class]] children];
}

- (void)setContent:(id)aContent
{
    if (_content != aContent) {
        [_content release];
        _content = [aContent retain];
    }
}

- (id)content
{
    return _content;
}

- (void)dealloc
{
    [_content release];
    [_styles release];
    [_stylesByIdent release];
    [_stylesheets release];
    [_masterSlides release];
    [_cache release];
    [super dealloc];
}

@end
