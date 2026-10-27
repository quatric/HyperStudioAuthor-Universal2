#import "HSDefaultSavePanelAccessoryViewController.h"
@implementation HSDefaultSavePanelAccessoryViewController
- (void)setShouldChangeHomeStackURL:(BOOL)aURL
{
    [self accessoryView];   // loads the nib
    [_changeHomeStackURLSwitch setState:aURL ? NSControlStateValueOn : NSControlStateValueOff];
}
- (BOOL)shouldChangeHomeStackURL
{
    return [_changeHomeStackURLSwitch state] == NSControlStateValueOn;
}
- (id)init
{
    return [self initWithNibName:@"DefaultSaveAccessoryView"];
}
@end
