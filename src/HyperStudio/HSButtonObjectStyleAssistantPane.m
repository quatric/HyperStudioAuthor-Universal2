#import "HSButtonObjectStyleAssistantPane.h"

@implementation HSButtonObjectStyleAssistantPane

+ (BOOL)canEditObject:(id)aObject
{
    return [aObject implementsHyperInterface:@protocol(HSButtonObjectAttributes)];
}

- (void)validateAlignmentMatrixState
{
    [super validateAlignmentMatrixState];
    if ([[[[[self assistant] object] queryHyperInterface:@protocol(HSButtonObjectSystemStyleBackgroundAttributes)] systemButtonType] isEqualToString:@"HSTexturedBackgroundSystemButtonType"])
        [_alignmentMatrix setEnabled:NO];
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUI];
}

- (void)setVerticalAlignment:(id)aAlignment
{
    id attributes = [[[self assistant] object] queryHyperInterface:@protocol(HSSystemTextViewFontTraitsAttributes)];
    if (attributes != nil)
        [attributes setHyperAlignment:[[aAlignment selectedCell] tag]];
}

- (void)setObservedButtonObjectBackgroundAttributes:(id)aAttributes
{
    if (_observedButtonObjectBackgroundAttributes != aAttributes) {
        [[_observedButtonObjectBackgroundAttributes attributeObservingController] removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSButtonObjectSystemStyleBackgroundAttributes)];
        [_observedButtonObjectBackgroundAttributes release];
        _observedButtonObjectBackgroundAttributes = [aAttributes retain];
        [[_observedButtonObjectBackgroundAttributes attributeObservingController] addObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSButtonObjectSystemStyleBackgroundAttributes) withPriority:-0.25f];
    }
}

- (void)setObservedButtonObjectAttributes:(id)aAttributes
{
    if (_observedButtonObjectAttributes != aAttributes) {
        [[_observedButtonObjectAttributes attributeObservingController] removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSButtonObjectAttributes)];
        [_observedButtonObjectAttributes release];
        _observedButtonObjectAttributes = [aAttributes retain];
        [[_observedButtonObjectAttributes attributeObservingController] addObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSButtonObjectAttributes) withPriority:-0.25f];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_backgroundColorWell setPatternSupportEnabled:NO];
    [_backgroundColorWell setGradientSupportEnabled:NO];
    [_textColorWell setGradientSupportEnabled:NO];
    [_textColorWell setPatternSupportEnabled:YES];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [super viewWillDisappear:aDisappear];
    [self setObservedButtonObjectAttributes:nil];
    [self setObservedButtonObjectBackgroundAttributes:nil];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [self setObservedButtonObjectAttributes:[[[self assistant] object] queryHyperInterface:@protocol(HSButtonObjectAttributes)]];
    [self setObservedButtonObjectBackgroundAttributes:[[[self assistant] object] queryHyperInterface:@protocol(HSButtonObjectSystemStyleBackgroundAttributes)]];
    [super viewWillAppear:aAppear];
}

- (void)dealloc
{
    [self setObservedButtonObjectAttributes:nil];
    [self setObservedButtonObjectBackgroundAttributes:nil];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"EditButtonStyleAssistantPane"];
    if (self != nil) {
        [self setTitle:[[NSBundle mainBundle] localizedStringForKey:@"Style" value:@"" table:@"AssistantPanes"]];
        [self setIcon:[NSImage imageNamed:@"style"]];
    }
    return self;
}

- (id)assistantObjectBackgroundType
{
    return [(id<HSButtonObjectSystemStyleBackgroundAttributes>)[[[self assistant] object] queryHyperInterface:@protocol(HSButtonObjectSystemStyleBackgroundAttributes)] systemButtonType];
}

@end
