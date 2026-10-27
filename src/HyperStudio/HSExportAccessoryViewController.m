#import "HSExportAccessoryViewController.h"

@implementation HSExportAccessoryViewController

- (BOOL)textView:(id)aView clickedOnLink:(id)aLink atIndex:(NSUInteger)aIndex
{
    [[NSWorkspace sharedWorkspace] openFile:@"/System/Library/PreferencePanes/Sound.prefPane"];
    return YES;
}

- (id)exportToDiskDescription
{
    return [self descriptionForKey:[[NSBundle mainBundle] localizedStringForKey:@"informativeTextForSavingToDisk" value:@"" table:@"Export"]];
}

- (id)descriptionForKey:(id)aKey
{
    NSString *directory = [[NSBundle mainBundle] localizedStringForKey:@"ExportDescriptions" value:@"" table:@"Export"];
    NSString *name = [[[self descriptionDictionary] objectForKey:NSStringFromClass([self class])] objectForKey:aKey];
    if (name != nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"rtf" inDirectory:directory];
        NSAttributedString *description = [[[NSAttributedString alloc] initWithPath:path documentAttributes:NULL] autorelease];
        if (description != nil)
            return description;
    }
    return [[[NSAttributedString alloc] initWithString:@""] autorelease];
}

- (id)descriptionDictionary
{
    if (_descriptionDictionary == nil) {
        NSString *name = [[NSBundle mainBundle] localizedStringForKey:@"ExportDescriptionInfo" value:@"" table:@"Export"];
        _descriptionDictionary = [[NSDictionary extraDictionaryNamed:[name stringByAppendingPathExtension:@"plist"]] retain];
    }
    return _descriptionDictionary;
}

- (void)detachFromExporter
{
    _exporter = nil;
}

- (void)refreshDescriptionForPublishType:(NSInteger)aType
{
    if ((NSUInteger)(aType - 1) < 3) {
        NSTextStorage *storage = [_descriptionTextView textStorage];
        NSAttributedString *description = [self exportToDiskDescription];
        [storage replaceCharactersInRange:NSMakeRange(0, [[_descriptionTextView textStorage] length]) withAttributedString:description];
    }
}

- (void)setExportPanelController:(id)aController
{
    if (_exportPanelController != aController)
        _exportPanelController = aController;
}

- (id)exportPanelController
{
    return _exportPanelController;
}

- (void)awakeFromNib
{
    [self refreshDescriptionForPublishType:_publishType];
}

- (void)dealloc
{
    [_descriptionDictionary release];
    [super dealloc];
}

- (id)initWithExporter:(id)aExporter publishType:(NSInteger)aType
{
    self = [self init];
    if (self != nil) {
        _exporter = aExporter;
        _publishType = (int)aType;
    }
    return self;
}

@end
