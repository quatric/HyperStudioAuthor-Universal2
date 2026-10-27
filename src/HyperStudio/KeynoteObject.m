#import "KeynoteObject.h"

@implementation KeynoteObject

- (id)description
{
    NSMutableString *result = [NSMutableString stringWithFormat:@"%@ %@ (%@) [%@]\n{\n%@\n", [super description], [self name], NSStringFromClass([self class]), [self xmlPath], [self nodeAttributes]];
    NSUInteger count = [[self children] count];
    for (NSUInteger i = 0; i < count; i++) {
        id child = [[self children] objectAtIndex:i];
        NSString *line = [NSString stringWithFormat:@"   %@ (%@) [%@] {%@}", [(KeynoteNode *)child name], NSStringFromClass([child class]), [child xmlPath], [child nodeAttributes]];
        [result appendFormat:@"%@\n", line];
    }
    [result appendString:@"\n}\n"];
    return result;
}

- (void)didDetail
{
}

- (void)didInitFromParser
{
}

// The node accessors detail the node lazily through the import manager.
- (id)nodeAttributes
{
    [self detailSelf];
    return [super nodeAttributes];
}

- (id)nodeParentIdent
{
    [self detailSelf];
    return [super nodeParentIdent];
}

- (id)nodeIdent
{
    [self detailSelf];
    return [super nodeIdent];
}

- (id)nodeId
{
    [self detailSelf];
    return [super nodeId];
}

- (id)nodeIdRef
{
    [self detailSelf];
    return [super nodeIdRef];
}

- (id)children
{
    [self detailSelf];
    return [super children];
}

- (void)detailChildren
{
    NSUInteger count = [[self children] count];
    for (NSUInteger i = 0; i < count; i++)
        [[[self children] objectAtIndex:i] detailChildren];
}

- (void)detailSelf
{
    if (!_isDetailed) {
        _isDetailed = YES;
        [_importManager specifyDetailForKeynoteObject:self];
    }
}

- (void)setImportManager:(id)aManager
{
    _importManager = aManager;
}

- (id)importManager
{
    return _importManager;
}

- (void)dealloc
{
    _importManager = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self)
        _isDetailed = NO;
    return self;
}

@end
