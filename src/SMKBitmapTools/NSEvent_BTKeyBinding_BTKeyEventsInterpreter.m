#import "NSEvent_BTKeyBinding_BTKeyEventsInterpreter.h"

// Key events as the text system's key bindings see them: the command (or
// text) the standard bindings give them, and lookups in binding dictionaries
// of the same form (keys like "@~a", nested dictionaries for sequences).

@implementation NSEvent_BTKeyBinding_BTKeyEventsInterpreter

- (void)interpretKeyEvents:(id)aEvents asCommand:(SEL *)aCommand text:(id *)aText
{
    _commandSelectorPtr = aCommand;
    _insertStringPtr = aText;
    [self interpretKeyEvents:aEvents];
    if (_insertStringPtr)
        [*_insertStringPtr autorelease];
    _commandSelectorPtr = NULL;
    _insertStringPtr = NULL;
}

- (void)insertText:(id)aText
{
    if (_insertStringPtr)
        *_insertStringPtr = [aText copy];
}

- (void)doCommandBySelector:(SEL)aSelector
{
    if (_commandSelectorPtr)
        *_commandSelectorPtr = aSelector;
}

@end

@implementation NSEvent (BTKeyBinding)

// The binding key: @ command, ^ control, ~ option, $ shift (only for return,
// space and keys past the main block, as other keys' characters show it).
- (id)BT_keyBindingCharacters
{
    NSEventModifierFlags flags = [self modifierFlags];
    NSMutableString *key = [NSMutableString string];
    if (flags & NSEventModifierFlagCommand)
        [key appendString:@"@"];
    if (flags & NSEventModifierFlagControl)
        [key appendString:@"^"];
    if (flags & NSEventModifierFlagOption)
        [key appendString:@"~"];
    if (flags & NSEventModifierFlagShift) {
        unsigned short code = [self keyCode];
        if (code == 0x24 || code == 0x31 || code > 0x32)
            [key appendString:@"$"];
    }
    [key appendString:[self charactersIgnoringModifiers]];
    return key;
}

- (id)BT_interpretationUsingKeyBindingDictionary:(id)aDictionary
{
    NSString *key = [self BT_keyBindingCharacters];
    return key ? [aDictionary objectForKey:key] : nil;
}

- (SEL)BT_commandSelectorUsingKeyBindingDictionary:(id)aDictionary
{
    return [[self class] NSEvent_BTKeyBinding_commandSelectorForKeyEventsInterpretation:
                             [self BT_interpretationUsingKeyBindingDictionary:aDictionary]];
}

- (void)BT_interpretAsCommand:(SEL *)aCommand text:(id *)aText
{
    NSArray *events = [NSArray arrayWithObject:self];
    if (events)
        [[self class] BT_interpretKeyEvents:events asCommand:aCommand text:aText];
}

+ (SEL)NSEvent_BTKeyBinding_commandSelectorForKeyEventsInterpretation:(id)aInterpretation
{
    if (![aInterpretation isKindOfClass:[NSString class]])
        return NULL;
    return NSSelectorFromString(aInterpretation);
}

// Each event but the last must lead to a nested dictionary.
+ (id)BT_interpretationForKeyEvents:(id)aEvents usingKeyBindingDictionary:(id)aDictionary
{
    NSEnumerator *events = [aEvents objectEnumerator];
    id interpretation = aDictionary;
    NSEvent *event = [events nextObject];
    while (event) {
        interpretation = [event BT_interpretationUsingKeyBindingDictionary:interpretation];
        if (!interpretation || !(event = [events nextObject]))
            break;
        if (![interpretation isKindOfClass:[NSDictionary class]])
            return nil;
    }
    return interpretation;
}

+ (SEL)BT_commandSelectorForKeyEvents:(id)aEvents usingKeyBindingDictionary:(id)aDictionary
{
    return [self NSEvent_BTKeyBinding_commandSelectorForKeyEventsInterpretation:
                     [self BT_interpretationForKeyEvents:aEvents usingKeyBindingDictionary:aDictionary]];
}

+ (void)BT_interpretKeyEvents:(id)aEvents asCommand:(SEL *)aCommand text:(id *)aText
{
    [[[[NSEvent_BTKeyBinding_BTKeyEventsInterpreter alloc] init] autorelease] interpretKeyEvents:aEvents
                                                                                       asCommand:aCommand
                                                                                            text:aText];
}

// The second dictionary with the first's entries over it (nested
// dictionaries merged).
+ (id)BT_mergeKeyBindingDictionary:(id)aDictionary intoDictionary:(id)aDictionary2
{
    if (!aDictionary2)
        return aDictionary;
    if (!aDictionary)
        return aDictionary2;
    NSMutableDictionary *merged = [NSMutableDictionary dictionaryWithDictionary:aDictionary2];
    Class dictionaryClass = [NSDictionary class];
    for (id key in aDictionary) {
        id value = [aDictionary objectForKey:key];
        id old = [aDictionary2 objectForKey:key];
        if ([old isKindOfClass:dictionaryClass] && [value isKindOfClass:dictionaryClass]) {
            id nested = [self BT_mergeKeyBindingDictionary:value intoDictionary:old];
            if (!nested)
                continue;
            value = nested;
        }
        [merged setObject:value forKey:key];
    }
    return [[merged copy] autorelease];
}

@end
