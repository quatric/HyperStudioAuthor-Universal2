#import "HyperPlayerBasePrefix.h"


@interface HSHTML5ExporterHelper : NSObject
{
}
+ (id)HTMLStringAdaptedToBrowsersSpecific:(id)aSpecific;
+ (id)HTML5StringWithAttributedString:(id)aString;
+ (id)HTMLStringWithRGBAColor:(id)aColor;
+ (id)HTMLStringWithColor:(id)aColor;
+ (id)defaultCardBackgroundImageForCard:(id)aCard;
+ (id)JSonCorrectFilenameForMedia:(id)aMedia andDocumentType:(id)aType;
+ (id)JSonCorrectFilenameForMedia:(id)aMedia;
+ (id)JSonCorrectFilenameWithString:(id)aString;
+ (id)HTML5TemplateResourcesURLs;
@end

