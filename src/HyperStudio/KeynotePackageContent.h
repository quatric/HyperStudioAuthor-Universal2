#import "HyperStudioPrefix.h"


@interface KeynotePackageContent : NSObject
{
    NSDictionary *_resources;
    struct __CFTree *_indexXmlTree;
}
- (void)setIndexXmlTree:(struct __CFTree *)aTree;
- (struct __CFTree *)indexXmlTree;
- (void)setResources:(id)aResources;
- (id)resources;
- (void)dealloc;
@end

