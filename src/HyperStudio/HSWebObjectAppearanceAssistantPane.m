#import "HSWebObjectAppearanceAssistantPane.h"

@implementation HSWebObjectAppearanceAssistantPane

- (void)setRefreshRate:(id)aRate
{
    [_webElementAttributes setRefreshRate:[aRate floatValue] / 60.0f];
    [self HSWebObjectAppearanceAssistantPane_refreshRateDidChange:nil];
}

- (void)setName:(id)aName
{
    [_objectAttributes setHyperName:[aName stringValue]];
}

- (void)textDidEndEditing:(id)aEditing
{
    [_webElementAttributes setHTMLCode:[_HTMLCodeTextView string]];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [_webElementAttributes setHTMLCode:[_HTMLCodeTextView string]];
    id controller = [_objectAttributes attributeObservingController];
    [controller removeObserver:self selector:@selector(HSWebObjectAppearanceAssistantPane_nameDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSObjectNameAttribute)];
    [controller removeObserver:self selector:@selector(HSWebObjectAppearanceAssistantPane_HTMLCodeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSWebElementHTMLCodeAttribute)];
    [controller removeObserver:self selector:@selector(HSWebObjectAppearanceAssistantPane_refreshRateDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSWebElementRefreshRateAttribute)];
    [_webElementAttributes release];
    [_objectAttributes release];
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    _objectAttributes = [[[[self assistant] object] queryHyperInterface:@protocol(HSMutableObjectAttributes)] retain];
    _webElementAttributes = [[_objectAttributes queryHyperInterface:@protocol(HSWebElementAttributes)] retain];
    [self HSWebObjectAppearanceAssistantPane_nameDidChange:nil];
    [self HSWebObjectAppearanceAssistantPane_HTMLCodeDidChange:nil];
    [self HSWebObjectAppearanceAssistantPane_refreshRateDidChange:nil];
    id controller = [_objectAttributes attributeObservingController];
    [controller addObserver:self selector:@selector(HSWebObjectAppearanceAssistantPane_nameDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSObjectNameAttribute) withPriority:-0.25];
    [controller addObserver:self selector:@selector(HSWebObjectAppearanceAssistantPane_HTMLCodeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSWebElementHTMLCodeAttribute) withPriority:-0.25];
    [controller addObserver:self selector:@selector(HSWebObjectAppearanceAssistantPane_refreshRateDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSWebElementRefreshRateAttribute) withPriority:-0.25];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[_refreshRateTextField formatter] setHasThousandSeparators:NO];
}

- (void)HSWebObjectAppearanceAssistantPane_refreshRateDidChange:(id)aChange
{
    float refreshRate = [_webElementAttributes refreshRate];
    [_refreshRateTextField setFloatValue:refreshRate * 60.0f];
    [_refreshRateStepper setFloatValue:refreshRate * 60.0f];
}

- (void)HSWebObjectAppearanceAssistantPane_HTMLCodeDidChange:(id)aChange
{
    NSString *code = [_webElementAttributes HTMLCode];
    [_HTMLCodeTextView setString:code != nil ? code : @""];
}

- (void)HSWebObjectAppearanceAssistantPane_nameDidChange:(id)aChange
{
    NSString *name = [_objectAttributes hyperName];
    [_nameTextField setStringValue:[name length] != 0 ? name : @"--"];
}

- (id)init
{
    self = [super initWithNibName:@"WebObjectAppearancePane"];
    if (self != nil) {
        NSString *title = [[NSBundle mainBundle] localizedStringForKey:@"Appearance" value:@"" table:@"AssistantPanes"];
        if (title != nil) {
            [super setTitle:title];
            NSImage *icon = [NSImage imageNamed:@"general"];
            if (icon != nil)
                [super setIcon:icon];
        }
    }
    return self;
}

@end
