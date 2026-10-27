#import "SMKBitmapToolsPrefix.h"


@interface NSEvent_BTKeyBinding_BTKeyEventsInterpreter : NSResponder
{
    SEL *_commandSelectorPtr;
    id *_insertStringPtr;
}
- (void)doCommandBySelector:(SEL)aSelector;
- (void)insertText:(id)aText;
- (void)interpretKeyEvents:(id)aEvents asCommand:(SEL *)aCommand text:(id *)aText;
@end

@interface NSEvent (BTKeyBinding)
+ (id)BT_mergeKeyBindingDictionary:(id)aDictionary intoDictionary:(id)aDictionary2;
+ (void)BT_interpretKeyEvents:(id)aEvents asCommand:(SEL *)aCommand text:(id *)aText;
+ (SEL)BT_commandSelectorForKeyEvents:(id)aEvents usingKeyBindingDictionary:(id)aDictionary;
+ (id)BT_interpretationForKeyEvents:(id)aEvents usingKeyBindingDictionary:(id)aDictionary;
+ (SEL)NSEvent_BTKeyBinding_commandSelectorForKeyEventsInterpretation:(id)aInterpretation;
- (void)BT_interpretAsCommand:(SEL *)aCommand text:(id *)aText;
- (SEL)BT_commandSelectorUsingKeyBindingDictionary:(id)aDictionary;
- (id)BT_interpretationUsingKeyBindingDictionary:(id)aDictionary;
- (id)BT_keyBindingCharacters;
@end

