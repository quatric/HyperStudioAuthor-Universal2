#import "HyperStudioPrefix.h"


@interface HSXMLNode : NSObject <NSCopying>
{
    struct __CFTree *_root;
}
- (id)data;
- (void)setAttributes:(id)aAttributes;
- (id)attributes;
- (void)setName:(id)aName;
- (struct __CFTree *)elementNamed:(id)aNamed inTree:(struct __CFTree *)aTree;
- (id)elementNamed:(id)aNamed;
- (id)name;
- (id)nameForTree:(struct __CFTree *)aTree;
- (void)dealloc;
- (id)copyWithZone:(NSZone *)aZone;
- (id)initWithTree:(struct __CFTree *)aTree;
- (id)initWithData:(id)aData;
@end

