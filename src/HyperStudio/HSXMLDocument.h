#import "HyperStudioPrefix.h"


@interface HSXMLDocument : NSObject
{
    HSXMLNode *_xmlRoot;
}
- (id)data;
- (id)rootElement;
- (void)dealloc;
- (id)initWithData:(id)aData;
@end

