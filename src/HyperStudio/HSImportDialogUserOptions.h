#import "HyperStudioPrefix.h"


@interface HSImportDialogUserOptions : NSObject <EXKeyValueCoding>
{
    NSMutableDictionary *_optionsDictionary;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)optionsDictionary;
- (void)setOptionsDictionary:(id)aDictionary;
- (void)setValue:(id)aValue forUndefinedKey:(id)aKey;
- (id)valueForUndefinedKey:(id)aKey;
- (id)copy;
- (void)dealloc;
@end

