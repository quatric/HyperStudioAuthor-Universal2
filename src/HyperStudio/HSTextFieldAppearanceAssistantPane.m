#import "HSTextFieldAppearanceAssistantPane.h"

@implementation HSTextFieldAppearanceAssistantPane

+ (BOOL)canEditObject:(id)aObject
{
    return [aObject implementsHyperInterface:@protocol(HSSystemTextFieldAttributes)];
}

- (void)validateUI
{
    id attributes = [[[self assistant] object] queryHyperInterface:@protocol(HSSystemTextFieldAttributes)];
    if (attributes == nil)
        return;
    [_nameTextField setStringValue:[attributes title]];
    [_textColorWell setColor:[attributes textColor]];
    [_backgroundColorWell setColor:[attributes backgroundColor]];
    [_readOnlyButton setState:![attributes isEditable] ? NSControlStateValueOn : NSControlStateValueOff];
    [_roundedButton setState:[attributes hyperTextFieldBezelStyle] != 0 ? NSControlStateValueOn : NSControlStateValueOff];
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUI];
}

- (void)readOnlyEnabled:(id)aEnabled
{
    id attributes = [[[self assistant] object] queryHyperInterface:@protocol(HSSystemTextFieldAttributes)];
    [attributes setEditable:[[aEnabled selectedCell] state] == NSControlStateValueOff];
}

- (void)roundedEnabled:(id)aEnabled
{
    id attributes = [[[self assistant] object] queryHyperInterface:@protocol(HSSystemTextFieldAttributes)];
    [attributes setHyperTextFieldBezelStyle:[[aEnabled selectedCell] state] == NSControlStateValueOn];
}

- (void)setBackgoundColor:(id)aColor
{
    [[[[self assistant] object] queryHyperInterface:@protocol(HSBackgroundColorAttribute)] setBackgroundColor:[(NSColorWell *)aColor color]];
}

- (void)setTextColor:(id)aColor
{
    [[[[self assistant] object] queryHyperInterface:@protocol(HSTextColorAttribute)] setTextColor:[(NSColorWell *)aColor color]];
}

- (void)setName:(id)aName
{
    [[[[self assistant] object] queryHyperInterface:@protocol(HSTitleAttributes)] setTitle:[aName stringValue]];
}

- (id)nameTextfField
{
    return _nameTextField;
}

- (id)initialKeyView
{
    return _nameTextField;
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [[[[[self assistant] object] queryHyperInterface:@protocol(HSSystemTextFieldAttributes)] attributeObservingController] removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSSystemTextFieldAttributes)];
    [[[[[self assistant] object] queryHyperInterface:@protocol(HSMutableObjectAttributes)] attributeObservingController] removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSMutableObjectAttributes)];
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [[[[[self assistant] object] queryHyperInterface:@protocol(HSSystemTextFieldAttributes)] attributeObservingController] addObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSSystemTextFieldAttributes) withPriority:-0.25f];
    [[[[[self assistant] object] queryHyperInterface:@protocol(HSMutableObjectAttributes)] attributeObservingController] addObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSMutableObjectAttributes) withPriority:-0.25f];
    [self validateUI];
}

- (id)init
{
    return [super initWithNibName:@"TextFieldAppearancePane"];
}

@end
