#import "KeynoteCharacterstyle.h"

@implementation KeynoteCharacterstyle

// Character attributes override those of the paragraph style.
- (id)deepStringAttributes
{
    id attributes = [super deepStringAttributes];
    NSMutableDictionary *merged = [NSMutableDictionary dictionaryWithDictionary:[[self paragraphStyle] deepStringAttributes]];
    [merged addEntriesFromDictionary:attributes];
    return merged;
}

- (id)paragraphStyle
{
    return _paragraphStyle;
}

- (void)setParagraphStyle:(id)aStyle
{
    _paragraphStyle = aStyle;
}

@end
