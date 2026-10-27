#import "HSTextViewEditor+HSDOMAssistantAdaption.h"

@implementation HSTextViewEditor (HSDOMAssistantAdaption)

- (id)rootViewController
{
    HSActionsAssistantPane *actions = [[[HSActionsAssistantPane alloc] initWithActionEvent:nil] autorelease];
    id style = [[HSTextStyleAssistantPane new] autorelease];
    id features = [[HSGenericObjectFeaturesAssistantPane new] autorelease];
    id appearance = [[HSTextAppearanceAssistantPane new] autorelease];
    NSDictionary *panes = [NSDictionary dictionaryWithObjectsAndKeys:appearance, HSAppearanceObjectAssistantRootPaneName,
        features, @"HSGenericObjectFeaturesAssistantPane", style, @"HSTextStyleAssistantPane", actions, @"HSActionsAssistantPane", nil];
    return [[[HSObjectAssistantToolbarController alloc] initWithViewControllers:panes withDefaultPaneIdentifier:HSAppearanceObjectAssistantRootPaneName] autorelease];
}

@end

@implementation HSRotatableTextObjectEditor (HSDOMAssistantAdaption)

- (id)rootViewController
{
    HSActionsAssistantPane *actions = [[[HSActionsAssistantPane alloc] initWithActionEvent:nil] autorelease];
    id style = [[HSTextStyleAssistantPane new] autorelease];
    id features = [[HSGenericObjectFeaturesAssistantPane new] autorelease];
    id appearance = [[HSTextAppearanceAssistantPane new] autorelease];
    NSDictionary *panes = [NSDictionary dictionaryWithObjectsAndKeys:appearance, HSAppearanceObjectAssistantRootPaneName,
        features, @"HSGenericObjectFeaturesAssistantPane", style, @"HSTextStyleAssistantPane", actions, @"HSActionsAssistantPane", nil];
    return [[[HSObjectAssistantToolbarController alloc] initWithViewControllers:panes withDefaultPaneIdentifier:HSAppearanceObjectAssistantRootPaneName] autorelease];
}

@end

@implementation HSTextObjectEditor (HSDOMAssistantAdaption)

- (id)rootViewController
{
    HSActionsAssistantPane *actions = [[[HSActionsAssistantPane alloc] initWithActionEvent:nil] autorelease];
    id style = [[HSTextStyleAssistantPane new] autorelease];
    id features = [[HSGenericObjectFeaturesAssistantPane new] autorelease];
    id appearance = [[HSTextAppearanceAssistantPane new] autorelease];
    NSDictionary *panes = [NSDictionary dictionaryWithObjectsAndKeys:appearance, HSAppearanceObjectAssistantRootPaneName,
        features, @"HSGenericObjectFeaturesAssistantPane", style, @"HSTextStyleAssistantPane", actions, @"HSActionsAssistantPane", nil];
    return [[[HSObjectAssistantToolbarController alloc] initWithViewControllers:panes withDefaultPaneIdentifier:HSAppearanceObjectAssistantRootPaneName] autorelease];
}

@end
