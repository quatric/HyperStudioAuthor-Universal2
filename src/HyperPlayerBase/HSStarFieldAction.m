#import "HSStarFieldAction.h"

@implementation HSStarFieldAction
+ (NSInteger)starFieldDurationModeFromStringForXMLStoring:(id)aStoring
{
    return [aStoring isEqualToString:@"Limited"] ? 1 : 0;
}
+ (id)stringForXMLStoringFromStarFieldDurationType:(NSInteger)aType
{
    return aType == 1 ? @"Limited" : @"Unlimited";
}
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    [super importFromXMLElementRepresentation:aRepresentation inContext:aContext];
    [self setStarFieldDurationMode:[[self class] starFieldDurationModeFromStringForXMLStoring:[[aRepresentation attributeForName:@"starFieldDurationMode"] stringValue]]];
    id duration = [aRepresentation attributeForName:@"starFieldDuration"];
    if (duration)
        [self setStarFieldDuration:[[duration stringValue] doubleValue]];
}
- (id)XMLElementRepresentationInContext:(id)aContext
{
    id element = [super XMLElementRepresentationInContext:aContext];
    [element addAttribute:[NSXMLNode attributeWithName:@"starFieldDurationMode" stringValue:[[self class] stringForXMLStoringFromStarFieldDurationType:[self starFieldDurationMode]]]];
    if ([self starFieldDurationMode] == 1)
        [element addAttribute:[NSXMLNode attributeWithName:@"starFieldDuration" stringValue:[NSString stringWithFormat:@"%.2f", [self starFieldDuration]]]];
    return element;
}
- (id)XMLElementName
{
    return @"actStarField";
}
- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}
- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    id dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
    [dictionary setObject:([self starFieldDurationMode] ? @"HSLimitedDurationMode" : @"HSUnlimitedDurationMode") forKey:@"starFieldDurationMode"];
    [dictionary setObject:[NSString stringWithFormat:@"%.1f", [self starFieldDuration]] forKey:@"starFieldDuration"];
    return dictionary;
}
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}
- (BOOL)supportedInIPad
{
    return YES;
}
- (void)notifyDidFinish
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSActionExecutionContextGraphicCompositionDidEnd" object:_context];
    [_context resumeAllPlayAnimationActions];
    [_context release];
    _context = nil;
    [super notifyDidFinish];
}
- (void)setStarFieldDuration:(double)aDuration
{
    if (_starFieldDuration == aDuration)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Star Field Duration" value:@"" table:@"UndoManager"]];
    [(HSStarFieldAction *)[[self undoManager] prepareWithInvocationTarget:self] setStarFieldDuration:[self starFieldDuration]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSStarFieldDurationAttribute) ofObject:self withUserInfo:nil];
    _starFieldDuration = aDuration;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSStarFieldDurationAttribute) ofObject:self withUserInfo:nil];
}
- (double)starFieldDuration
{
    return _starFieldDuration;
}
- (void)setStarFieldDurationMode:(NSInteger)aMode
{
    if (_starFieldDurationMode == aMode)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Star Field Mode" value:@"" table:@"UndoManager"]];
    [(HSStarFieldAction *)[[self undoManager] prepareWithInvocationTarget:self] setStarFieldDurationMode:[self starFieldDurationMode]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSStarFieldDurationModeAttribute) ofObject:self withUserInfo:nil];
    _starFieldDurationMode = (int)aMode;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSStarFieldDurationModeAttribute) ofObject:self withUserInfo:nil];
}
- (NSInteger)starFieldDurationMode
{
    return _starFieldDurationMode;
}
- (void)HSStarFieldAction_actionExecutionContextGraphicCompositionDidStop:(id)aStop
{
    [self notifyDidFinish];
}
// Plays Stars.qtz over the card; unlimited mode runs until a click.
- (void)startInContext:(id)aContext
{
    if ([aContext isTransitionPlaying]) {
        [self notifyDidFinish];
        return;
    }
    NSString *path = [[HSPlayerBaseID bundle] pathForResource:@"Stars" ofType:@"qtz"];
    if (!path)
        return;
    id composition = [HSQCGraphicComposition compositionWithCompositionFilePath:path];
    if (!composition)
        return;
    BOOL stopOnMouseClick;
    double interval;
    if (_starFieldDurationMode == 0) {
        stopOnMouseClick = YES;
        interval = DBL_MAX;
    } else if (_starFieldDurationMode == 1) {
        interval = _starFieldDuration;
        stopOnMouseClick = NO;
    } else {
        stopOnMouseClick = NO;
        interval = 0.0;
    }
    [aContext pauseAllPlayAnimationActions];
    if ([aContext isGraphicCompositionPlaying])
        [aContext stopGraphicComposition];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSStarFieldAction_actionExecutionContextGraphicCompositionDidStop:) name:@"HSActionExecutionContextGraphicCompositionDidEnd" object:aContext];
    [aContext showGraphicComposition:composition duringTimeInterval:interval stopOnMouseClick:stopOnMouseClick];
    _context = [aContext retain];
}
- (void)stop:(id)aStop
{
    [_context stopGraphicComposition];
    [super stop:aStop];
}
- (BOOL)canBeStopped
{
    return YES;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:@"starFieldDurationMode", @"starFieldDuration", nil]];
}
- (void)dealloc
{
    [_context release];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self)
        _starFieldDuration = 5.0;
    return self;
}
@end
