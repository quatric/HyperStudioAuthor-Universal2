#import "HyperPlayerBasePrefix.h"


@interface NSFont (HSFont)
+ (id)convertedFontWithDictionary:(id)aDictionary replacementFontName:(id)aName;
+ (id)convertedFontWithDictionary:(id)aDictionary;
+ (CGFloat)systemHyperFontSizeForControlSize:(NSUInteger)aSize;
@end

