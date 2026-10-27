#import "KeynoteSlideNumberPlaceholder.h"

@implementation KeynoteSlideNumberPlaceholder

// The slide number comes from the last "-" component of the slide node id.
- (id)createText
{
    id style = [[self style] deepStyleChildForXMLPath:@"./property-map/layoutStyle/layoutstyle/property-map/layoutParagraphStyle/paragraphstyle"];
    int index = [[[[[self keynoteObjectForXMLPath:@"./.."] nodeId] componentsSeparatedByString:@"-"] lastObject] intValue];
    NSString *number = [NSString stringWithFormat:@"%d", index + 1];
    return [KeynoteTools attributedStringFromString:number withStringAttributes:[style deepStringAttributes]];
}

- (BOOL)exportsText
{
    if (![[self slideStyle] isSlideNumberPlaceholderVisible])
        return NO;
    return [super exportsText];
}

@end
