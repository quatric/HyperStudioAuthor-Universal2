#import "KeynoteItem.h"

@implementation KeynoteItem

- (void)setStyleIdRef:(id)aRef
{
    if (_styleIdRef != aRef) {
        [_styleIdRef release];
        _styleIdRef = [aRef retain];
    }
}

- (id)styleIdRef
{
    if (_styleIdRef == nil)
        [self setStyleIdRef:[[self keynoteObjectForXMLPath:@"./style/graphic-style-ref"] nodeIdRef]];
    return _styleIdRef;
}

- (id)hyperlink
{
    return [[self nodeAttributes] objectForKey:@"href"];
}

- (BOOL)isLocked
{
    NSString *locked = [[self nodeAttributes] objectForKey:@"locked"];
    if (locked == nil)
        return NO;
    return [locked isEqualToString:@"true"];
}

- (id)themeStyle
{
    return [[self slideStylesheet] themeStyleById:[self styleIdRef]];
}

- (id)masterStyle
{
    return [[self slideStylesheet] masterSlideStyleById:[self styleIdRef]];
}

- (id)style
{
    return [[self slideStylesheet] styleById:[self styleIdRef]];
}

- (id)geometry
{
    return [self keynoteObjectForXMLPath:@"./geometry"];
}

- (id)slide
{
    id root = [self rootNode];
    KeynoteNode *node = self;
    while (![[node name] isEqualToString:@"slide"] && ![[node name] isEqualToString:@"master-slide"]) {
        node = [node keynoteObjectForXMLPath:@".."];
        if (node == nil || node == root)
            return nil;
    }
    return node;
}

- (id)slideStylesheet
{
    return [[self slide] keynoteObjectForXMLPath:@"./stylesheet"];
}

- (void)didDetail
{
    [super didDetail];
    NSString *hyperlink = [self hyperlink];
    if ([hyperlink hasPrefix:@"keynote:"]) {
        NSString *path = [hyperlink substringFromIndex:[@"keynote:" length]];
        if (![[NSFileManager defaultManager] hyperIsFileReadableAtPath:path])
            [[self importManager] addImportingProblemForCode:0x4e2c point:@"004" info:path];
    }
}

- (void)dealloc
{
    [_styleIdRef release];
    [super dealloc];
}

@end
