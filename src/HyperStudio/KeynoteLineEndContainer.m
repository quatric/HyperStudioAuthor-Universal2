#import "KeynoteLineEndContainer.h"

@implementation KeynoteLineEndContainer

- (id)tailLineEnd
{
    return [[self style] deepStyleChildForXMLPath:@"./property-map/tailLineEnd/line-end"];
}

- (id)headLineEnd
{
    return [[self style] deepStyleChildForXMLPath:@"./property-map/headLineEnd/line-end"];
}

@end
