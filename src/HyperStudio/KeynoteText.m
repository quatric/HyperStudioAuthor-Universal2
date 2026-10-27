#import "KeynoteText.h"

@implementation KeynoteText

- (void)setText:(id)aText
{
    if (_text != aText) {
        [_text release];
        _text = [aText retain];
    }
}

- (id)text
{
    return _text;
}

- (void)didInitFromParser
{
    [super didInitFromParser];
    [self setText:(NSString *)CFXMLNodeGetString(CFXMLTreeGetNode((CFXMLTreeRef)[self xmlTree]))];
}

- (void)dealloc
{
    [_text release];
    [super dealloc];
}

@end
