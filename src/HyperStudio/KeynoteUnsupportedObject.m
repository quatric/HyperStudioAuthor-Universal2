#import "KeynoteUnsupportedObject.h"

@implementation KeynoteUnsupportedObject

- (void)didDetail
{
    [super didDetail];
    [[self importManager] addImportingProblemForCode:0x4e29 point:@"001" info:[self name]];
}

@end
