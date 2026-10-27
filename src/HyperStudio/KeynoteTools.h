#import "HyperStudioPrefix.h"


@interface KeynoteTools : NSObject
{
}
+ (id)stringWithKeynoteString:(id)aString;
+ (Class)classForXMLTreeName:(id)aName;
+ (id)classNamesForKeynote;
+ (id)parseSelectorNameSuffixForXMLTreeName:(id)aName;
+ (id)suffixForXMLTreeName:(id)aName;
+ (id)attributedStringFromString:(id)aString withStringAttributes:(id)aAttributes;
+ (NSInteger)playLoopModeWithAttributesDictionary:(id)aDictionary;
+ (id)pathWithAttributesDictionary:(id)aDictionary;
+ (BOOL)verticalFlipWithAttributesDictionary:(id)aDictionary;
+ (BOOL)horizontalFlipWithAttributesDictionary:(id)aDictionary;
+ (NSInteger)fractionWithAttributesDictionary:(id)aDictionary;
+ (NSInteger)scaleTypeWithAttributesDictionary:(id)aDictionary;
+ (CGFloat)angleWithAttributesDictionary:(id)aDictionary;
+ (CGFloat)angleWithFloat:(CGFloat)aFloat;
+ (CGFloat)angleAsDegreeWithAttributesDictionary:(id)aDictionary;
+ (CGFloat)angleAsDegreeWithFloat:(CGFloat)aFloat;
+ (NSPoint)pointWithAttributesDictionary:(id)aDictionary;
+ (NSSize)sizeWithAttributesDictionary:(id)aDictionary;
@end

