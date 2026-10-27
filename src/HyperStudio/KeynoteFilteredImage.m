#import "KeynoteFilteredImage.h"

@implementation KeynoteFilteredImage

- (NSSize)size
{
    id size = [[[self dataObject] keynoteObjectForXMLPath:@".."] keynoteObjectForXMLPath:@"./size"];
    if (size == nil)
        return NSZeroSize;
    return [(KeynoteSize *)size size];
}

// The filtered data wins over the unfiltered one; either may be a reference
// to another image in the cache.
- (id)dataObject
{
    if (_dataObject == nil) {
        _dataObject = [self keynoteObjectForXMLPath:@"./filtered/data"];
        if (_dataObject == nil) {
            id identifier = [[[self keynoteObjectForXMLPath:@"./filtered-ref"] nodeAttributes] objectForKey:@"IDREF"];
            _dataObject = [[[self cache] objectOfType:@"image" inCacheForId:identifier] dataObject];
        }
        if (_dataObject == nil)
            _dataObject = [self keynoteObjectForXMLPath:@"./unfiltered/data"];
        if (_dataObject == nil) {
            id identifier = [[[self keynoteObjectForXMLPath:@"./unfiltered-ref"] nodeAttributes] objectForKey:@"IDREF"];
            _dataObject = [[[self cache] objectOfType:@"image" inCacheForId:identifier] dataObject];
        }
        [_dataObject retain];
    }
    return _dataObject;
}

- (void)didInitFromParser
{
    [super didInitFromParser];
    id node = [self keynoteObjectForXMLPath:@"./filtered"];
    if (node == nil)
        node = [self keynoteObjectForXMLPath:@"./unfiltered"];
    if (node != nil)
        [[self cache] addObject:self type:@"image" inCacheForId:[node nodeId]];
}

- (void)dealloc
{
    [_dataObject release];
    [super dealloc];
}

@end
