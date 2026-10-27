#import "KeynoteSpan.h"

@implementation KeynoteSpan

- (void)setStylesheet:(id)aStylesheet
{
    [super setStylesheet:aStylesheet];
    [[self style] setParagraphStyle:[(KeynoteParagraph *)[self parentNode] style]];
}

@end
