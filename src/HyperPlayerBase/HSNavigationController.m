#import "HSNavigationController.h"
#import "HSActionEvent.h"
#import "HSAlert.h"
#import "HSApplicationController.h"
#import "HSCardView.h"
#import "HSChangeCardAction.h"
#import "HSDocument.h"
#import "HSErrorManager.h"
#import "HSExecutableResourceProvider.h"
#import "HSHistoryItem.h"
#import "HSHomeStackController.h"
#import "HSNavigationOperation.h"
#import "HSWindowMovingAnimation.h"
#import "NSString+NSStringLinkRecognitionHSExtensions.h"

// Navigation operation stages driven by -continueNavigationOperation:.
enum {
    HSNavigationStageStart = 0,
    HSNavigationStageCheckUnsavedChanges = 2,
    HSNavigationStageAskToSave = 3,
    HSNavigationStageAskingToSave = 4,
    HSNavigationStageRunSavePanel = 5,
    HSNavigationStageSaving = 6,
    HSNavigationStageCheckDestinationOpened = 7,
    HSNavigationStageNotifyDestinationOpened = 8,
    HSNavigationStageNotifyingDestinationOpened = 9,
    HSNavigationStageMoveToOpenedStack = 10,
    HSNavigationStageMoveToStack = 11,
    HSNavigationStageFinished = 13,
    HSNavigationStageCancelled = 14
};

static NSString *HSNavigationLocalizedAlertString(NSString *key)
{
    return [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:key value:@"" table:@"Alerts"];
}

@implementation HSNavigationController

/* i386 ivar offsets: _document=0x4, _delegate=0x8, _currentNavigationOperation=0xc, _performingHistoryOperation=0x10, _spinControlWindow=0x14, _spinControl=0x18, _wasOpenGLSurfaceEnabled=0x1c */

// Opens the home stack, falling back to the default one (after telling the
// user) when the configured one is missing or unreadable.
// Navigates the current document there when it may go home, otherwise opens
// the home stack as a document of its own.
+ (BOOL)goToHomeStack
{
    return [self goToHomeStackInNewDocument:NO];
}

+ (BOOL)goToHomeStackAtURL:(id)aURL
{
    return [self goToHomeStackAtURL:aURL createNewDocument:NO];
}

+ (BOOL)goToHomeStackInNewDocument:(BOOL)aNewDocument
{
    return [self goToHomeStack:NO withPageIndex:NSIntegerMax inNewDocument:aNewDocument];
}

+ (BOOL)goToTutorialsPage
{
    BOOL notOpen = [[HSApplicationController sharedDocumentController] documentForURL:[[HSHomeStackController sharedHomeStackController] defaultHomeStackURL]] == nil;
    return [self goToHomeStack:YES withPageIndex:2 inNewDocument:notOpen];
}

+ (BOOL)goToHomeStackAtURL:(id)aURL createNewDocument:(BOOL)aNewDocument
{
    return [[self class] goToHomeStackAtURL:aURL withPageIndex:NSIntegerMax createNewDocument:aNewDocument];
}

+ (BOOL)goToHomeStackAtURL:(id)aURL withPageIndex:(NSUInteger)aPageIndex createNewDocument:(BOOL)aNewDocument
{
    id document = [[HSApplicationController sharedDocumentController] currentDocument];
    if (document != nil && !aNewDocument && [[document navigationControllerClass] documentCanGoHome:document]) {
        HSNavigationController *navigation = [document navigationController];
        if (aPageIndex == NSIntegerMax)
            aPageIndex = [[HSHomeStackController sharedHomeStackController] defaultCardIndex];
        if (![navigation canGoToCardAtIndex:aPageIndex inStackAtURL:aURL])
            return NO;
        [navigation goToCardAtIndex:aPageIndex inStackAtURL:aURL withTransition:nil];
        return YES;
    }
    __block BOOL result = YES;
    [[HSApplicationController sharedDocumentController] openDocumentWithContentsOfURL:aURL display:YES completionHandler:^(NSDocument *aDocument, BOOL aAlreadyOpen, NSError *aError) {
        if (aError == nil) {
            if (aPageIndex != NSIntegerMax) {
                id stack = [(id)aDocument stack];
                NSUInteger index = aPageIndex < [stack hyperCount] ? aPageIndex : 0;
                [(id)aDocument setCurrentCard:[stack hyperChildAtIndex:index]];
            }
        } else {
            [[HSErrorManager sharedErrorManager] presentError:aError];
            result = NO;
        }
    }];
    return result;
}

+ (BOOL)goToHomeStack:(BOOL)aDefault withPageIndex:(NSUInteger)aPageIndex inNewDocument:(BOOL)aNewDocument
{
    HSHomeStackController *controller = [HSHomeStackController sharedHomeStackController];
    NSURL *homeURL = aDefault ? [controller defaultHomeStackURL] : [controller homeStackURL];
    NSString *path = [homeURL path];
    if ([path length] == 0) {
        HSAlert *alert = [HSAlert new];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"CannotGoToHomeStackAlertTitle" value:@"" table:@"Alerts"]];
        [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"CannotGoToHomeStackAlertMessage" value:@"" table:@"Alerts"]];
        [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"CannotGoToHomeStackAlertDefaultButton" value:@"" table:@"Alerts"]];
        [alert runModal];
        [alert release];
        return NO;
    }
    NSString *found = [self findFile:path base:[path stringByDeletingLastPathComponent]];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:found] || ![manager isReadableFileAtPath:found]) {
        HSAlert *alert = [HSAlert new];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"CannotOpenHomeStackAlertTitle" value:@"" table:@"Alerts"]];
        [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"CannotOpenHomeStackAlertMessage" value:@"" table:@"Alerts"]];
        [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"CannotOpenHomeStackAlertDefaultButton" value:@"" table:@"Alerts"]];
        [alert runModal];
        [alert release];
        NSURL *defaultURL = [controller defaultHomeStackURL];
        NSString *defaultPath = [defaultURL path];
        if (defaultURL == nil || defaultPath == nil || ![manager fileExistsAtPath:defaultPath] || ![manager isReadableFileAtPath:defaultPath])
            return NO;
        BOOL result = [[self class] goToHomeStackAtURL:defaultURL createNewDocument:aNewDocument];
        [controller setHomeStackURL:defaultURL];
        return result;
    }
    return [[self class] goToHomeStackAtURL:[NSURL fileURLWithPath:found] withPageIndex:aPageIndex createNewDocument:aNewDocument];
}

// The open tutorial document with the given URL, if any.
- (id)HSNavigationController_openedTutorialDocumentWithURL:(id)aURL
{
    if (![[HSPathsProvider sharedPathsProvider] isTutorialURL:aURL])
        return nil;
    __block id found = nil;
    [[NSApp windows] enumerateObjectsUsingBlock:^(id aWindow, NSUInteger aIndex, BOOL *aStop) {
        id document = [[aWindow windowController] document];
        if ([[document fileURL] isEqualTo:aURL]) {
            found = document;
            *aStop = YES;
        }
    }];
    return found;
}

+ (BOOL)documentCanGoHome:(id)aHome
{
    return YES;
}

// Locates a stack that may have moved: an old ".stk" name is tried as
// ".stack" first, then the path is searched relative to the base, and finally
// the file name is looked for in the usual user folders and next to a
// ".files" folder the base may be in.
+ (id)findFile:(id)aFile base:(id)aBase
{
    NSString *found = nil;
    if ([[aFile pathExtension] isEqualToString:@"stk"])
        found = [self findFile:[[aFile stringByDeletingPathExtension] stringByAppendingPathExtension:@"stack"] base:aBase];
    if ([found length] != 0)
        return found;
    if ([aFile pathComponentsCount] <= ([aFile isAbsolutePath] ? 1 : 0))
        return found;
    found = [self privateFindFile:aFile base:aBase];
    if ([found length] != 0)
        return found;
    NSString *file = [aBase stringByAppendingPathComponent:[aFile lastPathComponent]];
    NSMutableArray *folders = [NSMutableArray arrayWithObjects:@"~/Desktop/", @"~/Downloads/", @"~/Documents/", @"~/Music/", @"~/Movies/", nil];
    if ([[aBase lastPathComponent] hasSuffix:@"files"]) {
        NSString *name = [[aFile lastPathComponent] stringByDeletingPathExtension];
        NSString *folder = [[[aBase stringByDeletingLastPathComponent] stringByDeletingLastPathComponent] stringByAppendingPathComponent:name];
        [folders addObject:[folder stringByAppendingPathComponent:[name stringByAppendingPathExtension:@"files"]]];
    }
    NSEnumerator *enumerator = [folders objectEnumerator];
    NSString *folder;
    while ((folder = [enumerator nextObject]) != nil) {
        found = [self privateFindFile:file base:[folder stringByExpandingTildeInPath]];
        if ([found length] != 0)
            break;
    }
    return found;
}

// File URLs are searched on disk; anything else is probed over the network.
// The action URL itself is returned when nothing better is found.
+ (id)findURLUsingActionURL:(id)aURL baseURL:(id)aURL2
{
    if (![aURL2 isFileURL])
        return [self privateFindUsingAcitonURL:aURL baseURL:aURL2];
    NSString *found = [self findFile:[aURL path] base:[aURL2 path]];
    if (found == nil)
        return aURL;
    return [NSURL fileURLWithPath:found];
}

// Tries the file name next to the base, one and two levels up, and inside the
// "<name>/<name>.files" folder two levels up; the first that answers with a
// matching file name and some content wins.
+ (id)privateFindUsingAcitonURL:(id)aURL baseURL:(id)aURL2
{
    NSString *name = [aURL lastPathComponent];
    NSURL *sibling = [NSURL URLWithString:name relativeToURL:aURL2];
    NSURL *parent = [aURL2 URLByDeletingLastPathComponent];
    NSURL *inParent = [NSURL URLWithString:name relativeToURL:parent];
    NSURL *grandparent = [parent URLByDeletingLastPathComponent];
    NSURL *inGrandparent = [NSURL URLWithString:name relativeToURL:grandparent];
    NSString *baseName = [name stringByDeletingPathExtension];
    NSURL *inFilesFolder = [[[[grandparent URLByAppendingPathComponent:baseName] URLByAppendingPathComponent:baseName]
                             URLByAppendingPathExtension:@"files"] URLByAppendingPathComponent:name];
    NSArray *candidates = [NSArray arrayWithObjects:inFilesFolder, sibling, inParent, inGrandparent, nil];
    for (NSURL *candidate in candidates) {
        NSURLRequest *request = [NSURLRequest requestWithURL:candidate cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30.0];
        if (![NSURLConnection canHandleRequest:request])
            continue;
        NSURLResponse *response = nil;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
        if ([[candidate lastPathComponent] isEqualToString:[response suggestedFilename]] && [response expectedContentLength] > 0)
            return candidate;
    }
    return aURL;
}

// Walks up from the base looking for the file's trailing path components, or
// its leading components with the file name appended. A path sharing a
// leading part with the base is first made relative to it.
+ (id)privateFindFile:(id)aFile base:(id)aBase
{
    NSString *directory = aBase != nil ? aBase : @"/";
    NSString *relative = aFile;
    if ([aFile isAbsolutePath] && [aBase isAbsolutePath]) {
        NSArray *fileComponents = [aFile pathComponents];
        NSArray *baseComponents = [aBase pathComponents];
        NSUInteger count = MIN([fileComponents count], [baseComponents count]);
        NSUInteger common = 0;
        while (common < count && [[fileComponents objectAtIndex:common] isEqualToString:[baseComponents objectAtIndex:common]])
            common++;
        if (common != 0)
            relative = [aFile pathWithLastComponents:[aFile pathComponentsCount] - common];
    }
    NSString *name = [aFile isEqualToString:@"/"] ? nil : [aFile lastPathComponent];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (name == nil || [fileManager fileExistsAtPath:aFile])
        return aFile;
    while ([directory pathComponentsCount] > 0) {
        for (NSInteger i = 1; i < [relative pathComponentsCount]; i++) {
            NSString *candidate = [directory stringByAppendingPathComponent:[relative pathWithLastComponents:i]];
            if ([fileManager fileExistsAtPath:candidate])
                return candidate;
            candidate = [directory stringByAppendingPathComponent:[[relative pathWithFirstComponents:i] stringByAppendingPathComponent:name]];
            if ([fileManager fileExistsAtPath:candidate])
                return candidate;
        }
        directory = [directory isEqualToString:@"/"] ? nil : [directory stringByDeletingLastPathComponent];
    }
    return nil;
}

- (void)interruptAllNavigationOperations
{
    if ([self currentNavigationOperation] != nil)
        [self cancelNavigationOperation:[self currentNavigationOperation]];
}

- (void)willBeClosedWithDocument
{
    [self updateLastMarkedCardDocumentPath];
    [self pushCurrentCardInHistoryIfNeededWithTransition:nil isGoingToAnotherStack:YES];
    if (_currentNavigationOperation == nil)
        [[self presentationSync] endPresentation];
}

- (double)transitionDurationForCurrentNavigationOperation
{
    return [(id<HSTransitionDurationAttribute>)[_currentNavigationOperation transition] duration];
}

- (id)presentationSync
{
    return nil;
}

- (void)recycleCurrentNavigationOperation:(BOOL)aOperation
{
    [self hideSpinIndicator];
    [self concludeHistoryOperationIfNeeded:aOperation];
    id presentationSync = [self presentationSync];
    [[[presentationSync dataSource] actionExecutionContextForPresentationSync:[self presentationSync]] setTransitionPlaying:NO];
    NSDictionary *userInfo = nil;
    if (_currentNavigationOperation != nil)
        userInfo = [NSDictionary dictionaryWithObject:_currentNavigationOperation forKey:@"HSNavigationOperationKey"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSNavigationControllerDidFinishNavigationOperationNotification" object:self userInfo:userInfo];
    [_currentNavigationOperation release];
    _currentNavigationOperation = nil;
}

- (void)cancelNavigationOperation:(id)aOperation
{
    [aOperation setStage:HSNavigationStageCancelled];
    [self continueNavigationOperation:aOperation];
}

- (void)finishNavigationOperation:(id)aOperation
{
    if (_wasOpenGLSurfaceEnabled) {
        id cardView = [_document cardView];
        [cardView enableOpenGLSurface];
        [cardView setNeedsDisplay:YES];
        _wasOpenGLSurfaceEnabled = 0;
    }
    [aOperation willChangeStage];
    [aOperation setStage:HSNavigationStageFinished postNotification:NO];
    [self continueNavigationOperation:aOperation];
    [aOperation didChangeStage];
}

- (void)concludeHistoryOperationIfNeeded:(BOOL)aNeeded
{
    if (_performingHistoryOperation) {
        [[self historyStack] concludeHistoryOperation:aNeeded];
        _performingHistoryOperation = NO;
    }
}

// Advances the operation through its stages: unsaved changes (asking, saving),
// an already opened destination (notifying, moving there), then the move to the
// destination stack and card.
- (void)continueNavigationOperation:(id)aOperation
{
    switch ([aOperation stage]) {
    case HSNavigationStageStart:
        [aOperation setStage:HSNavigationStageCheckUnsavedChanges];
        [self continueNavigationOperation:aOperation];
        break;
    case HSNavigationStageCheckUnsavedChanges:
        [aOperation setStage:[self shouldAskUserToSaveChangesForNavigationOperation:aOperation] ? HSNavigationStageAskToSave : HSNavigationStageCheckDestinationOpened];
        [self continueNavigationOperation:aOperation];
        break;
    case HSNavigationStageAskToSave:
        [self askUserToSaveChangesForNavigationOperation:aOperation];
        break;
    case HSNavigationStageRunSavePanel:
        [[self document] runModalSavePanelForSaveOperation:NSSaveAsOperation delegate:self
                                           didSaveSelector:@selector(document:didSave:contextInfo:) contextInfo:aOperation];
        [aOperation setStage:HSNavigationStageSaving];
        break;
    case HSNavigationStageCheckDestinationOpened:
        [aOperation setStage:[self isDestinationStackOpened:aOperation] ? HSNavigationStageNotifyDestinationOpened : HSNavigationStageMoveToStack];
        [self continueNavigationOperation:aOperation];
        break;
    case HSNavigationStageNotifyDestinationOpened:
        [self notifyUserAboutOpenedStackForNavigationOperation:aOperation];
        break;
    case HSNavigationStageMoveToOpenedStack:
        [self prepareForNavigationToOpenedStack:aOperation];
        break;
    case HSNavigationStageMoveToStack: {
        [self disableOpenGLSurfaceIfNeeded];
        [self hideSpinIndicator];
        [self saveHistoryForNavigationOperationIfNeeded:aOperation];
        if (![self moveToStackWithNavigationOperation:aOperation]) {
            [self cancelNavigationOperation:aOperation];
            break;
        }
        id card = [self destinationCardInStack:[[self document] stack] fromNavigationOperation:aOperation];
        if ([aOperation destinationCardUID] != nil && card == nil)
            [[self historyStack] removeCardWithUID:[aOperation destinationCardUID] inStack:[[self document] stack]];
        if (card == nil) {
            [self cancelNavigationOperation:aOperation];
            break;
        }
        [aOperation setDestinationCard:card];
        [[self document] setCurrentCard:card];
        [aOperation setStage:HSNavigationStageFinished];
        [self continueNavigationOperation:aOperation];
        break;
    }
    case HSNavigationStageFinished:
        [self recycleCurrentNavigationOperation:YES];
        break;
    case HSNavigationStageCancelled:
        [self recycleCurrentNavigationOperation:NO];
        break;
    default:
        break;
    }
}

// The OpenGL surface is detached while another stack is loaded.
- (void)disableOpenGLSurfaceIfNeeded
{
    HSCardView *cardView = [_document cardView];
    BOOL enabled = [cardView isOpenGLSurfaceEnabled];
    _wasOpenGLSurfaceEnabled = enabled ? 1 : 0;
    if (enabled) {
        [cardView disableOpenGLSurfaceDetachingImmediately:NO];
        [cardView display];
    }
}

- (void)startNavigationOperation:(id)aOperation
{
    if (_currentNavigationOperation == nil) {
        [self setNavigationOperation:aOperation];
        [self continueNavigationOperation:aOperation];
    }
}

- (void)setNavigationOperation:(id)aOperation
{
    if (_currentNavigationOperation != aOperation) {
        [_currentNavigationOperation release];
        _currentNavigationOperation = [aOperation retain];
    }
}

- (id)currentNavigationOperation
{
    return _currentNavigationOperation;
}

// Whether the destination exists and differs from where the document is now;
// the delegate gets the last word.
- (BOOL)canPerformNavigationOperation:(id)aOperation
{
    BOOL result;
    if ([aOperation destinationStackURL] != nil) {
        if ([[[self document] fileURL] isEqual:[aOperation destinationStackURL]]) {
            id card = [[self document] currentCard];
            if ([aOperation destinationCardUID] != nil && ![[aOperation destinationCardUID] isEqual:[card hyperUID]])
                result = YES;
            else if ([aOperation destinationCardIndex] != [card hyperIndex])
                result = YES;
            else
                result = [aOperation destinationCardIdOldFileFormat] != [card cardIdOldFileFormat];
        } else {
            BOOL isDirectory = NO;
            result = [[NSFileManager defaultManager] fileExistsAtPath:[[aOperation destinationStackURL] path] isDirectory:&isDirectory] && !isDirectory;
        }
    } else if ([aOperation destinationStack] != nil) {
        result = [[aOperation destinationStack] childWithUID:[aOperation destinationCardUID]] != nil;
    } else if ([aOperation shouldOpenUntitledDocument]) {
        result = YES;
    } else if ([aOperation destinationStackURL] != nil) {
        result = NO;
    } else if ([self canGoToCardAtIndex:[aOperation destinationCardIndex] allowGoToCurrent:YES]) {
        result = YES;
    } else if ([aOperation destinationCardUID] != nil && [[[self document] stack] childWithUID:[aOperation destinationCardUID]] != nil) {
        result = YES;
    } else {
        NSInteger oldIdentifier = [aOperation destinationCardIdOldFileFormat];
        result = oldIdentifier != 0 && oldIdentifier != 0x7fffffff;
    }
    if ([_delegate respondsToSelector:@selector(canInNavigationController:performNavigationOperation:)])
        result = result && [_delegate canInNavigationController:self performNavigationOperation:aOperation];
    return result;
}

// Runs the card's own click "change card" action when it has one.
- (void)advanceToNextCard:(id)aCard
{
    if ([self currentNavigationOperation] != nil)
        return;
    id card = [[_document cardViewForNavigation] card];
    [card hyperIndex];
    [self cardCount];
    id actor = [card queryHyperInterface:@protocol(HSActor)];
    if ([actor hyperActionOfType:[HSChangeCardAction actionType] forEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType]] != nil) {
        id manager = [_document actionExecutionManager];
        id context = [_document actionExecutionContext];
        [manager runActionsForObject:card withEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType] inContext:context forRequestor:self];
    } else {
        [self goToNextCard:aCard];
    }
}

- (void)goToUntitledDocument:(id)aDocument
{
    HSNavigationOperation *operation = [[HSNavigationOperation new] autorelease];
    [operation setShouldOpenUntitledDocument:YES];
    if ([self canPerformNavigationOperation:operation]) {
        [self processUserInitiatedNavigationOperation:operation];
        [self startNavigationOperation:operation];
    }
}

- (void)goToFirstCard:(id)aCard
{
    [self goToCardAtIndex:0 allowGoToCurrent:YES];
}

- (void)goToLastCard:(id)aCard
{
    [self goToCardAtIndex:[self cardCount] - 1 allowGoToCurrent:YES];
}

- (void)goToPreviousCard:(id)aCard
{
    if ([self currentNavigationOperation] == nil)
        [self goToCardAtIndex:[self cardIndex] - 1];
}

- (void)goToNextCard:(id)aCard
{
    [self goToCardAtIndex:[self cardIndex] + 1];
}

- (void)goToHome:(id)aHome
{
    if ([_delegate respondsToSelector:@selector(canGoToHomeInNavigationController:)] && ![_delegate canGoToHomeInNavigationController:self])
        return;
    [[self class] goToHomeStack];
}

// History moves carry the source card and its view transforms for the
// transition.
- (void)goForward:(id)aForward
{
    if (![self canGoForward])
        return;
    _performingHistoryOperation = YES;
    [[self historyStack] startForwardOperation];
    HSNavigationOperation *operation = [[self historyStack] createForwardNavigationOperationWithTransition:[aForward queryHyperInterface:@protocol(HSTransitionAttributes)]];
    [operation setSourceCard:[[self document] currentCard]];
    id cardView = [[self document] cardView];
    [operation setSourceCardUserSpaceToViewSpaceTransform:[cardView userSpaceToViewSpaceCGAffineTransform]];
    [operation setSourceCardViewTransform:[cardView NSE_affineTransformToView:nil]];
    [self processUserInitiatedNavigationOperation:operation];
    [self startNavigationOperation:operation];
    [operation release];
}

- (void)goBack:(id)aBack
{
    if (![self canGoBack])
        return;
    _performingHistoryOperation = YES;
    [[self historyStack] startBackOperation];
    HSNavigationOperation *operation = [[self historyStack] createBackNavigationOperationWithTransition:[aBack queryHyperInterface:@protocol(HSTransitionAttributes)]];
    [operation setSourceCard:[[self document] currentCard]];
    id cardView = [[self document] cardView];
    [operation setSourceCardUserSpaceToViewSpaceTransform:[cardView userSpaceToViewSpaceCGAffineTransform]];
    [operation setSourceCardViewTransform:[cardView NSE_affineTransformToView:nil]];
    [self processUserInitiatedNavigationOperation:operation];
    [self startNavigationOperation:operation];
    [operation release];
}

- (BOOL)validateUserInterfaceItem:(id)aItem
{
    SEL action = [(id<NSValidatedUserInterfaceItem>)aItem action];
    if ([self currentNavigationOperation] != nil)
        return NO;
    if (action == @selector(goBack:) || action == @selector(goBackWithoutLeaveActions:))
        return [self canGoBack];
    if (action == @selector(goForward:) || action == @selector(goForwardWithoutLeaveActions:))
        return [self canGoForward];
    if (action == @selector(goToNextCard:) || action == @selector(goToPreviousCard:) ||
        action == @selector(goToNextCardWithoutLeaveActions:) || action == @selector(goToPreviousCardWithoutLeaveActions:)) {
        NSInteger index = [self cardIndex];
        if (action == @selector(goToNextCard:) || action == @selector(goToNextCardWithoutLeaveActions:))
            index++;
        else
            index--;
        return [self canGoToCardAtIndex:index];
    }
    if (action == @selector(goToLastCard:) || action == @selector(goToFirstCard:) || action == @selector(goToSpecificCard:) ||
        action == @selector(goToLastCardWithoutLeaveActions:) || action == @selector(goToFirstCardWithoutLeaveActions:) ||
        action == @selector(goToSpecificCardWithoutLeaveActions:))
        return [self cardCount] != 0;
    return NO;
}

- (BOOL)canGoToCardWithUID:(id)aUID
{
    return [[[self document] stack] childWithUID:aUID] != nil;
}

- (BOOL)canGoForward
{
    id operation = [[self historyStack] createForwardNavigationOperationWithTransition:nil];
    if (operation == nil)
        return NO;
    BOOL result = [self canPerformNavigationOperation:operation];
    [operation release];
    return result;
}

- (BOOL)canGoBack
{
    id operation = [[self historyStack] createBackNavigationOperationWithTransition:nil];
    if (operation == nil)
        return NO;
    BOOL result = [self canPerformNavigationOperation:operation];
    [operation release];
    return result;
}

- (BOOL)canGoToPreviousCard
{
    return [self canGoToCardAtIndex:[self cardIndex] - 1];
}

- (BOOL)canGoToNextCard
{
    return [self canGoToCardAtIndex:[self cardIndex] + 1];
}

- (id)historyStack
{
    return [[self document] historyStack];
}

- (void)goToCardWithUID:(id)aUID inStackAtURL:(id)aURL withTransition:(id)aTransition
{
    NSURL *url = nil;
    if (aURL != nil)
        url = [NSURL fileURLWithPath:[[self class] findFile:[aURL path] base:[[[[self document] fileURL] path] stringByDeletingLastPathComponent]]];
    HSNavigationOperation *operation = [[[HSNavigationOperation alloc] initWithDestinationStackURL:url destinationCardUID:aUID transition:aTransition] autorelease];
    [operation setSourceCard:[_document currentCard]];
    if ([self canPerformNavigationOperation:operation]) {
        [self processUserInitiatedNavigationOperation:operation];
        [self startNavigationOperation:operation];
    }
}

- (void)goToCardWithUID:(id)aUID
{
    if ([self HS_canGoToCardWithUID:aUID])
        [self goToCardWithUID:aUID inStackAtURL:nil withTransition:nil];
}

- (void)goToCardAtIndex:(NSInteger)aIndex
{
    [self goToCardAtIndex:aIndex allowGoToCurrent:NO];
}

// Index -1 wraps to the last card and one past the end to the first.
- (void)goToCardAtIndex:(NSInteger)aIndex allowGoToCurrent:(BOOL)aCurrent
{
    if (![self canGoToCardAtIndex:aIndex allowGoToCurrent:aCurrent])
        return;
    NSInteger count = [self cardCount];
    if (aIndex == -1)
        aIndex = count - 1;
    else if (count == aIndex)
        aIndex = 0;
    [self goToCardAtIndex:aIndex inStackAtURL:nil withTransition:nil];
}

- (void)goToCardAtIndex:(NSInteger)aIndex inStackAtURL:(id)aURL withTransition:(id)aTransition
{
    NSURL *url = nil;
    if (aURL != nil)
        url = [NSURL fileURLWithPath:[[self class] findFile:[aURL path] base:[[[[self document] fileURL] path] stringByDeletingLastPathComponent]]];
    HSNavigationOperation *operation = [[[HSNavigationOperation alloc] initWithDestinationStackURL:url destinationCardIndex:aIndex transition:aTransition] autorelease];
    [operation setSourceCard:[_document currentCard]];
    [self processUserInitiatedNavigationOperation:operation];
    [self startNavigationOperation:operation];
}

- (void)goToCard:(id)aCard withTransition:(id)aTransition
{
    NSInteger index = [[[self document] stack] indexOfHyperChild:[aCard queryHyperInterface:@protocol(HSNodeChild)]];
    [self goToCardAtIndex:index inStackAtURL:nil withTransition:aTransition];
}

// Outside presentation mode this window slides onto the already opened
// destination window first.
- (void)prepareForNavigationToOpenedStack:(id)aStack
{
    NSURL *URL = [aStack destinationStackURL];
    id destination = [[HSPathsProvider sharedPathsProvider] isTutorialURL:URL] ? [self HSNavigationController_openedTutorialDocumentWithURL:URL] : [[HSApplicationController sharedDocumentController] documentForURL:URL];
    id stack = [destination stack];
    id card = nil;
    NSInteger index = [aStack destinationCardIndex];
    if ((NSUInteger)index == (NSUInteger)NSNotFound) {
        if ([aStack destinationCardUID] != nil)
            card = [stack childWithUID:[aStack destinationCardUID]];
    } else if (index != (NSInteger)[stack indexOfHyperChild:[destination currentCard]]) {
        card = [stack hyperChildAtIndex:index];
    }
    if ([[self historyStack] isBackGoing])
        [[destination historyStack] startBackOperation];
    [[destination historyStack] pushCard:[[self document] currentCard] withTransition:[aStack transition]];
    if ([[self historyStack] lastMarkedCard] != nil && ![[[self document] currentCard] isMarkedCard])
        [[destination historyStack] setLastMarkedCard:[[self historyStack] lastMarkedCard]];
    [aStack setTransition:nil];
    if ([[destination historyStack] isBackGoing])
        [[destination historyStack] concludeHistoryOperation:NO];
    if (card != nil)
        [destination setCurrentCard:card];
    [destination showWindows];
    [self continueNavigationToDestinationStack];
}

- (void)continueNavigationToDestinationStack
{
    [[self presentationSync] navigationOperationCompleted];
    [_currentNavigationOperation setStage:HSNavigationStageMoveToStack];
    [self continueNavigationOperation:_currentNavigationOperation];
}

// The destination is already open in another window: continue (moving into
// it), save it first when it has changes, or cancel.
- (BOOL)isDestinationStackOpened:(id)aOpened
{
    NSURL *url = [aOpened destinationStackURL];
    if ([[[self document] fileURL] isEqual:url])
        return NO;
    if ([[NSDocumentController sharedDocumentController] documentForURL:url] != nil)
        return YES;
    return [self HSNavigationController_openedTutorialDocumentWithURL:url] != nil;
}

- (void)document:(id)aDocument didSave:(BOOL)aSave contextInfo:(void *)aInfo
{
    if (aSave) {
        [(id)aInfo setStage:HSNavigationStageCheckDestinationOpened];
        [self continueNavigationOperation:(id)aInfo];
    } else {
        [self cancelNavigationOperation:(id)aInfo];
    }
}

// Save goes through the document's own save (or the save panel for an
// untitled or imported one); Don't Save moves on; Cancel cancels.
- (void)alertAskUserToSaveChangesDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    id operation = (id)aInfo;
    [[aEnd window] orderOut:self];
    if (aCode == 0) {
        [self cancelNavigationOperation:operation];
    } else if (aCode == NSAlertThirdButtonReturn) {
        [operation setStage:HSNavigationStageCheckDestinationOpened];
        [self continueNavigationOperation:operation];
    } else if (aCode == 1) {
        [self saveChangesForNavigationOperation:operation];
    }
    [aEnd release];
}

- (void)askUserToSaveChangesForNavigationOperation:(id)aOperation
{
    NSAlert *alert = [NSAlert new];
    [alert setMessageText:HSNavigationLocalizedAlertString(@"NavigationSaveDocumentAlertText")];
    [alert setInformativeText:HSNavigationLocalizedAlertString(@"NavigationSaveDocumentAlertInformativeText")];
    [[alert addButtonWithTitle:HSNavigationLocalizedAlertString(@"NavigationSaveDocumentSaveButtonTitle")] setTag:1];
    [[alert addButtonWithTitle:HSNavigationLocalizedAlertString(@"Cancel")] setTag:0];
    [alert addButtonWithTitle:HSNavigationLocalizedAlertString(@"NavigationSaveDocumentDontSaveTitle")];
    [alert beginSheetModalForWindow:[[self document] windowForSheet] modalDelegate:self
                     didEndSelector:@selector(alertAskUserToSaveChangesDidEnd:returnCode:contextInfo:) contextInfo:aOperation];
    [aOperation setStage:HSNavigationStageAskingToSave];
}

// Only when leaving (or reopening) an edited stack outside the web player.
- (BOOL)shouldAskUserToSaveChangesForNavigationOperation:(id)aOperation
{
    BOOL leaving = NO;
    if ([aOperation destinationStackURL] != nil) {
        if (![[[self document] fileURL] isEqual:[aOperation destinationStackURL]])
            leaving = YES;
        else if ([[[self document] fileURL] isEqual:[aOperation destinationStackURL]] && [aOperation shouldReopenDocumentIfSoureIsDestination])
            leaving = YES;
    }
    BOOL edited = [[self document] isDocumentEdited] && ![[self document] isWebPlayerDocument];
    return leaving && edited;
}

// Opens the destination stack: in the web player the document re-reads itself
// from the new file, elsewhere a new document is opened in this window and
// takes over this controller. Failures are reported to the user.
- (BOOL)moveToStackWithNavigationOperation:(id)aOperation
{
    NSURL *url = [aOperation destinationStackURL];
    if (!([[[self document] fileURL] isEqual:url] && [aOperation shouldReopenDocumentIfSoureIsDestination]) &&
        [[[self document] fileURL] isEqual:url])
        return YES;
    if (url == nil)
        return YES;
    HSCardView *cardView = [_document cardView];
    BOOL wasOpenGLSurfaceEnabled = [cardView isOpenGLSurfaceEnabled];
    if (wasOpenGLSurfaceEnabled) {
        [cardView disableOpenGLSurfaceDetachingImmediately:NO];
        [cardView display];
    }
    [self showSpinIndicator];
    BOOL separateWindow = [[HSPathsProvider sharedPathsProvider] isTutorialURL:url] || [aOperation shouldOpenInSeparateWindow];
    BOOL result = YES;
    NSError *error = nil;
    id card = [cardView card];
    CGAffineTransform userSpaceToViewSpace = [cardView userSpaceToViewSpaceCGAffineTransform];
    CGAffineTransform viewTransform = [cardView NSE_affineTransformToView:nil];
    BOOL succeeded;
    NSString *type = nil;
    id newDocument = nil;
    if (![_document isWebPlayerDocument]) {
        if (separateWindow)
            newDocument = [[HSApplicationController sharedDocumentController] openDocumentWithContentsOfURL:url display:YES error:&error];
        else
            newDocument = [[HSApplicationController sharedDocumentController] openDocumentWithContentsOfURL:url inWindowOfDocument:[self document] error:&error];
        succeeded = error == nil && newDocument != nil;
    } else {
        NSString *fileType = [[NSFileManager defaultManager] hyperFileTypeAtPath:[url path]];
        if ([@"stack" isEqualToString:fileType])
            type = @"HSDocumentType";
        else if ([@"'Stak'" isEqualToString:fileType])
            type = @"HSNativeDocumentType";
        succeeded = [_document readFromURL:url ofType:type error:&error];
        if (succeeded)
            [[_document actionExecutionContext] shutDownSpeechRecognition];
    }
    if (succeeded) {
        if (newDocument == nil) {
            [_document setFileURL:url];
            [_document setFileType:type];
        } else if (separateWindow) {
            id destinationCard = [self destinationCardInStack:[newDocument stack] fromNavigationOperation:aOperation];
            result = NO;
            if (destinationCard != nil)
                [newDocument setCurrentCard:destinationCard];
        } else {
            [aOperation setSourceDocument:_document];
            [aOperation setSourceCard:card];
            [aOperation setSourceCardUserSpaceToViewSpaceTransform:userSpaceToViewSpace];
            [aOperation setSourceCardViewTransform:viewTransform];
            [self retain];
            [_document setNavigationController:nil];
            [self setDocument:newDocument];
            [newDocument setNavigationController:self];
            [self release];
        }
    } else {
        id cancelled = [[error userInfo] objectForKey:HSUserCancelledImportKey];
        if (cancelled != nil) {
            if (![cancelled boolValue])
                [NSApp presentError:error];
        } else if ([error code] == 20022 && [[error domain] isEqualToString:HSSpecificErrorDomain]) {
            [NSApp presentError:error];
        } else {
            HSAlert *alert = [[HSAlert allocWithZone:[self zone]] init];
            id action = [[aOperation userInfo] objectForKey:@"HSNavigationOperationActionKey"];
            if (action != nil) {
                [alert setMessageText:[NSString stringWithFormat:HSNavigationLocalizedAlertString(@"HSGoToActionTargetStackDamagedMessageText"), [[action class] localizedName]]];
                [alert setInformativeText:[NSString stringWithFormat:HSNavigationLocalizedAlertString(@"HSGoToActionTargetStackDamagedInformativeText"),
                                           [[[url path] lastPathComponent] stringByDeletingPathExtension]]];
            } else {
                [alert setMessageText:[NSString stringWithFormat:HSNavigationLocalizedAlertString(@"OpenDamagedStackAlertMessage"), [[url path] lastPathComponent]]];
                [alert setInformativeText:HSNavigationLocalizedAlertString(@"OpenDamagedStackAlertInformativeText")];
            }
            [alert addButtonWithTitle:HSNavigationLocalizedAlertString(@"OK")];
            [alert setAlertStyle:5];
            [alert runModal];
            [alert release];
        }
    }
    if (wasOpenGLSurfaceEnabled) {
        [cardView enableOpenGLSurface];
        [cardView setNeedsDisplay:YES];
    }
    return succeeded && result;
}

- (void)hideSpinIndicator
{
}

- (void)showSpinIndicator
{
}

// A small translucent window with a spinner, centred on the document window.
- (id)spinControlWindow
{
    if (_spinControlWindow == nil) {
        NSRect frame = [[[[self document] currentWindowController] window] frame];
        NSRect rect = NSMakeRect(frame.size.width * 0.5f + frame.origin.x - 32.0f + 0.0f, frame.size.height * 0.5f + frame.origin.y - 32.0f + 0.0f, 64.0, 64.0);
        _spinControlWindow = [[NSWindow alloc] initWithContentRect:rect styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:YES];
        [_spinControlWindow setOpaque:NO];
        [_spinControlWindow setBackgroundColor:[NSColor clearColor]];
        [_spinControlWindow setReleasedWhenClosed:NO];
        NSImageView *imageView = [[NSImageView alloc] initWithFrame:[[_spinControlWindow contentView] bounds]];
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"loadingIndicatorBackground" ofType:@"tiff"];
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:path];
        [imageView setImage:image];
        [image release];
        NSRect bounds = [imageView bounds];
        _spinControl = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(bounds.size.width * 0.5f + bounds.origin.x - 16.0f + 0.0f,
                                                                             bounds.size.height * 0.5f + bounds.origin.y - 16.0f + 0.0f, 32.0, 32.0)];
        [_spinControl setControlSize:NSControlSizeRegular];
        [_spinControl setStyle:NSProgressIndicatorStyleSpinning];
        [_spinControlWindow setContentView:imageView];
        [[_spinControlWindow contentView] addSubview:_spinControl];
        [_spinControl release];
        [imageView release];
    }
    return _spinControlWindow;
}

- (void)saveHistoryForNavigationOperationIfNeeded:(id)aNeeded
{
    [aNeeded setSourceStackURL:[[self document] fileURL]];
    BOOL goingToAnotherStack = [aNeeded destinationStackURL] != nil && ![[aNeeded destinationStackURL] isEqual:[aNeeded sourceStackURL]];
    [self pushCurrentCardInHistoryIfNeededWithTransition:[aNeeded transition] isGoingToAnotherStack:goingToAnotherStack];
}

// Only saved stacks (native or web) keep history; a card no longer in its
// stack is dropped from it instead. Leaving the stack drops its links, or the
// whole stack for unsaved ones.
- (void)pushCurrentCardInHistoryIfNeededWithTransition:(id)aTransition isGoingToAnotherStack:(BOOL)aStack
{
    NSString *fileType = [[self document] fileType];
    if ([[self document] fileURL] == nil || !([fileType isEqualToString:@"HSDocumentType"] || [[[self document] fileType] isEqualToString:@"HSWebDocumentType"])) {
        if (aStack)
            [[self historyStack] removeStack:[[self document] stack]];
        return;
    }
    id card = [[self document] currentCard];
    if (card != nil) {
        if ([card stack] == nil)
            [[self historyStack] removeCardWithUID:[[card queryHyperInterface:@protocol(HSObjectUIDAttribute)] hyperUID] inStack:[[self document] stack]];
        else
            [[self historyStack] pushCard:card withTransition:aTransition];
    }
    if (aStack)
        [[self historyStack] removeAllLinksOnStack:[[self document] stack]];
}

- (void)showCannotFindCardAlert
{
    HSAlert *alert = [HSAlert new];
    [alert setMessageText:HSNavigationLocalizedAlertString(@"Cannot find card")];
    [alert setInformativeText:HSNavigationLocalizedAlertString(@"The card this button should lead to may have been deleted.")];
    [alert runModal];
    [alert release];
}

- (void)processUserInitiatedNavigationOperation:(id)aOperation
{
    [[self presentationSync] prepareForUserInitiatedNavigationOperation];
}

- (BOOL)canGoToCardWithUID:(id)aUID inStackAtURL:(id)aURL
{
    NSString *path = [[self class] findFile:[aURL path] base:[[[[self document] fileURL] path] stringByDeletingLastPathComponent]];
    return [[NSFileManager defaultManager] isReadableFileAtPath:path];
}

- (BOOL)HS_canGoToCardWithUID:(id)aUID
{
    id card = [[[self document] stack] childWithUID:aUID];
    return [self canGoToCardAtIndex:[[[self document] stack] indexOfHyperChild:card]];
}

- (BOOL)canGoToCardAtIndex:(NSInteger)aIndex inStackAtURL:(id)aURL
{
    NSString *path = [[self class] findFile:[aURL path] base:[[[[self document] fileURL] path] stringByDeletingLastPathComponent]];
    BOOL result = [[NSFileManager defaultManager] isReadableFileAtPath:path];
    if ([_delegate respondsToSelector:@selector(canGoInNavigationController:toCardAtIndex:inStackAtURL:)])
        result = result && [_delegate canGoInNavigationController:self toCardAtIndex:aIndex inStackAtURL:aURL];
    return result;
}

- (BOOL)canGoToCardAtIndex:(NSInteger)aIndex
{
    return [self canGoToCardAtIndex:aIndex allowGoToCurrent:NO];
}

// Index -1 and one past the end are accepted (they wrap).
- (BOOL)canGoToCardAtIndex:(NSInteger)aIndex allowGoToCurrent:(BOOL)aCurrent
{
    if ([_document currentCard] == nil)
        return YES;
    if ([self cardCount] == 0 || (NSInteger)[self cardCount] < aIndex || aIndex < -1)
        return NO;
    if (!aCurrent)
        return (NSInteger)[self cardIndex] != aIndex;
    return YES;
}

- (NSUInteger)cardIndex
{
    return [[[_document cardViewForNavigation] card] hyperIndex];
}

- (NSUInteger)cardCount
{
    return [[_document stack] hyperCount];
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

// The document owns its navigation controller, so it is not retained.
- (void)setDocument:(id)aDocument
{
    if (_document != aDocument)
        _document = aDocument;
}

- (id)document
{
    return _document;
}

- (void)dealloc
{
    [_currentNavigationOperation release];
    [_spinControlWindow close];
    [_spinControlWindow release];
    [super dealloc];
}

- (id)initWithDocument:(id)aDocument
{
    self = [super init];
    if (self != nil)
        [self setDocument:aDocument];
    return self;
}

- (BOOL)shouldGoHomeInNewDocument
{
    if ([[self document] fileURL] != nil)
        return NO;
    for (id document in [[NSDocumentController sharedDocumentController] documents]) {
        if ([document isDefaultHomeStack])
            return YES;
    }
    return NO;
}

- (void)updateLastMarkedCardDocumentPath
{
    id card = [[self historyStack] lastMarkedCard];
    if ([[self document] stack] == [card cardStack])
        [card setCardDocumentPath:[[[[self document] fileURL] path] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

- (void)saveChangesForNavigationOperation:(id)aOperation
{
    [[self document] canCloseDocumentWithDelegate:self shouldCloseSelector:@selector(document:didSave:contextInfo:) contextInfo:aOperation];
}

- (id)destinationCardInStack:(id)aStack fromNavigationOperation:(id)aOperation
{
    if ([aOperation destinationCardUID] != nil)
        return [aStack childWithUID:[aOperation destinationCardUID]];
    if ([aOperation destinationCardIndex] == 0x7fffffff)
        return nil;
    return [aStack hyperChildAtIndex:[aOperation destinationCardIndex]];
}

@end
