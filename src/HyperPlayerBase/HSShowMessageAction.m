#import "HSShowMessageAction.h"
#import "HSAlert.h"
#import "HSActionExecutionContext.h"
#import "HSMediaFileWrapper.h"
#import "HSNewMediaAccessor.h"
#import "HSHTML5ExporterHelper.h"
#import "HSiPadExportContext.h"
#import "NSImage+HSImageSize.h"

@implementation HSShowMessageAction

+ (NSInteger)messageStyleFromStringForXMLStoring:(id)aStoring
{
    if ([aStoring isEqualToString:@"HSInformationalAlertStyle"])
        return 1;
    if ([aStoring isEqualToString:@"HSCriticalAlertStyle"])
        return 2;
    if ([aStoring isEqualToString:@"HSMascotAlertStyle"])
        return 3;
    if ([aStoring isEqualToString:@"HSCustomMascotAlertStyle"])
        return 4;
    if ([aStoring isEqualToString:@"HSApplicationAlertStyle"])
        return 5;
    return 0;
}

+ (id)stringForXMLStoringFromMessageStyle:(NSInteger)aStyle
{
    switch (aStyle) {
    case 1:
        return @"HSInformationalAlertStyle";
    case 2:
        return @"HSCriticalAlertStyle";
    case 3:
        return @"HSMascotAlertStyle";
    case 4:
        return @"HSCustomMascotAlertStyle";
    case 5:
        return @"HSApplicationAlertStyle";
    default:
        return @"HSWarningAlertStyle";
    }
}

// Without a custom icon the alert style's standard icon is exported.
- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    NSMutableDictionary *dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
    id media = _messageIconMedia;
    if (media == nil)
        media = [HSNewMedia mediaWithData:[[HSAlert iconForAlertStyle:_alertStyle] hyperPNGRepresentation] name:@"icon" type:@"png"];
    NSString *source = [aContext mediaNameForUID:[media mediaUID]];
    if (source == nil) {
        NSString *filename = [HSHTML5ExporterHelper JSonCorrectFilenameForMedia:media];
        if ([filename length] == 0)
            return nil;
        source = [@"Resources" stringByAppendingPathComponent:filename];
        [aContext addMedia:media];
        [aContext addUID:[media mediaUID] withMediaName:source];
    }
    [dictionary setObject:[NSString stringWithFormat:@"%d", _alertStyle] forKey:@"style"];
    [dictionary setObject:[self buttonTitle] forKey:@"buttonTitle"];
    NSString *message = [HSHTML5ExporterHelper HTML5StringWithAttributedString:[[[NSAttributedString alloc] initWithString:[self messageString]] autorelease]];
    [dictionary setObject:message != nil ? message : @"" forKey:@"messageString"];
    [dictionary setObject:_runAsModalDialog ? @"1" : @"0" forKey:@"runAsModalDialog"];
    [dictionary setObject:source forKey:@"src"];
    return dictionary;
}

- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}

- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    [super importFromXMLElementRepresentation:aRepresentation inContext:aContext];
    NSXMLElement *iconReference = [[aRepresentation elementsForName:@"iconMediaRef"] extraFirstObject];
    [self setMessageIconImageUID:[HSUID UIDWithString:[[iconReference attributeForName:HSXMLStoringRefIdString] stringValue]]];
    [self setMessageString:[[aRepresentation attributeForName:@"message"] stringValue]];
    [self setMessageStyle:[[self class] messageStyleFromStringForXMLStoring:[[aRepresentation attributeForName:@"messageStyle"] stringValue]]];
    [self setButtonTitle:[[aRepresentation attributeForName:@"buttonTitle"] stringValue]];
    [self setRunAsModalDialog:[[[aRepresentation attributeForName:@"runAsModalDialog"] stringValue] hyperBoolValue]];
}

// The icon is stored as converted media keyed "<style>_icon.png", or
// "<uid>_icon.png" for a custom mascot icon.
- (id)XMLElementRepresentationInContext:(id)aContext
{
    NSXMLElement *element = [super XMLElementRepresentationInContext:aContext];
    [element addAttribute:[NSXMLNode attributeWithName:@"message" stringValue:[self messageString]]];
    NSString *style = [[self class] stringForXMLStoringFromMessageStyle:[self messageStyle]];
    [element addAttribute:[NSXMLNode attributeWithName:@"messageStyle" stringValue:style]];
    [element addAttribute:[NSXMLNode attributeWithName:@"buttonTitle" stringValue:[self buttonTitle]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"runAsModalDialog" stringValue:[self runAsModalDialog] ? HSXMLStoring1String : HSXMLStoring0String]];
    BOOL isCustomIcon = NO;
    NSString *key;
    if ([self messageIconImageUID] != nil && [style isEqualToString:@"HSCustomMascotAlertStyle"]) {
        key = [[[self messageIconImageUID] stringValue] stringByAppendingString:@"_icon"];
        isCustomIcon = YES;
    } else {
        key = [style stringByAppendingString:@"_icon"];
    }
    key = [key stringByAppendingPathExtension:@"png"];
    id media = [aContext convertedMediaForKey:key];
    if (media == nil) {
        NSImage *icon = isCustomIcon ? [self messageIcon] : [HSAlert iconForAlertStyle:[self messageStyle]];
        if (icon != nil) {
            media = [HSNewMedia mediaWithData:[icon hyperPNGRepresentation] name:key type:@"png"];
            [aContext setConvertedMedia:media forKey:key];
        }
    }
    if (media != nil) {
        [aContext addMedia:media];
        NSXMLElement *iconReference = [NSXMLElement elementWithName:@"iconMediaRef"];
        [iconReference addAttribute:[NSXMLNode attributeWithName:HSXMLStoringRefIdString stringValue:[[media mediaUID] stringValue]]];
        [element addChild:iconReference];
    }
    return element;
}

- (id)XMLElementName
{
    return @"actShowMessage";
}

- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}

- (BOOL)supportedInIPad
{
    return YES;
}

- (id)ownedMediaUIDs
{
    return [NSCountedSet setWithSet:[self mediaUIDs]];
}

- (id)mediaUIDs
{
    if ([self messageIconMedia] == nil)
        return nil;
    return [NSSet setWithObject:[[self messageIconMedia] mediaUID]];
}

- (void)setMessageIcon:(id)aIcon
{
    [self setMessageIconMedia:aIcon != nil ? [HSNewMedia mediaWithImage:aIcon] : nil];
}

- (id)messageIcon
{
    return [[self messageIconMedia] image];
}

- (void)setMessageIconImageUID:(id)aUID
{
    [self setMessageIconMedia:[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:aUID]];
}

- (id)messageIconImageUID
{
    return [[self messageIconMedia] mediaUID];
}

- (void)setMessageIconMedia:(id)aMedia
{
    if (_messageIconMedia == aMedia)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Message Icon" value:@"" table:@"UndoManager"]];
    [(HSShowMessageAction *)[[self undoManager] prepareWithInvocationTarget:self] setMessageIconMedia:[self messageIconMedia]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSMessageIconImageAttribute) ofObject:self withUserInfo:nil];
    [_messageIconMedia release];
    _messageIconMedia = [aMedia retain];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSMessageIconImageAttribute) ofObject:self withUserInfo:nil];
}

- (id)messageIconMedia
{
    return _messageIconMedia;
}

- (void)setRunAsModalDialog:(BOOL)aDialog
{
    if (_runAsModalDialog == aDialog)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Run As Modal Dialog" value:@"" table:@"UndoManager"]];
    [(HSShowMessageAction *)[[self undoManager] prepareWithInvocationTarget:self] setRunAsModalDialog:[self runAsModalDialog]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSRunAsModalDialogAttribute) ofObject:self withUserInfo:nil];
    _runAsModalDialog = aDialog;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSRunAsModalDialogAttribute) ofObject:self withUserInfo:nil];
}

- (BOOL)runAsModalDialog
{
    return _runAsModalDialog;
}

- (void)setButtonTitle:(id)aTitle
{
    if ([_buttonTitle isEqual:aTitle])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Button Title" value:@"" table:@"UndoManager"]];
    [(HSShowMessageAction *)[[self undoManager] prepareWithInvocationTarget:self] setButtonTitle:[self buttonTitle]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSMessageButtonTitleAttribute) ofObject:self withUserInfo:nil];
    [_buttonTitle release];
    _buttonTitle = [aTitle retain];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSMessageButtonTitleAttribute) ofObject:self withUserInfo:nil];
}

// Note: the lazily created empty string is not retained, yet released in
// dealloc (original behaviour; harmless for the constant empty string).
- (id)buttonTitle
{
    if (_buttonTitle == nil)
        _buttonTitle = [NSString string];
    return _buttonTitle;
}

- (void)setMessageString:(id)aString
{
    if ([_messageString isEqual:aString])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Message Text" value:@"" table:@"UndoManager"]];
    [(HSShowMessageAction *)[[self undoManager] prepareWithInvocationTarget:self] setMessageString:[self messageString]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSMessageStringAttribute) ofObject:self withUserInfo:nil];
    [_messageString release];
    _messageString = [aString retain];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSMessageStringAttribute) ofObject:self
                                        withUserInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:HSValidateMessageString]];
}

- (id)messageString
{
    if (_messageString == nil)
        _messageString = [NSString string];
    return _messageString;
}

- (void)setMessageStyle:(NSInteger)aStyle
{
    if (_alertStyle == aStyle)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Message Style" value:@"" table:@"UndoManager"]];
    [(HSShowMessageAction *)[[self undoManager] prepareWithInvocationTarget:self] setMessageStyle:[self messageStyle]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSMessageStyleAttribute) ofObject:self withUserInfo:nil];
    _alertStyle = (int)aStyle;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSMessageStyleAttribute) ofObject:self withUserInfo:nil];
}

- (NSInteger)messageStyle
{
    return _alertStyle;
}

// contextInfo is self, retained in startInContext:.
- (void)alertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [aEnd release];
    [self notifyDidFinish];
    [self release];
}

- (void)startInContext:(id)aContext
{
    HSAlert *alert = [HSAlert new];
    [alert setAlertStyle:[self messageStyle]];
    [alert setMessageText:[self messageString]];
    [alert addButtonWithTitle:[self buttonTitle]];
    if ([self messageStyle] == 4)
        [alert setIcon:[self messageIcon]];
    BOOL fullscreen = [aContext isFullscreen];
    BOOL modal = [self runAsModalDialog];
    id retainedSelf = [self retain];
    if (modal || fullscreen) {
        NSInteger returnCode = [alert runModal];
        [self alertDidEnd:alert returnCode:returnCode contextInfo:retainedSelf];
    } else {
        [aContext displayAlert:alert modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:retainedSelf];
    }
}

- (BOOL)isSynchronous
{
    return YES;
}

- (BOOL)canChangeSynchronousFlag
{
    return NO;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:
            [NSArray arrayWithObjects:@"messageStyle", @"messageString", @"buttonTitle", @"runAsModalDialog", @"messageIconImageUID", nil]];
}

// Note: _messageIconMedia is never released (original behaviour).
- (void)dealloc
{
    [_messageString release];
    [_buttonTitle release];
    [super dealloc];
}

@end
