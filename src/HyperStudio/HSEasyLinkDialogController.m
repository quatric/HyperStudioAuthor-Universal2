#import "HSEasyLinkDialogController.h"

@implementation HSEasyLinkDialogController

// Original quirk kept: the Done button is never disabled again.
- (void)fileNameDidChange:(id)aChange
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[_fileNameTextField stringValue]])
        [_doneButton setEnabled:YES];
}

- (void)applyChanges
{
    HSOpenLocationAction *action = [[[HSOpenLocationAction alloc] init] autorelease];

    [action setURL:[NSURL fileURLWithPath:[_fileNameTextField stringValue]]];
    [action setOpensDocument:YES];
    [self addButtonWithOpenLoactionAction:action];
}

- (void)chooseFile:(id)aFile
{
    NSOpenPanel *panel = [[NSOpenPanel openPanel] retain];
    NSString *folder;

    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    folder = [[HSPathsProvider sharedPathsProvider] easyLinkFolder];
    if (folder != nil)
        [panel setDirectoryURL:[NSURL fileURLWithPath:folder isDirectory:YES]];
    if ([panel runModal] == NSModalResponseOK) {
        [[HSPathsProvider sharedPathsProvider] setEasyLinkFolder:[[panel directoryURL] path]];
        [_fileNameTextField setStringValue:[[[panel URLs] objectAtIndex:0] path]];
        [self fileNameDidChange:self];
    }
    [panel release];
}

- (void)addButtonWithOpenLoactionAction:(id)aAction
{
    id button = [HSButtonObject defaultObject];
    id applier;
    NSSize size;

    [button setTitle:[[[[aAction URL] path] lastPathComponent] stringByDeletingPathExtension]];
    [button hyperAutoSizeToFitTitle];
    size = [(HSButtonObject *)button size];
    applier = [[button queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    [applier resizeTo:NSMakeSize(MAX(size.width, size.height), size.height) withLayoutGuidingContext:nil];
    [applier moveFrameBoundingRectOriginTo:NSMakePoint(10.0, 10.0) withLayoutGuidingContext:nil];
    [[button queryHyperInterface:@protocol(HSActor)] addHyperAction:aAction forEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType]];
    if ([[self document] prepareForHandlingActionThatRequiresConditionalSwitchToEditMode])
        [[self card] addHyperChild:button];
}

- (id)nibName
{
    return @"EasyLink";
}

@end
