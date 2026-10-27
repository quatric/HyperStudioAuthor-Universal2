#import "HSTextObjectAppearanceAssistantPane.h"

@implementation HSTextObjectAppearanceAssistantPane

+ (BOOL)canEditObject:(id)aObject
{
    return [aObject implementsHyperInterface:@protocol(HSTextObjectAttributes)];
}

// Opacity is only editable for colors that are not pattern colors.
- (void)validateUI
{
    id attributes = [[[self assistant] object] queryHyperInterface:@protocol(HSMutableObjectAttributes)];
    if (attributes != nil)
        [_nameTextField setStringValue:[attributes hyperName]];
    id textAttributes = [[[self assistant] object] queryHyperInterface:@protocol(HSTextObjectAttributes)];
    if (textAttributes == nil)
        return;
    NSColor *color = [textAttributes hyperTextColor];
    BOOL isPattern = YES;
    [_textColorWell setColor:color];
    @try {
        [color patternImage];
    }
    @catch (NSException *exception) {
        isPattern = NO;
    }
    float opacity = [color alphaComponent] * 100.0f;
    [_opacitySlider setFloatValue:opacity];
    [_opacityTextField setFloatValue:opacity];
    [_opacityStepper setFloatValue:opacity];
    [_opacitySlider setEnabled:!isPattern];
    [_opacityTextField setEnabled:!isPattern];
    [_opacityStepper setEnabled:!isPattern];
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUI];
}

- (void)opacityChanged:(id)aChanged
{
    float opacity = [aChanged floatValue];
    id textAttributes = [[[self assistant] object] queryHyperInterface:@protocol(HSTextObjectAttributes)];
    [textAttributes setHyperTextColor:[(NSColor *)[textAttributes hyperTextColor] colorWithAlphaComponent:opacity / 100.0f]];
}

- (void)setTextColor:(id)aColor
{
    id textAttributes = [[[self assistant] object] queryHyperInterface:@protocol(HSTextObjectAttributes)];
    [textAttributes setHyperTextColor:[(NSColorWell *)aColor color]];
}

- (void)setName:(id)aName
{
    id attributes = [[[self assistant] object] queryHyperInterface:@protocol(HSMutableObjectAttributes)];
    [attributes setHyperName:[aName stringValue]];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [super viewWillDisappear:aDisappear];
    [[[[[self assistant] object] queryHyperInterface:@protocol(HSMutableObjectAttributes)] attributeObservingController] removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSMutableObjectAttributes)];
    [[[[[self assistant] object] queryHyperInterface:@protocol(HSTextObjectAttributes)] attributeObservingController] removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSTextObjectAttributes)];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [[[[[self assistant] object] queryHyperInterface:@protocol(HSMutableObjectAttributes)] attributeObservingController] addObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSMutableObjectAttributes) withPriority:-0.25f];
    [[[[[self assistant] object] queryHyperInterface:@protocol(HSTextObjectAttributes)] attributeObservingController] addObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSTextObjectAttributes) withPriority:-0.25f];
    [self validateUI];
}

- (void)viewDidLoad
{
    [_textColorWell setGradientSupportEnabled:YES];
}

- (id)init
{
    self = [super initWithNibName:@"TextObjectAppearancePane"];
    if (self != nil) {
        [self setTitle:[[NSBundle mainBundle] localizedStringForKey:@"Appearance" value:@"" table:@"AssistantPanes"]];
        [self setIcon:[NSImage imageNamed:@"general"]];
    }
    return self;
}

@end
