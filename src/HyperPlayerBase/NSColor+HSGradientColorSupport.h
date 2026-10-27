#import "HyperPlayerBasePrefix.h"


@interface NSColor (HSGradientColorSupport)
- (id)hyperGradientColor;
@end

@interface NSColor (HSExtensions)
+ (id)hyperColorWithDictionary:(id)aDictionary;
+ (CGFloat)hyperValueForColorComponentName:(id)aName dictionary:(id)aDictionary;
+ (id)hyperColorWithString:(id)aString;
- (id)hyperStringRepresentation;
@end

