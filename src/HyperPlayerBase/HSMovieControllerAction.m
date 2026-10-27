#import "HSMovieControllerAction.h"
// The "Control Movie" action: plays, pauses, steps or resets the movie of
// its card. Commands 0 play, 1 stop (pause), 2 step forward, 3 step back,
// 4 reset, 5 play/pause; playing finishes when the movie stops.
@implementation HSMovieControllerAction
+ (NSInteger)movieControllerCommandTypeFromStringForXMLStoring:(id)aStoring
{
    if ([aStoring isEqualToString:@"stop"])
        return 1;
    if ([aStoring isEqualToString:@"stepForward"])
        return 2;
    if ([aStoring isEqualToString:@"stepBack"])
        return 3;
    if ([aStoring isEqualToString:@"reset"])
        return 4;
    return [aStoring isEqualToString:@"playPause"] ? 5 : 0;
}
+ (id)stringForXMLStoringFromMovieControllerCommandType:(NSInteger)aType
{
    switch (aType) {
    case 1:
        return @"stop";
    case 2:
        return @"stepForward";
    case 3:
        return @"stepBack";
    case 4:
        return @"reset";
    case 5:
        return @"playPause";
    default:
        return @"play";
    }
}
- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    NSMutableDictionary *dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
    [dictionary setObject:[NSString stringWithFormat:@"%i", (int)[self movieCommand]] forKey:@"command"];
    return dictionary;
}
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    [super importFromXMLElementRepresentation:aRepresentation inContext:aContext];
    NSString *command = [[aRepresentation attributeForName:@"commandType"] stringValue];
    [self setMovieCommand:[[self class] movieControllerCommandTypeFromStringForXMLStoring:command]];
}
- (id)XMLElementRepresentationInContext:(id)aContext
{
    NSXMLElement *element = [super XMLElementRepresentationInContext:aContext];
    NSString *command = [[self class] stringForXMLStoringFromMovieControllerCommandType:[self movieCommand]];
    [element addAttribute:[NSXMLNode attributeWithName:@"commandType" stringValue:command]];
    return element;
}
- (id)XMLElementName
{
    return @"actMovieController";
}
- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}
- (void)hyperPlayableObjectDidStop:(id)aStop
{
    [self notifyDidFinish];
}
- (BOOL)supportedInIPad
{
    return YES;
}
- (void)setMovieCommand:(NSInteger)aCommand
{
    if ([self movieCommand] == aCommand)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Command" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setMovieCommand:[self movieCommand]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSMovieCommandAttribute) ofObject:self withUserInfo:nil];
    _movieCommand = (int)aCommand;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSMovieCommandAttribute) ofObject:self withUserInfo:nil];
}
- (NSInteger)movieCommand
{
    return _movieCommand;
}
// Play and play/pause pass the action itself as the movie's observer and
// finish in hyperPlayableObjectDidStop: when a movie started; the other
// commands finish at once.
- (void)startInContext:(id)aContext
{
    HSActionExecutionContext *context = aContext;
    switch ([self movieCommand]) {
    case 0:
        if ([context playMovie:self onCard:[self card]])
            return;
        break;
    case 1:
        [context pauseMovieOnCard:[self card]];
        break;
    case 2:
        [context stepForwardOnCard:[self card]];
        break;
    case 3:
        [context stepBackwardOnCard:[self card]];
        break;
    case 4:
        [context resetMovieOnCard:[self card]];
        break;
    case 5:
        if ([context playPauseMovie:self onCard:[self card]])
            return;
        break;
    }
    [self notifyDidFinish];
}
// (Old documents also stored a movie UID; it's read and ignored.)
- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    NSArray *keys = [NSArray arrayWithObjects:@"movieUID", @"movieCommand", nil];
    return [[super keysForExtraLoadingWithCodingContext:aContext] arrayByAddingObjectsFromArray:keys];
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSArray *keys = [NSArray arrayWithObjects:@"movieCommand", nil];
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:keys];
}
- (void)setMovieUID:(id)aUID
{
}
@end
