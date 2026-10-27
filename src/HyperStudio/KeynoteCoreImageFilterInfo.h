#import "HyperStudioPrefix.h"
#import "KeynoteObject.h"


@interface KeynoteCoreImageFilterInfo : KeynoteObject
{
}
- (id)filterName;
- (id)filterDescriptorObject;
- (CGFloat)floatForName:(id)aName inOverrides:(id)aOverrides;
- (id)shadow;
- (void)didInitFromParser;
@end

