#import "HyperStudioPrefix.h"
#import "KeynoteObject.h"


@interface KeynoteLayers : KeynoteObject
{
}
- (id)drawablesOfLayerAtIndex:(NSUInteger)aIndex;
- (id)foregroundLayerItems;
- (id)backgroundLayerItems;
@end

