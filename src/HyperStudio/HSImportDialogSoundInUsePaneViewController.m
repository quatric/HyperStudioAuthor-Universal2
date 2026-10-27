#import "HSImportDialogSoundInUsePaneViewController.h"

@implementation HSImportDialogSoundInUsePaneViewController

+ (void)load
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    [HSImportDialogController registerPaneViewController:self withIdentifier:HSImportDialogControllerTypeSound];
    [pool release];
}

- (void)tableView:(id)aView didClickTableColumn:(id)aColumn
{
}

// Re-sorts the list and restores the selection.
- (void)tableView:(id)aView sortDescriptorsDidChange:(id)aChange
{
    NSIndexSet *selectedIndexes = _soundsInUse ? [_soundsTableView selectedRowIndexes] : [NSIndexSet indexSet];
    NSArray *selectedSounds = [[self soundsInUse] objectsAtIndexes:selectedIndexes];
    NSArray *sorted = [[self soundsInUse] sortedArrayUsingDescriptors:[aView sortDescriptors]];
    [_soundsInUse release];
    _soundsInUse = [sorted retain];
    [aView reloadData];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    NSEnumerator *enumerator = [selectedSounds objectEnumerator];
    id sound;
    while ((sound = [enumerator nextObject])) {
        NSUInteger index = [[self soundsInUse] indexOfObject:sound];
        if (index != NSNotFound)
            [indexes addIndex:index];
    }
    [_soundsTableView selectRowIndexes:indexes byExtendingSelection:NO];
    [_soundsTableView scrollRowToVisible:[indexes firstIndex]];
}

- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow
{
    id attributes = [[[self soundsInUse] objectAtIndex:aRow] queryHyperInterface:@protocol(HSSoundPlaybackAttributes)];
    if (!attributes)
        return nil;
    id icon = [[aColumn identifier] isEqualToString:biSoundIconKey] ? [self defaultSoundIcon] : nil;
    if ([[aColumn identifier] isEqual:@"SoundName"])
        return [[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:[attributes mediaUID]] mediaName];
    if ([[aColumn identifier] isEqual:@"SoundDuration"])
        return [NSCalendarDate dateWithYear:0 month:0 day:0 hour:0 minute:0 second:(NSUInteger)[(NSSound *)[attributes sound] duration] timeZone:nil];
    return icon;
}

- (NSInteger)numberOfRowsInTableView:(id)aView
{
    return [[self soundsInUse] count];
}

- (id)soundsInUse
{
    if (!_soundsInUse) {
        _soundsInUse = [[HSSoundsInUseProvider soundsInUseForStack:[[self paneHyperDocument] stack]] retain];
        NSString *format = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"%dItems" value:@"" table:@"ImportDialogs"];
        [_itemsCountTextField setStringValue:[NSString stringWithFormat:format, [_soundsInUse count]]];
    }
    return _soundsInUse;
}

- (id)soundsForActor:(id)aActor
{
    NSMutableSet *sounds = [[NSMutableSet alloc] initWithCapacity:0];
    NSEnumerator *enumerator = [[aActor hyperActionsOfType:[HSPlaySoundAction actionType]] objectEnumerator];
    id action;
    while ((action = [enumerator nextObject]))
        [sounds addObjectsFromArray:[action sounds]];
    NSArray *all = [sounds allObjects];
    [sounds release];
    return all;
}

- (void)willMountToDialogController:(id)aController
{
    [super willMountToDialogController:aController];
    if (_soundsTableView) {
        [_soundsInUse release];
        _soundsInUse = nil;
        [self tableView:_soundsTableView sortDescriptorsDidChange:[_soundsTableView sortDescriptors]];
    }
}

- (id)paneFilePath
{
    NSInteger row = [_soundsTableView selectedRow];
    if (row >= 0 && row < (NSInteger)[[self soundsInUse] count]) {
        id sound = [[self soundsInUse] objectAtIndex:row];
        return [[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:[[sound queryHyperInterface:@protocol(HSSoundPlaybackAttributes)] mediaUID]] fullPathToMediaFile];
    }
    return nil;
}

- (id)paneFileDisplayName
{
    NSInteger row = [_soundsTableView selectedRow];
    if (row >= 0 && row < (NSInteger)[[self soundsInUse] count]) {
        id sound = [[self soundsInUse] objectAtIndex:row];
        return [[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:[[sound queryHyperInterface:@protocol(HSSoundPlaybackAttributes)] mediaUID]] mediaName];
    }
    return nil;
}

- (id)paneTitle
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"ImportDialogSoundInUsePaneTitle" value:@"" table:@"ImportDialogs"];
}

- (NSInteger)paneWeight
{
    return 4;
}

- (id)paneView
{
    if (!_paneView)
        [NSBundle loadNibNamed:[self paneViewNibName] owner:self];
    return _paneView;
}

- (id)paneIdentifier
{
    return @"HSImportDialogInUseSound";
}

- (id)paneViewNibName
{
    return @"IDSoundInUsePaneView";
}

- (void)dealloc
{
    [_soundsInUse release];
    [super dealloc];
}

@end
