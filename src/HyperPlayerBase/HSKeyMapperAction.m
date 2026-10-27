#import "HSKeyMapperAction.h"
// "Map Keys": while its card is shown, keys (with Command / Shift) act as
// clicks on buttons. Each mapping is a dictionary with the character (or
// its code), the Command flag and the button's UID (older stacks stored
// the button's title instead).
@implementation HSKeyMapperAction
- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    NSMutableDictionary *dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
    NSMutableArray *mappings = [NSMutableArray new];
    for (NSDictionary *mapping in [self keyMappings]) {
        NSMutableDictionary *exported = [NSMutableDictionary new];
        for (NSString *key in mapping) {
            if ([key isEqualToString:@"HSKeyMapperActionCharacterKey"] || [key isEqualToString:@"HSKeyMapperActionCharacterCodeKey"])
                continue;
            id value = [mapping objectForKey:key];
            if (![value isKindOfClass:[NSString class]])
                value = [value stringValue];
            [exported setObject:value forKey:key];
        }
        id character = [self specialStringKeyFromCode:[[mapping objectForKey:@"HSKeyMapperActionCharacterCodeKey"] unsignedShortValue]];
        if (character == nil)
            character = [mapping objectForKey:@"HSKeyMapperActionCharacterKey"];
        [exported setObject:character forKey:@"HSKeyMapperActionCharacterKey"];
        [mappings addObject:exported];
        [exported release];
    }
    [dictionary setObject:mappings forKey:@"mappings"];
    [mappings release];
    return dictionary;
}
// Names of function keys for the HTML5 player.
- (id)specialStringKeyFromCode:(unsigned short)aCode
{
    switch (aCode) {
    case 3:
        return @"Enter";
    case 9:
        return @"Tab";
    case 0xd:
        return @"Return";
    case 0x1b:
        return @"Escape";
    case 0x7f:
        return @"Delete";
    case NSUpArrowFunctionKey:
        return @"Up";
    case NSDownArrowFunctionKey:
        return @"Down";
    case NSLeftArrowFunctionKey:
        return @"Left";
    case NSRightArrowFunctionKey:
        return @"Right";
    case NSHomeFunctionKey:
        return @"Home";
    case NSEndFunctionKey:
        return @"End";
    case NSPageUpFunctionKey:
        return @"PageUp";
    case NSPageDownFunctionKey:
        return @"PageDown";
    case NSClearLineFunctionKey:
        return @"Clear";
    case NSHelpFunctionKey:
        return @"Help";
    }
    if ((unsigned short)(aCode - NSF1FunctionKey) < 15)
        return [NSString stringWithFormat:@"F%d", aCode - 0xf703];
    return nil;
}
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return NO;
}
// Old mappings name buttons by title: add the UID of the first button of
// that name in the stack (not undoable).
- (void)addUIDKeyToKeyMappings
{
    NSMutableArray *objects = [NSMutableArray new];
    NSEnumerator *enumerator = [[[self stack] queryHyperInterface:@protocol(HSNodeContainer)] hyperDeepEnumerator];
    id node;
    while ((node = [enumerator nextObject]) != nil) {
        id object = [node queryHyperInterface:@protocol(HSObjectAttributes)];
        if (object != nil)
            [objects addObject:object];
    }
    NSArray *allObjects = [objects copy];
    [objects release];
    NSMutableArray *mappings = [[NSMutableArray alloc] initWithCapacity:[[self keyMappings] count]];
    for (NSDictionary *mapping in [self keyMappings]) {
        if ([mapping objectForKey:@"HSKeyMapperActionObjectUIDKey"] != nil) {
            [mappings addObject:mapping];
            continue;
        }
        NSMutableDictionary *updated = [mapping mutableCopy];
        NSString *title = [mapping objectForKey:@"HSKeyMapperActionObjectTitleKey"];
        for (id object in allObjects) {
            if ([[object hyperName] isEqualToString:title]) {
                [updated setObject:[[object hyperUID] stringValue] forKey:@"HSKeyMapperActionObjectUIDKey"];
                break;
            }
        }
        [mappings addObject:[[updated copy] autorelease]];
        [updated release];
    }
    [[self undoManager] disableUndoRegistration];
    [self setKeyMappings:[[mappings copy] autorelease]];
    [[self undoManager] enableUndoRegistration];
    [allObjects release];
    [mappings release];
}
- (BOOL)isKeyMappingsWithoutUIDKey
{
    for (NSDictionary *mapping in [self keyMappings])
        if ([mapping objectForKey:@"HSKeyMapperActionObjectUIDKey"] == nil)
            return YES;
    return NO;
}
- (id)buttonWithUID:(id)aUID
{
    NSEnumerator *enumerator = [[[self stack] queryHyperInterface:@protocol(HSNodeContainer)] hyperDeepEnumerator];
    id node;
    while ((node = [enumerator nextObject]) != nil) {
        id object = [node queryHyperInterface:@protocol(HSObjectAttributes)];
        if (object != nil && [[[object queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID] isEqual:aUID])
            return object;
    }
    return nil;
}
- (void)checkKeyMappingsForUIDKey
{
    if ([self isKeyMappingsWithoutUIDKey])
        [self addUIDKeyToKeyMappings];
}
- (void)setKeyMappings:(id)aMappings
{
    if ([[self keyMappings] isEqualToArray:aMappings])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Key Mappings" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setKeyMappings:[self keyMappings]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSKeyMappingsAttribute) ofObject:self withUserInfo:nil];
    [_keyMappings release];
    _keyMappings = [aMappings retain];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSKeyMappingsAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}
- (id)keyMappings
{
    if (_keyMappings == nil)
        _keyMappings = [[NSArray alloc] init];
    return _keyMappings;
}
// Merging another key mapper (objects combined into an image): unless the
// image already has a mapping, the highest-priority replaced object's
// mapping moves to the image; mappings of objects that are neither ours
// nor replaced are added.
- (void)mergeInKeyMapperAction:(id)aAction replacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID
{
    NSArray *mappings = [self keyMappings];
    NSMutableSet *UIDs = [NSMutableSet new];
    for (NSDictionary *mapping in mappings)
        [UIDs addObject:[HSUID UIDWithString:[mapping objectForKey:@"HSKeyMapperActionObjectUIDKey"]]];
    NSArray *otherMappings = [aAction keyMappings];
    NSMutableArray *merged = nil;
    if (![UIDs containsObject:aUID]) {
        NSUInteger count = [otherMappings count];
        NSMutableDictionary *indexes = [NSMutableDictionary new];
        for (NSUInteger i = 0; i < count; i++)
            [indexes setObject:[NSNumber numberWithUnsignedInteger:i] forKey:[HSUID UIDWithString:[[otherMappings objectAtIndex:i] objectForKey:@"HSKeyMapperActionObjectUIDKey"]]];
        for (id UID in aPriority) {
            NSNumber *index = [indexes objectForKey:UID];
            if (index == nil)
                continue;
            merged = [mappings mutableCopy];
            NSMutableDictionary *mapping = [[otherMappings objectAtIndex:[index unsignedIntegerValue]] mutableCopy];
            if (mapping != nil) {
                [mapping setValue:[aUID stringValue] forKey:@"HSKeyMapperActionObjectUIDKey"];
                [merged addObject:mapping];
                [mapping release];
            }
            break;
        }
        [indexes release];
    }
    for (NSDictionary *mapping in otherMappings) {
        id UID = [HSUID UIDWithString:[mapping objectForKey:@"HSKeyMapperActionObjectUIDKey"]];
        if ([UIDs containsObject:UID] || [aDs containsObject:UID])
            continue;
        if (merged == nil)
            merged = [mappings mutableCopy];
        [merged addObject:mapping];
    }
    if (merged != nil) {
        [self setKeyMappings:merged];
        [merged release];
    }
    [UIDs release];
}
// The copy for an image replacing objects: the highest-priority replaced
// object's mapping is redirected to the image; the replaced objects'
// mappings are removed (by their index, in priority order).
- (id)copyReplacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID
{
    HSKeyMapperAction *copy = [super copyReplacingObjectUIDs:aDs sortedByPriority:aPriority withImageObjectUID:aUID];
    if (copy == nil)
        return nil;
    NSArray *mappings = [copy keyMappings];
    NSUInteger count = [mappings count];
    NSMutableDictionary *indexes = [NSMutableDictionary new];
    for (NSUInteger i = 0; i < count; i++)
        [indexes setObject:[NSNumber numberWithUnsignedInteger:i] forKey:[HSUID UIDWithString:[[mappings objectAtIndex:i] objectForKey:@"HSKeyMapperActionObjectUIDKey"]]];
    NSMutableArray *updated = nil;
    BOOL redirected = NO;
    NSUInteger removed = 0;
    for (id UID in aPriority) {
        NSNumber *indexNumber = [indexes objectForKey:UID];
        if (indexNumber == nil)
            continue;
        NSUInteger index = [indexNumber unsignedIntegerValue];
        if (!redirected) {
            if (updated == nil)
                updated = [mappings mutableCopy];
            NSMutableDictionary *mapping = [[mappings objectAtIndex:index] mutableCopy];
            if (mapping != nil) {
                [mapping setValue:[aUID stringValue] forKey:@"HSKeyMapperActionObjectUIDKey"];
                [updated addObject:mapping];
                [mapping release];
                redirected = YES;
            }
        }
        [updated removeObjectAtIndex:index - removed];
        removed++;
    }
    [indexes release];
    if (updated != nil) {
        [copy setKeyMappings:updated];
        [updated release];
    }
    return copy;
}
// Characters typed with Shift on a US keyboard.
// Hands the context the key → button map (Shift for capitals and shifted
// symbols).
- (void)startInContext:(id)aContext
{
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    [self checkKeyMappingsForUIDKey];
    for (NSDictionary *mapping in [self keyMappings]) {
        NSString *string = [mapping objectForKey:@"HSKeyMapperActionCharacterKey"];
        if ([string length] == 0) {
            unichar code = [[mapping objectForKey:@"HSKeyMapperActionCharacterCodeKey"] unsignedShortValue];
            string = [NSString stringWithCharacters:&code length:1];
        }
        if ([string length] == 0)
            continue;
        unichar character = [string characterAtIndex:0];
        BOOL command = [[mapping objectForKey:@"HSKeyMapperActionUseCommandKeyKey"] boolValue];
        BOOL shift = [[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:character] || [self isUsedShiftForKey:character];
        id button = [self buttonWithUID:[HSUID UIDWithString:[mapping objectForKey:@"HSKeyMapperActionObjectUIDKey"]]];
        if (button == nil)
            continue;
        HSKeyMapping *key = [[HSKeyMapping alloc] initWithCharacter:character useCommandKey:command useShiftKey:shift];
        [map setObject:button forKey:key];
        [key release];
    }
    [aContext setKeyMappings:[[map copy] autorelease]];
    [self notifyDidFinish];
}
- (BOOL)canChangeSynchronousFlag
{
    return NO;
}
- (BOOL)isSynchronous
{
    return YES;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObject:@"keyMappings"];
}
- (void)dealloc
{
    [_keyMappings release];
    [super dealloc];
}
- (id)buttonWithTitle:(id)aTitle
{
    NSEnumerator *enumerator = [[[self stack] queryHyperInterface:@protocol(HSNodeContainer)] hyperDeepEnumerator];
    id object;
    while ((object = [enumerator nextObject]) != nil) {
        id button = [object queryHyperInterface:@protocol(HSSystemButtonAttributes)];
        if ([[button title] isEqualToString:aTitle])
            return button;
    }
    return nil;
}

@end
