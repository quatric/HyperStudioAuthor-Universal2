#import "HSiPadExporterHelper.h"
@implementation HSiPadExporterHelper
+ (id)MIMETypeForExtension:(id)aExtension
{
    static NSDictionary *MIMETypes;
    if (MIMETypes == nil)
        MIMETypes = [[EXBundleID extraDictionaryNamed:@"MIMETypesByExtension.plist"] retain];
    return [MIMETypes objectForKey:aExtension];
}
+ (id)filenameForCard:(id)aCard
{
    return [[NSString stringWithFormat:@"%@%d", @"card", (int)[aCard hyperIndex]] stringByAppendingPathExtension:@"xml"];
}
@end
