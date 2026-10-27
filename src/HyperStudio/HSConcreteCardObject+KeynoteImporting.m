#import "HSConcreteCardObject+KeynoteImporting.h"

@implementation HSConcreteCardObject (KeynoteImporting)

+ (id)actionClassNameFromKeynoteHyperlink:(id)aHyperlink
{
    static NSDictionary *sActionsForKeynote = nil;
    id name;

    if (aHyperlink == nil)
        return nil;
    if (sActionsForKeynote == nil)
        sActionsForKeynote = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ActionsForKeynote" ofType:@"plist"]] retain];

    name = [sActionsForKeynote objectForKey:aHyperlink];
    if (name != nil)
        return name;
    NSArray *parts = [aHyperlink componentsSeparatedByString:@":"];
    if (parts != nil && [parts count] > 1)
        name = [sActionsForKeynote objectForKey:[parts objectAtIndex:0]];
    if (name == nil && [aHyperlink hasPrefix:@"?id="])
        name = [sActionsForKeynote objectForKey:@"?id="];
    return name;
}

- (id)actionWithClassName:(id)aName fromKeynoteItem:(id)aItem
{
    return [self actionWithClassName:aName fromKeynoteItem:aItem withLink:nil];
}

// Builds the HyperStudio action for a Keynote hyperlink; mail and web links end up wrapped in a go-to-URL action.
- (id)actionWithClassName:(id)aName fromKeynoteItem:(id)aItem withLink:(id)aLink
{
    id action = [[NSClassFromString(aName) new] autorelease];
    id attributes = [action queryHyperInterface:@protocol(HSActionAttributes)];
    NSString *link;
    id target;

    if (attributes == nil)
        return nil;

    link = aLink;
    if (![aItem isKindOfClass:[KeynoteShape class]] || [aLink length] == 0) {
        link = [aItem hyperlink];

        target = [attributes queryHyperInterface:@protocol(HSOtherCardActionAttributes)];
        if (target != nil) {
            id stack = [[[self hyperParent] queryHyperInterface:@protocol(HSNodeParentAttribute)] hyperParent];
            NSUInteger index = 0;

            if ([link hasPrefix:@"?slide="]) {
                if (![link hasSuffix:@"first"] && [link hasSuffix:@"last"])
                    index = [stack hyperCount] - 1;
            } else if ([link hasPrefix:@"?id="]) {
                NSString *slideId = [link substringFromIndex:[@"?id=" length]];
                NSArray *slides = [[[aItem slide] keynoteObjectForXMLPath:@"./.."] keynoteObjectForXMLPath:@"./slide"];
                NSUInteger count = [slides count];
                for (index = 0; index < count; index++) {
                    if ([[[slides objectAtIndex:index] nodeId] isEqualToString:slideId])
                        break;
                }
            }
            id uid = [[stack hyperChildAtIndex:index] hyperUID];
            if (uid != nil)
                [target setDestinationCardUID:uid];
        }

        target = [attributes queryHyperInterface:@protocol(HSOpenStackActionAttributes)];
        if (target != nil) {
            NSURL *url = [NSURL fileURLWithPath:[link substringFromIndex:[@"keynote:" length]]];
            if (url != nil)
                [target setURL:url];
        } else {
            target = [attributes queryHyperInterface:@protocol(HSTransitionOwner)];
            if (target != nil) {
                id transition = [HSKeynoteAttributesConvert transitionFromKeynoteTransition:[[[aItem slide] graphicStyle] transition]];
                if (transition != nil)
                    [target setTransition:transition];
            }
        }
    }

    target = [attributes queryHyperInterface:@protocol(HSSendMailActionAttributes)];
    if (target != nil) {
        NSArray *parts = [[link substringFromIndex:[@"mailto" length] + 1] componentsSeparatedByString:@"?subject="];
        if ([parts count] == 2) {
            [target setHyperEmailAddresses:[[parts objectAtIndex:0] componentsSeparatedByString:@"%20"]];
            [target setHyperEmailSubject:[parts objectAtIndex:1]];
        }
        attributes = [[HSGoToURLAction new] autorelease];
        [[attributes queryHyperInterface:@protocol(HSActionOwner)] setCurrentAction:target];
    }

    target = [attributes queryHyperInterface:@protocol(HSOpenWebPageActionAttributes)];
    if (target == nil)
        return attributes;
    [target setURL:[NSURL URLWithString:link]];
    action = [[HSGoToURLAction new] autorelease];
    [[action queryHyperInterface:@protocol(HSActionOwner)] setCurrentAction:target];
    return action;
}

- (void)applyHyperlinkFromKeynoteItem:(id)aItem
{
    NSString *link = [aItem hyperlink];

    if ([link length] == 0 && [[aItem keynoteObjectForXMLPath:@"./.."] isKindOfClass:[KeynoteGroup class]]
        && [aItem isKindOfClass:[KeynoteShape class]] && [aItem exportsText]) {
        link = [[aItem keynoteObjectForXMLPath:@"./.."] hyperlink];
        aItem = [aItem keynoteObjectForXMLPath:@"./.."];
    }
    if (link == nil)
        return;

    id action = [self actionWithClassName:[[self class] actionClassNameFromKeynoteHyperlink:link] fromKeynoteItem:aItem];
    id actor = [self queryHyperInterface:@protocol(HSActor)];
    if (actor != nil && action != nil)
        [actor addHyperAction:action forEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType]];
}

- (void)importLinksFromKeynoteShape:(id)aShape
{
    NSEnumerator *e = [[aShape allLinks] objectEnumerator];
    NSString *title;

    while ((title = [e nextObject]) != nil) {
        id<HSHypertextLinkContainerAttributes> links = [[self stack] queryHyperInterface:@protocol(HSHypertextLinkContainerAttributes)];
        if ([links linkWithTitle:title] != nil)
            continue;
        id link = [links addLinkWithTitle:title];
        id action = [self actionWithClassName:[[self class] actionClassNameFromKeynoteHyperlink:title] fromKeynoteItem:aShape withLink:title];
        [[link queryHyperInterface:@protocol(HSActor)] addHyperAction:action forEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType]];
    }
}

// Lines carry their geometry in the bezier path itself, so only the flips are applied to them.
- (void)applyKeynoteGeometry:(id)aGeometry
{
    id applier = [[self queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];

    if (aGeometry == nil || applier == nil)
        return;
    if ([aGeometry isHorizontalFlip])
        [applier flipHorizontallyWithLayoutGuidingContext:nil];
    if ([aGeometry isVerticalFlip])
        [applier flipVerticallyWithLayoutGuidingContext:nil];
    if ([[aGeometry parentNode] conformsToProtocol:@protocol(KeynoteBezierPathContainer)] && [[aGeometry parentNode] isLine])
        return;
    [applier rotateTo:[aGeometry angle] aboutRelativePoint:NSMakePoint(0.5f, 0.5f) withLayoutGuidingContext:nil];
    [applier setSize:[(KeynoteGeometry *)aGeometry size] withLayoutGuidingContext:nil];
    [applier moveFrameBoundingRectOriginTo:[(KeynoteGeometry *)aGeometry origin] withLayoutGuidingContext:nil];
}

- (void)importFromKeynoteObject:(id)aObject
{
    [self applyKeynoteGeometry:[aObject geometry]];
    if ([aObject isKindOfClass:[KeynoteItem class]]) {
        [self applyKeynoteGraphicStyle:[(KeynoteItem *)aObject style]];
        [self setLocked:[aObject isLocked]];
        [self applyHyperlinkFromKeynoteItem:aObject];
    }
    if ([aObject isKindOfClass:[KeynoteShape class]])
        [self importLinksFromKeynoteShape:aObject];
    [super importFromKeynoteObject:aObject];
}

@end
