#import "KeynoteBuild.h"

@implementation KeynoteBuild

- (id)referencedMediaId
{
    return [[[self keynoteObjectForXMLPath:@"./info-ref"] nodeAttributes] objectForKey:@"IDREF"];
}

- (NSInteger)buildType
{
    return [[[[self keynoteObjectForXMLPath:@"./style"] nodeAttributes] objectForKey:@"type"] isEqualToString:@"apple:movie-start"];
}

@end
