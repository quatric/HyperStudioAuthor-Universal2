#import "KeynoteBodyPlaceholder.h"

@implementation KeynoteBodyPlaceholder

- (id)textBody
{
    return [self keynoteObjectForXMLPath:@"./text/text-storage/text-body"];
}

// Without a text body the slide's bullets after the headline are joined, one per line.
- (id)createText
{
    id body = [self textBody];
    id stylesheet = [self slideStylesheet];
    if (body != nil) {
        [body setStylesheet:stylesheet];
        return [body attributedText];
    }
    id bullets = [self keynoteObjectForXMLPath:@"./../bullets/headline"];
    if (![bullets isKindOfClass:[NSArray class]])
        return nil;
    NSMutableAttributedString *text = [[[NSMutableAttributedString alloc] initWithString:@""] autorelease];
    NSAttributedString *newline = [[[NSAttributedString alloc] initWithString:@"\n"] autorelease];
    NSUInteger count = [bullets count];
    for (NSUInteger i = 1; i < count; i++) {
        id bulletBody = [[bullets objectAtIndex:i] keynoteObjectForXMLPath:@"./text/text-storage/text-body"];
        [bulletBody setStylesheet:stylesheet];
        id bulletText = [bulletBody attributedText];
        if (bulletText != nil) {
            [text appendAttributedString:bulletText];
            [text appendAttributedString:newline];
        }
    }
    return text;
}

- (BOOL)exportsText
{
    if (![[self slideStyle] isBodyPlaceholderVisible])
        return NO;
    return [super exportsText];
}

@end
