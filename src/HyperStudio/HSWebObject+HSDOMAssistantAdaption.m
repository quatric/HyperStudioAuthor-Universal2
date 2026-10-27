#import "HSWebObject+HSDOMAssistantAdaption.h"

@implementation HSWebObject (HSDOMAssistantAdaption)

- (id)rootViewController
{
    HSActionsAssistantPane *actions = [[[HSActionsAssistantPane alloc] initWithActionEvent:nil] autorelease];
    id features = [[[HSGenericObjectFeaturesAssistantPane alloc] init] autorelease];
    id appearance = [[HSWebObjectAppearanceAssistantPane new] autorelease];
    NSDictionary *panes = [NSDictionary dictionaryWithObjectsAndKeys:appearance, HSAppearanceObjectAssistantRootPaneName, features, @"HSGenericObjectFeaturesAssistantPane", actions, @"HSActionsAssistantPane", nil];
    if (!panes)
        return nil;
    return [[[HSObjectAssistantToolbarController alloc] initWithViewControllers:panes withDefaultPaneIdentifier:HSAppearanceObjectAssistantRootPaneName] autorelease];
}
@end

@implementation HSYouTubeObject (HSDOMAssistantAdaption)

- (id)rootViewController
{
    HSActionsAssistantPane *actions = [[[HSActionsAssistantPane alloc] initWithActionEvent:nil] autorelease];
    id features = [[[HSGenericObjectFeaturesAssistantPane alloc] init] autorelease];
    id appearance = [[HSYouTubeObjectAppearanceAssistantPane new] autorelease];
    NSDictionary *panes = [NSDictionary dictionaryWithObjectsAndKeys:appearance, HSAppearanceObjectAssistantRootPaneName, features, @"HSGenericObjectFeaturesAssistantPane", actions, @"HSActionsAssistantPane", nil];
    return [[[HSObjectAssistantToolbarController alloc] initWithViewControllers:panes withDefaultPaneIdentifier:HSAppearanceObjectAssistantRootPaneName] autorelease];
}

@end

@implementation HSMovieObject (HSDOMAssistantAdaption)

- (id)rootViewController
{
    HSActionsAssistantPane *actions = [[[HSActionsAssistantPane alloc] initWithActionEvent:nil] autorelease];
    id starting = [[HSMovieStartingAssistantPane new] autorelease];
    id features = [[[HSGenericObjectFeaturesAssistantPane alloc] init] autorelease];
    id appearance = [[HSMovieObjectAppearanceAssistantPane new] autorelease];
    NSDictionary *panes = [NSDictionary dictionaryWithObjectsAndKeys:appearance, HSAppearanceObjectAssistantRootPaneName, features, @"HSGenericObjectFeaturesAssistantPane", starting, HSStartingAssistantRootPaneName, actions, @"HSActionsAssistantPane", nil];
    return [[[HSObjectAssistantToolbarController alloc] initWithViewControllers:panes withDefaultPaneIdentifier:HSAppearanceObjectAssistantRootPaneName] autorelease];
}

@end

@implementation HSVectorGraphicsObject (HSDOMAssistantAdaption)

- (id)rootViewController
{
    HSActionsAssistantPane *actions = [[[HSActionsAssistantPane alloc] initWithActionEvent:nil] autorelease];
    id features = [[HSGenericObjectFeaturesAssistantPane new] autorelease];
    Class appearanceClass = [self queryHyperInterface:@protocol(HSBackgroundAttributes)] ? [HSDrawShapeAppearanceAssistantPane class] : [HSBrushAppearanceAssistantPane class];
    id appearance = [[appearanceClass new] autorelease];
    NSDictionary *panes = [NSDictionary dictionaryWithObjectsAndKeys:appearance, HSAppearanceObjectAssistantRootPaneName, features, @"HSGenericObjectFeaturesAssistantPane", actions, @"HSActionsAssistantPane", nil];
    return [[[HSObjectAssistantToolbarController alloc] initWithViewControllers:panes withDefaultPaneIdentifier:HSAppearanceObjectAssistantRootPaneName] autorelease];
}

@end

@implementation HSVectorBrushObject (HSDOMAssistantAdaption)

- (id)rootViewController
{
    HSActionsAssistantPane *actions = [[[HSActionsAssistantPane alloc] initWithActionEvent:nil] autorelease];
    id features = [[HSGenericObjectFeaturesAssistantPane new] autorelease];
    id appearance = [[HSBrushAppearanceAssistantPane new] autorelease];
    NSDictionary *panes = [NSDictionary dictionaryWithObjectsAndKeys:appearance, HSAppearanceObjectAssistantRootPaneName, features, @"HSGenericObjectFeaturesAssistantPane", actions, @"HSActionsAssistantPane", nil];
    return [[[HSObjectAssistantToolbarController alloc] initWithViewControllers:panes withDefaultPaneIdentifier:HSAppearanceObjectAssistantRootPaneName] autorelease];
}

@end

@implementation HSWebPageObject (HSDOMAssistantAdaption)

- (id)rootViewController
{
    HSActionsAssistantPane *actions = [[[HSActionsAssistantPane alloc] initWithActionEvent:nil] autorelease];
    id features = [[[HSGenericObjectFeaturesAssistantPane alloc] init] autorelease];
    id appearance = [[HSWebcamAppearanceAssistantPane new] autorelease];
    NSDictionary *panes = [NSDictionary dictionaryWithObjectsAndKeys:appearance, HSAppearanceObjectAssistantRootPaneName, features, @"HSGenericObjectFeaturesAssistantPane", actions, @"HSActionsAssistantPane", nil];
    return [[[HSObjectAssistantToolbarController alloc] initWithViewControllers:panes withDefaultPaneIdentifier:HSAppearanceObjectAssistantRootPaneName] autorelease];
}

@end

@implementation HSLiveObject (HSDOMAssistantAdaption)

- (id)rootViewController
{
    HSActionsAssistantPane *actions = [[[HSActionsAssistantPane alloc] initWithActionEvent:nil] autorelease];
    id features = [[[HSGenericObjectFeaturesAssistantPane alloc] init] autorelease];
    id appearance = [[HSLiveObjectAppearanceAssistantPane new] autorelease];
    NSDictionary *panes = [NSDictionary dictionaryWithObjectsAndKeys:appearance, HSAppearanceObjectAssistantRootPaneName, features, @"HSGenericObjectFeaturesAssistantPane", actions, @"HSActionsAssistantPane", nil];
    return [[[HSObjectAssistantToolbarController alloc] initWithViewControllers:panes withDefaultPaneIdentifier:HSAppearanceObjectAssistantRootPaneName] autorelease];
}

@end

@implementation HSSystemImageView (HSDOMAssistantAdaption)

- (id)rootViewController
{
    HSActionsAssistantPane *actions = [[[HSActionsAssistantPane alloc] initWithActionEvent:nil] autorelease];
    id features = [[HSGenericObjectFeaturesAssistantPane new] autorelease];
    id appearance = [[HSImageWellAppearanceAssistantPane new] autorelease];
    NSDictionary *panes = [NSDictionary dictionaryWithObjectsAndKeys:appearance, HSAppearanceObjectAssistantRootPaneName, features, @"HSGenericObjectFeaturesAssistantPane", actions, @"HSActionsAssistantPane", nil];
    return [[[HSObjectAssistantToolbarController alloc] initWithViewControllers:panes withDefaultPaneIdentifier:HSAppearanceObjectAssistantRootPaneName] autorelease];
}

@end

@implementation HSSystemBox (HSDOMAssistantAdaption)

- (id)rootViewController
{
    HSActionsAssistantPane *actions = [[[HSActionsAssistantPane alloc] initWithActionEvent:nil] autorelease];
    id features = [[[HSGenericObjectFeaturesAssistantPane alloc] init] autorelease];
    id appearance = [[HSSystemBoxAppearanceAssistantPane new] autorelease];
    NSDictionary *panes = [NSDictionary dictionaryWithObjectsAndKeys:appearance, HSAppearanceObjectAssistantRootPaneName, features, @"HSGenericObjectFeaturesAssistantPane", actions, @"HSActionsAssistantPane", nil];
    return [[[HSObjectAssistantToolbarController alloc] initWithViewControllers:panes withDefaultPaneIdentifier:HSAppearanceObjectAssistantRootPaneName] autorelease];
}

@end

@implementation HSTextObject (HSDOMAssistantAdaption)

- (id)rootViewController
{
    HSActionsAssistantPane *actions = [[[HSActionsAssistantPane alloc] initWithActionEvent:nil] autorelease];
    id style = [[HSTextObjectStyleAssistantPane new] autorelease];
    id features = [[HSGenericObjectFeaturesAssistantPane new] autorelease];
    id appearance = [[HSTextObjectAppearanceAssistantPane new] autorelease];
    NSDictionary *panes = [NSDictionary dictionaryWithObjectsAndKeys:appearance, HSAppearanceObjectAssistantRootPaneName, features, @"HSGenericObjectFeaturesAssistantPane", style, @"HSTextStyleAssistantPane", actions, @"HSActionsAssistantPane", nil];
    return [[[HSObjectAssistantToolbarController alloc] initWithViewControllers:panes withDefaultPaneIdentifier:HSAppearanceObjectAssistantRootPaneName] autorelease];
}

@end

@implementation HSSystemTextView (HSDOMAssistantAdaption)

- (id)rootViewController
{
    HSActionsAssistantPane *actions = [[[HSActionsAssistantPane alloc] initWithActionEvent:nil] autorelease];
    id style = [[HSTextStyleAssistantPane new] autorelease];
    id features = [[HSGenericObjectFeaturesAssistantPane new] autorelease];
    id appearance = [[HSTextAppearanceAssistantPane new] autorelease];
    NSDictionary *panes = [NSDictionary dictionaryWithObjectsAndKeys:appearance, HSAppearanceObjectAssistantRootPaneName, features, @"HSGenericObjectFeaturesAssistantPane", style, @"HSTextStyleAssistantPane", actions, @"HSActionsAssistantPane", nil];
    return [[[HSObjectAssistantToolbarController alloc] initWithViewControllers:panes withDefaultPaneIdentifier:HSAppearanceObjectAssistantRootPaneName] autorelease];
}

@end

@implementation HSButtonObject (HSDOMAssistantAdaption)

- (id)rootViewController
{
    HSActionsAssistantPane *actions = [[[HSActionsAssistantPane alloc] initWithActionEvent:nil] autorelease];
    id style = [[HSButtonObjectStyleAssistantPane new] autorelease];
    id features = [[[HSGenericObjectFeaturesAssistantPane alloc] init] autorelease];
    id appearance = [[HSButtonObjectAssistantPane new] autorelease];
    NSDictionary *panes = [NSDictionary dictionaryWithObjectsAndKeys:appearance, HSAppearanceObjectAssistantRootPaneName, features, @"HSGenericObjectFeaturesAssistantPane", style, @"HSTextStyleAssistantPane", actions, @"HSActionsAssistantPane", nil];
    return [[[HSObjectAssistantToolbarController alloc] initWithViewControllers:panes withDefaultPaneIdentifier:HSAppearanceObjectAssistantRootPaneName] autorelease];
}

@end

@implementation HSImageObject (HSDOMAssistantAdaption)

- (id)rootViewController
{
    HSActionsAssistantPane *actions = [[[HSActionsAssistantPane alloc] initWithActionEvent:nil] autorelease];
    id graphicObjects = [[HSGraphicObjectsAssistantPane new] autorelease];
    id features = [[HSGenericObjectFeaturesAssistantPane new] autorelease];
    id appearance = [[HSGraphicAppearanceAssistantPane new] autorelease];
    NSDictionary *panes = [NSDictionary dictionaryWithObjectsAndKeys:appearance, HSAppearanceObjectAssistantRootPaneName, features, @"HSGenericObjectFeaturesAssistantPane", graphicObjects, @"HSGraphicObjectsAssistantPane", actions, @"HSActionsAssistantPane", nil];
    return [[[HSObjectAssistantToolbarController alloc] initWithViewControllers:panes withDefaultPaneIdentifier:@"HSGraphicObjectsAssistantPane"] autorelease];
}

@end

@implementation HSStack (HSDOMAssistantAdaption)

- (id)rootViewController
{
    return [[HSStackAssistantPane new] autorelease];
}

@end

@implementation HSCard (HSDOMAssistantAdaption)

- (id)rootViewController
{
    return [[HSCardAssistantPane new] autorelease];
}

@end
