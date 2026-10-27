#import "HSPatternColorMatrix.h"

@implementation HSPatternColorMatrix

- (void)handleDoubleClick
{
    HSAlert *alert = [HSAlert new];
    [alert setAlertStyle:5];
    [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"PatternEditAlertText" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"OK" value:@"" table:@"Alerts"]];
    [alert runModal];
    [alert release];
    [super handleDoubleClick];
}

- (id)initWithFrame:(NSRect)aFrame
{
    return [super initWithFrame:aFrame dataProvider:[HSPatternColorMatrixDataProvider sharedDataProvider]];
}

@end
