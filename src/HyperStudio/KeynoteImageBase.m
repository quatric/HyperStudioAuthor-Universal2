#import "KeynoteImageBase.h"

@implementation KeynoteImageBase

- (id)media
{
    if (_media == nil) {
        id nodeId = [[self dataObject] nodeId];
        _media = [[[self cache] objectOfType:@"hsNewMedia" inCacheForId:nodeId] retain];
        if (_media == nil) {
            NSString *path = [self path];
            _media = [[HSNewMedia mediaWithData:[self data] name:[[path lastPathComponent] stringByDeletingPathExtension] type:[path pathExtension]] retain];
            [[self cache] addObject:_media type:@"hsNewMedia" inCacheForId:nodeId];
        }
    }
    return _media;
}

- (id)path
{
    return [[self dataObject] path];
}

- (id)data
{
    return [[self dataObject] data];
}

- (id)image
{
    return [[self dataObject] image];
}

- (NSSize)size
{
    [self doesNotRecognizeSelector:_cmd];
    return NSZeroSize;
}

- (id)dataObject
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)didDetail
{
    [super didDetail];
    if (![[self dataObject] containsValidData])
        [[self importManager] addImportingProblemForCode:0x4e2c point:@"003" info:[self path]];
}

- (void)dealloc
{
    [_media release];
    [super dealloc];
}

@end
