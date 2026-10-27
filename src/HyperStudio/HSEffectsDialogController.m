#import "HSEffectsDialogController.h"

@implementation HSEffectsDialogController

+ (BOOL)canEditObject:(id)aObject
{
    if (![aObject implementsHyperInterface:@protocol(HSImageObjectAttributes)] && ![aObject implementsHyperInterface:@protocol(HSEditableImageAttributes)])
        return NO;
    return ![[aObject queryHyperInterface:@protocol(HSCardObjectAttributes)] isLocked];
}

- (void)showHelp:(id)aHelp
{
    [[HSHelpBookManager sharedHelpBookManager] openHelpTopic:@"HSEffectsDialog"];
}

- (void)revertSettingsToDefault:(id)aDefault
{
    [_currentEffectController revertSettingsToDefault];
}

- (void)willCloseWindow
{
    [super willCloseWindow];
    [self setObject:nil];
    [_currentEffectController willUnmount];
    [[_currentEffectController contentView] removeFromSuperview];
    [_currentEffectController didUnmount];
}

- (void)applyChanges
{
    [_currentEffectController applyChanges];
}

- (void)willShowWindow
{
    [self tabView:_tabView willSelectTabViewItem:[_tabView selectedTabViewItem]];
}

- (void)tabView:(id)aView willSelectTabViewItem:(id)aItem
{
    [self mountEffectControllerWithIdentifier:[aItem identifier] intoView:[aItem view]];
}

- (void)mountEffectControllerWithIdentifier:(id)aIdentifier intoView:(id)aView
{
    [_currentEffectController willUnmount];
    [[_currentEffectController contentView] removeFromSuperview];
    [_currentEffectController didUnmount];
    [_currentEffectController release];
    _currentEffectController = [[self controllerForIdentifier:aIdentifier] retain];
    [_currentEffectController setObject:_object];
    [aView setAutoresizesSubviews:YES];
    [aView addSubview:[_currentEffectController contentView]];
    [_currentEffectController willMount];
    [[_currentEffectController contentView] setFrame:[aView bounds]];
    [_currentEffectController didMount];
}

- (id)controllerForIdentifier:(id)aIdentifier
{
    if (_controllersByIdentifier == nil)
        _controllersByIdentifier = [NSMutableDictionary new];
    id controller = [_controllersByIdentifier objectForKey:aIdentifier];
    if (controller == nil) {
        controller = [[[NSClassFromString(aIdentifier) alloc] init] autorelease];
        [_controllersByIdentifier setObject:controller forKey:aIdentifier];
    }
    return controller;
}

- (id)nibName
{
    return @"HSEffectsDialog";
}

- (void)setObject:(id)aObject
{
    if (_object != aObject) {
        [_object release];
        _object = [aObject retain];
    }
}

- (id)initWithObject:(id)aObject
{
    self = [super init];
    if (self != nil)
        _object = [aObject retain];
    return self;
}

- (void)dealloc
{
    [_currentEffectController release];
    [_controllersByIdentifier release];
    [_object release];
    [super dealloc];
}

@end
