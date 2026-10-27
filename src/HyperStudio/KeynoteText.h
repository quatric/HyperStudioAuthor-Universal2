#import "HyperStudioPrefix.h"
#import "KeynoteObject.h"


@interface KeynoteText : KeynoteObject
{
    NSString *_text;
}
- (void)setText:(id)aText;
- (id)text;
- (void)didInitFromParser;
- (void)dealloc;
@end

