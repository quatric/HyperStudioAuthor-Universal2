#import "HSAHTML5ExportCompatibilityChecker.h"
#import "HSStack.h"
#import "HSNode.h"
#import "HSActionEvent.h"
#import "HSClearChangeFlagAction.h"
#import "HSAvailableActionsProvider.h"
#import "HSPathsProvider.h"
#import "HSErrorsAlert.h"
#import "HSExecutableResourceProvider.h"
#import "HSSubmitRequest.h"

@interface NSObject (HSAHTML5ExportCompatibilityCheckerSupport)
- (id)actionType;
- (BOOL)isKindOfType:(id)aType;
- (BOOL)hasUnsupportedHTML5FeaturesForDocumentType:(id)aType;
- (id)HTML5UnsupportedFeaturesForDocumentType:(id)aType;
- (id)HTML5UnsupportedFunctionalityDescription;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (id)queryHyperInterface:(Protocol *)aProtocol;
- (id)hyperActionOfType:(id)aType forEvent:(id)aEvent;
- (id)localizedName;
- (id)events;
- (id)eventType;
+ (id)errorWithHSCode:(int)aCode;
+ (id)errorWithDomain:(NSString *)aDomain code:(NSInteger)aCode userInfo:(NSDictionary *)aInfo;
@end

@implementation HSAHTML5ExportCompatibilityChecker

- (void)dealloc
{
    [_unsupportedDescriptions release];
    [_verifiableDocumentURL release];
    [_undecidedActions release];
    [super dealloc];
}

- (BOOL)canBeExportedActionObject:(id)aObject
{
    if ([_undecidedActions count] != 0 && [_undecidedActions containsObject:aObject]) {
        return YES;
    }
    if ([[HSAvailableActionsProvider unsupportediBooksActionTypes] containsObject:NSStringFromClass([aObject class])]) {
        return NO;
    }
    return [aObject canBeExportedToHTML5DocumentType:@"HSHTML5DocumentType"];
}

- (BOOL)shouldOmitChecking
{
    return (BOOL)(NSUInteger)[[HSPathsProvider sharedPathsProvider] isDefaultHomeStackURL:_verifiableDocumentURL];
}

- (id)unsupportedDescriptionForObject:(id)aObject
{
    if ([aObject isKindOfClass:[HSNode class]]) {
        return [aObject HTML5UnsupportedFunctionalityDescription];
    }
    if ([aObject isKindOfClass:[HSAction class]]) {
        id attributes = [aObject queryHyperInterface:@protocol(HSActionAttributes)];
        id name = [attributes localizedName];
        NSString *format = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSHTML5UnsupportedFeatureAction"
                                                                                          value:@""
                                                                                          table:@"Export"];
        return [NSString stringWithFormat:format, name];
    }
    return nil;
}

- (BOOL)shouldPostponeActionValidation:(id)aAction
{
    if (![aAction isKindOfType:[HSClearChangeFlagAction actionType]]) {
        return NO;
    }
    NSUInteger before = [_undecidedActions count];
    [[aAction events] enumerateObjectsUsingBlock:^(id event, NSUInteger idx, BOOL *stop) {
        if ([[event eventType] isEqualToString:kHSLeaveActionEventType]) {
            [[self undecidedActions] addObject:aAction];
            *stop = YES;
        }
    }];
    return before < [_undecidedActions count];
}

- (void)setVerifiableDocumentURL:(id)aURL
{
    if (![aURL isEqual:_verifiableDocumentURL]) {
        [_verifiableDocumentURL release];
        _verifiableDocumentURL = [aURL retain];
    }
}

- (BOOL)canBeExportObject:(id)aObject
{
    if ([self shouldOmitChecking]) {
        return YES;
    }
    BOOL canExport;
    if ([aObject isKindOfClass:[HSAction class]]) {
        canExport = [self canBeExportedActionObject:aObject];
    } else if ([aObject isKindOfClass:[HSNode class]]) {
        canExport = [aObject canBeExportedToHTML5DocumentType:@"HSHTML5DocumentType"];
    } else {
        return YES;
    }
    if (!canExport) {
        _existsUnsupportedObjects = 1;
    }
    return canExport;
}

- (id)unsupportedDescriptions
{
    if (_unsupportedDescriptions == nil) {
        _unsupportedDescriptions = [NSMutableSet new];
    }
    return _unsupportedDescriptions;
}

- (id)undecidedActions
{
    if (_undecidedActions == nil) {
        _undecidedActions = [NSMutableArray new];
    }
    return _undecidedActions;
}

- (void)addUnsupportedObjectIfNeeded:(id)aObject
{
    if ([self shouldOmitChecking]) {
        return;
    }
    if ([aObject isKindOfClass:[HSStack class]] && [_undecidedActions count] != 0) {
        [_undecidedActions enumerateObjectsUsingBlock:^(id action, NSUInteger idx, BOOL *stop) {
            if ([action isKindOfType:[HSClearChangeFlagAction actionType]]) {
                id actor = [aObject queryHyperInterface:@protocol(HSActor)];
                id type = [HSClearChangeFlagAction actionType];
                id event = [HSActionEvent actionEventOfType:kHSLeaveActionEventType];
                if ([actor hyperActionOfType:type forEvent:event] != action) {
                    [[self unsupportedDescriptions] addObject:[self unsupportedDescriptionForObject:action]];
                }
            }
        }];
    }

    BOOL unsupported = NO;
    if ([aObject isKindOfClass:[HSNode class]]) {
        if (![aObject canBeExportedToHTML5DocumentType:@"HSHTML5DocumentType"]) {
            unsupported = YES;
        }
    }
    if (!unsupported) {
        if ([aObject isKindOfClass:[HSAction class]] && ![self canBeExportedActionObject:aObject]) {
            if ([self shouldPostponeActionValidation:aObject]) {
                return;
            }
            unsupported = YES;
        } else {
            if (![aObject isKindOfClass:[HSNode class]] && ![aObject isKindOfClass:[HSAction class]]) {
                return;
            }
            if (![aObject hasUnsupportedHTML5FeaturesForDocumentType:@"HSHTML5DocumentType"]) {
                return;
            }
            [[self unsupportedDescriptions] addObjectsFromArray:
                [[aObject HTML5UnsupportedFeaturesForDocumentType:@"HSHTML5DocumentType"] allObjects]];
            return;
        }
    }
    [[self unsupportedDescriptions] addObject:[self unsupportedDescriptionForObject:aObject]];
}

- (NSInteger)runUserConfirmationAlert
{
    id error = [HSError errorWithHSCode:20000];
    HSErrorsAlert *alert = [HSErrorsAlert new];
    [alert setScriptErrors:[[self unsupportedDescriptions] allObjects]];
    [alert setMessageText:[error localizedDescription]];
    [alert setInformativeText:[error localizedRecoverySuggestion]];
    HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
    [alert addButtonWithTitle:[provider localizedStringForKey:@"Continue" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[provider localizedStringForKey:@"Cancel" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[provider localizedStringForKey:@"Submit Request" value:@"" table:@"Alerts"]];
    [alert setAlertStyle:NSCriticalAlertStyle];
    NSInteger result = [alert runModal];
    [alert release];
    return result;
}

- (void)submitRequestWithString:(id)aString
{
    [[HSSubmitRequest sharedInstance] submitInformation:aString];
}

- (BOOL)shouldImportDocumentWithError:(NSError **)aError
{
    if ([[self unsupportedDescriptions] count] == 0) {
        return YES;
    }
    NSInteger result = [self runUserConfirmationAlert];
    if (result == NSAlertThirdButtonReturn) {
        [self submitRequestWithString:[[_unsupportedDescriptions allObjects] componentsJoinedByString:@"\n"]];
    }
    [_unsupportedDescriptions removeAllObjects];
    _existsUnsupportedObjects = NO;
    BOOL proceed = result != NSAlertSecondButtonReturn;
    if (!proceed && aError != NULL) {
        NSDictionary *info = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                         forKey:HSUserCancelledImportKey];
        *aError = [HSError errorWithDomain:HSSpecificErrorDomain code:10001 userInfo:info];
    }
    return proceed;
}

- (BOOL)shouldImportDocument
{
    return [self shouldImportDocumentWithError:NULL];
}

- (BOOL)existsUnsupportedObjects
{
    return _existsUnsupportedObjects;
}

@end
