#import "HSGlobalSelectionSync.h"

NSString * const HSGlobalSelectionSyncDidChangeSelectedObjectNotification = @"HSGlobalSelectionSyncDidChangeSelectedObjectNotification";

static HSGlobalSelectionSync *HSGlobalSelectionSyncShared = nil;

@implementation HSGlobalSelectionSync

+ (id)globalSelectionSync
{
    if (HSGlobalSelectionSyncShared == nil)
        HSGlobalSelectionSyncShared = [[HSGlobalSelectionSync alloc] init];
    return HSGlobalSelectionSyncShared;
}

- (void)notifySelectionDidChange
{
    [[NSNotificationCenter defaultCenter] postNotificationName:HSGlobalSelectionSyncDidChangeSelectedObjectNotification object:self];
}

- (BOOL)isRegisteredSelectionHost:(id)aHost
{
    return [aHost isKindOfClass:[HSEditorSelectionSync class]];
}

- (void)editorSelectionSyncDidChangeSelection:(id)aSelection
{
    if ([self currentSelectionHost] == aSelection)
        [self refreshCurrentlySelectedObjectAndNotify:YES];
}

- (void)editorSelectionSyncWillResignActive:(id)aActive
{
    [self setCurrentSelectionHost:nil];
}

- (void)editorSelectionSyncDidBecomeActive:(id)aActive
{
    [self setCurrentSelectionHost:aActive];
}

- (void)dealloc
{
    if (HSGlobalSelectionSyncShared == self)
        HSGlobalSelectionSyncShared = nil;
    [super dealloc];
}

- (id)init
{
    if (HSGlobalSelectionSyncShared != nil) {
        [self release];
        return [HSGlobalSelectionSyncShared retain];
    }
    self = [super init];
    if (self != nil)
        HSGlobalSelectionSyncShared = [self retain];
    return self;
}

@end
