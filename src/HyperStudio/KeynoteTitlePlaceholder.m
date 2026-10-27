#import "KeynoteTitlePlaceholder.h"

@implementation KeynoteTitlePlaceholder

// Falls back to the first bullet of the slide's headline list.
- (id)textBody
{
    id body = [self keynoteObjectForXMLPath:@"./text/text-storage/text-body"];
    if (body == nil) {
        body = [self keynoteObjectForXMLPath:@"./../bullets/headline"];
        if ([body isKindOfClass:[NSArray class]])
            body = [body objectAtIndex:0];
        body = [body keynoteObjectForXMLPath:@"./text/text-storage/text-body"];
    }
    return body;
}

- (id)createText
{
    id body = [self textBody];
    [body setStylesheet:[self slideStylesheet]];
    return [body attributedText];
}

- (BOOL)exportsText
{
    if (![[self slideStyle] isTitlePlaceholderVisible])
        return NO;
    return [super exportsText];
}

@end
