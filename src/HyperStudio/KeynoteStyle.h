#import "HyperStudioPrefix.h"
#import "KeynoteObject.h"


@interface KeynoteStyle : KeynoteObject
{
    NSMutableDictionary *_stringAttributes;
}
- (id)deepStringAttributes;
- (void)createStringAttributes;
- (id)deepStyleChildForXMLPath:(id)aPath;
- (id)parentStyle;
- (id)stylesheet;
- (void)setStringAttributes:(id)aAttributes;
- (id)stringAttributes;
- (void)didInitFromParser;
- (void)dealloc;
@end

