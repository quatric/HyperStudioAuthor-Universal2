#import "HSExportContext.h"

@implementation HSExportContext

- (id)mediaArray
{
    return [[_mediaArray copy] autorelease];
}

- (void)addMedia:(id)aMedia
{
    if (_mediaArray == nil)
        _mediaArray = [NSMutableArray new];
    [_mediaArray addObject:aMedia];
}

- (id)document
{
    return _document;
}

- (void)dealloc
{
    [_mediaArray release];
    [super dealloc];
}

- (id)init
{
    return [self initWithDocument:nil];
}

- (id)initWithDocument:(id)aDocument
{
    self = [super init];
    if (self != nil)
        _document = aDocument;
    return self;
}

@end
