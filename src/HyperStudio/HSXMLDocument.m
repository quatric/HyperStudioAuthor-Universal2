#import "HSXMLDocument.h"

@implementation HSXMLDocument

- (id)data
{
    return [_xmlRoot data];
}

- (id)rootElement
{
    return _xmlRoot;
}

- (void)dealloc
{
    [_xmlRoot release];
    [super dealloc];
}

- (id)initWithData:(id)aData
{
    self = [self init];
    if (self != nil) {
        _xmlRoot = [[HSXMLNode alloc] initWithData:aData];
        if (_xmlRoot == nil) {
            [self release];
            return nil;
        }
    }
    return self;
}

@end
