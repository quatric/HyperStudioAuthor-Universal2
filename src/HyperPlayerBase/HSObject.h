#import "HyperPlayerBasePrefix.h"
#import "HSWeaklyReferencedObject.h"


@interface HSObject : HSWeaklyReferencedObject <HyperInterface, NSObject>
{
    NSMapTable *_intefaceIdentifiers;
}
- (CGFloat)extraCodingVersion;
- (BOOL)conformsToProtocol:(id)aProtocol;
- (id)intefaceIdentifiers;
- (void)dealloc;
@end

