#import "HSChangeCardAction.h"
#import "HSActionExecutionContext.h"
#import "HSAlert.h"
#import "HSCursorSynchronizer.h"
#import "HSExecutableResourceProvider.h"
#import "HSNavigationController.h"
#import "HSNavigationOperation.h"
#import "HSQTTransition.h"
#import "HSTransitionEffectProvider.h"
#import "HSUID.h"
#import "HSView.h"

// Number of card changes in flight; only one navigation runs at a time.
static int sRunningNavigationCount = 0;

@implementation HSChangeCardAction

- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    [super importFromXMLElementRepresentation:aRepresentation inContext:aContext];
    id element = [[aRepresentation elementsForName:@"transition"] extraFirstObject];
    NSString *name = [[element attributeForName:@"name"] stringValue];
    double duration = [[[element attributeForName:@"duration"] stringValue] doubleValue];
    HSTransition *transition = [HSTransition transitionWithName:name];
    if (transition == nil)
        transition = [[[HSTransition alloc] init] autorelease];
    [transition setDuration:duration];
    [self setTransition:transition];
}

- (id)XMLElementRepresentationInContext:(id)aContext
{
    id element = [super XMLElementRepresentationInContext:aContext];
    id transitionElement = [self xmlTransitionElement];
    if (transitionElement != nil)
        [element addChild:transitionElement];
    return element;
}

- (id)xmlTransitionElement
{
    NSXMLElement *element = [NSXMLElement elementWithName:@"transition"];
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    HSTransition *transition = [self transition];
    if (transition == nil) {
        element = nil;
    } else {
        [element addAttribute:[NSXMLNode attributeWithName:@"uid" stringValue:[[HSUID UID] stringValue]]];
        [element addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:[transition transitionName]]];
        [element addAttribute:[NSXMLNode attributeWithName:@"duration" stringValue:[NSString stringWithFormat:@"%.1f", [transition duration]]]];
    }
    [pool release];
    return element;
}

- (id)HTML5UnsupportedFeaturesForDocumentType:(id)aType
{
    return [[self transition] HTML5UnsupportedFeaturesForDocumentType:aType];
}

- (BOOL)hasUnsupportedHTML5FeaturesForDocumentType:(id)aType
{
    if ([super hasUnsupportedHTML5FeaturesForDocumentType:aType])
        return YES;
    return [[self transition] hasUnsupportedHTML5FeaturesForDocumentType:aType];
}

- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    if (![self isValid])
        return nil;
    id dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
    HSTransition *transition = [self transition];
    if (transition != nil) {
        [dictionary setObject:[HSTransitionEffectProvider exportTransitionNameForTransitionName:[transition transitionName]] forKey:@"effect"];
        [dictionary setObject:[NSString stringWithFormat:@"%.1f", [transition duration]] forKey:@"duration"];
    }
    return dictionary;
}

- (void)stopCurrentNavigationOperation
{
    [self notifyDidFinish];
    _isRunning = NO;
    sRunningNavigationCount--;
}

- (void)notifyDidFinish
{
    [_context release];
    _context = nil;
    [super notifyDidFinish];
}

- (void)alertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [self notifyDidFinish];
}

- (void)navigationOperationStageDidChange:(id)aChange
{
    HSNavigationOperation *operation = [aChange object];
    if ([operation stage] != 3 && [operation stage] != 4)
        return;
    [self willConcludeNavigationOperation:operation];
    [self stopCurrentNavigationOperation];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSNavigationOperationStageDidChangeNotification" object:operation];
    [_navigationOperation release];
    _navigationOperation = nil;
}

- (void)startInContext:(id)aContext
{
    _context = [aContext retain];
    if (![self canGoToHyperDestinationCard]) {
        [aContext displayAlert:[self alert] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:NULL];
        [_context release];
        _context = nil;
    } else {
        [HSCursor clearCursor];
        [self performSelector:@selector(setAndPerformNavigationOperationInContext:) withObject:_context afterDelay:0.0];
    }
}

- (BOOL)canRunInContext:(id)aContext
{
    return sRunningNavigationCount == 0;
}

- (BOOL)canBeStopped
{
    return !_isRunning;
}

- (void)setAndPerformNavigationOperationInContext:(id)aContext
{
    id cardView = [[self document] cardView];
    if (cardView == nil)
        return;

    _isRunning = YES;
    if (sRunningNavigationCount++ != 0) {
        // Another card change is already in progress.
        [self stopCurrentNavigationOperation];
        return;
    }

    _navigationOperation = [self createNavigationOperation];
    [_navigationOperation setSourceCard:[self card]];
    [_navigationOperation setSourceCardUserSpaceToViewSpaceTransform:[cardView userSpaceToViewSpaceCGAffineTransform]];
    [_navigationOperation setSourceCardViewTransform:[cardView NSE_affineTransformToView:nil]];
    [_navigationOperation setUserInfo:[NSDictionary dictionaryWithObject:self forKey:@"HSNavigationOperationActionKey"]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navigationOperationStageDidChange:) name:@"HSNavigationOperationStageDidChangeNotification" object:_navigationOperation];
    [self willStartNavigationOperation:_navigationOperation];

    if ([[aContext navigationController] canPerformNavigationOperation:_navigationOperation]) {
        [[aContext navigationController] startNavigationOperation:_navigationOperation];
    } else {
        [self stopCurrentNavigationOperation];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSNavigationOperationStageDidChangeNotification" object:_navigationOperation];
        [_navigationOperation release];
        _navigationOperation = nil;
    }
}

- (void)willConcludeNavigationOperation:(id)aOperation
{
}

- (void)willStartNavigationOperation:(id)aOperation
{
}

- (id)createNavigationOperation
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)alert
{
    if (_alert == nil) {
        _alert = [HSAlert new];
        [_alert setMessageText:[self cantChangeCardAlertTitle]];
        [_alert setInformativeText:[self cantChangeCardAlertMessage]];
    }
    return _alert;
}

- (id)cantChangeCardAlertMessage
{
    return [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"This card has been deleted." value:@"" table:@"Alerts"];
}

- (id)cantChangeCardAlertTitle
{
    return [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cannot go to specified card" value:@"" table:@"Alerts"];
}

- (id)attributeNotificationCenterForTransition:(id)aTransition
{
    return [self attributeNotificationCenter];
}

- (id)undoManagerForTransition:(id)aTransition
{
    return [self undoManager];
}

- (BOOL)canGoToHyperDestinationCard
{
    return YES;
}

- (void)setTransition:(id)aTransition
{
    if (_transition == aTransition)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Transition" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setTransition:_transition];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSTransitionAttribute) ofObject:self withUserInfo:nil];
    if ([_transition delegate] == self)
        [_transition setDelegate:nil];
    [_transition release];
    _transition = [aTransition retain];
    [_transition setDelegate:self];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSTransitionAttribute) ofObject:self withUserInfo:nil];
}

- (id)transition
{
    if (_transition == nil) {
        _transition = [[HSTransition alloc] init];
        [_transition setDelegate:self];
    }
    return _transition;
}

- (id)queryHyperInterface:(id)aInterface
{
    if (protocol_conformsToProtocol(aInterface, @protocol(HSTransitionAttributes)))
        return [self transition];
    return [super queryHyperInterface:aInterface];
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObject:@"transition"];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([_transition delegate] == self)
        [_transition setDelegate:nil];
    [_transition release];
    [_context release];
    [_navigationOperation release];
    [_alert release];
    [super dealloc];
}

@end
