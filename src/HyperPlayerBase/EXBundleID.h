#import "HyperPlayerBasePrefix.h"


@interface EXBundleID : NSObject
{
}
+ (BOOL)loadNibNamed:(id)aNamed owner:(id)aOwner;
+ (id)localizedString:(id)aString fromTable:(id)aTable;
+ (id)localizedString:(id)aString;
+ (id)extraDictionaryNamed:(id)aNamed;
+ (id)identifier;
+ (NSUInteger)signature;
+ (id)infoDictionary;
+ (id)bundle;
@end

