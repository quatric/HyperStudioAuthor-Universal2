#import "HSSystemBoxAppearanceAssistantPane.h"

@implementation HSSystemBoxAppearanceAssistantPane

- (void)validateTitle
{
    id attributes = [[[self assistant] object] queryHyperInterface:@protocol(HSSystemBoxTitleMutableAttributes)];
    if (attributes != nil) {
        [_showTitleSwitch setState:[attributes isHyperTitleVisible] ? NSControlStateValueOn : NSControlStateValueOff];
        [_titleTextField setStringValue:[attributes title]];
    }
}

- (void)validateName
{
    id attributes = [[[self assistant] object] queryHyperInterface:@protocol(HSMutableObjectAttributes)];
    if (attributes != nil)
        [_nameTextField setStringValue:[attributes hyperName]];
}

- (void)validateUI
{
    [self validateName];
    [self validateTitle];
}

- (void)validateTitleWithNotification:(id)aNotification
{
    [self validateTitle];
}

- (void)validateNameWithNotification:(id)aNotification
{
    [self validateName];
}

- (void)changeTitleVisibility:(id)aVisibility
{
    [[[[self assistant] object] queryHyperInterface:@protocol(HSSystemBoxTitleMutableAttributes)] setHyperTitleVisible:[aVisibility state] == NSControlStateValueOn];
}

- (void)changeTitle:(id)aTitle
{
    [[[[self assistant] object] queryHyperInterface:@protocol(HSSystemBoxTitleMutableAttributes)] setTitle:[aTitle stringValue]];
}

- (void)changeName:(id)aName
{
    [[[[self assistant] object] queryHyperInterface:@protocol(HSMutableObjectAttributes)] setHyperName:[aName stringValue]];
}

- (id)nameTextfField
{
    return _nameTextField;
}

- (id)initialKeyView
{
    return _nameTextField;
}

- (BOOL)isEditingTextAttribute
{
    return [_nameTextField currentEditor] != nil || [_titleTextField currentEditor] != nil;
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [super viewWillDisappear:aDisappear];
    [[[[[self assistant] object] queryHyperInterface:@protocol(HSSystemBoxTitleMutableAttributes)] attributeObservingController] removeObserver:self selector:@selector(validateTitleWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSSystemBoxTitleMutableAttributes)];
    [[[[[self assistant] object] queryHyperInterface:@protocol(HSMutableObjectAttributes)] attributeObservingController] removeObserver:self selector:@selector(validateNameWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSMutableObjectAttributes)];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [self validateUI];
    [[[[[self assistant] object] queryHyperInterface:@protocol(HSSystemBoxTitleMutableAttributes)] attributeObservingController] addObserver:self selector:@selector(validateTitleWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSSystemBoxTitleMutableAttributes) withPriority:-0.25f];
    [[[[[self assistant] object] queryHyperInterface:@protocol(HSMutableObjectAttributes)] attributeObservingController] addObserver:self selector:@selector(validateNameWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSMutableObjectAttributes) withPriority:-0.25f];
}

- (id)init
{
    self = [super initWithNibName:@"SystemBoxAppearancePane"];
    if (self != nil) {
        [self setTitle:[[NSBundle mainBundle] localizedStringForKey:@"Appearance" value:@"" table:@"AssistantPanes"]];
        [self setIcon:[NSImage imageNamed:@"general"]];
    }
    return self;
}

@end
