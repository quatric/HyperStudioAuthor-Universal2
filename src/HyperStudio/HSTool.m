#import "HSTool.h"

@implementation HSTool

- (void)noteCurrentToolSetDidChange
{
}

- (BOOL)preservesActiveInPlaceEditors
{
    return NO;
}

- (BOOL)allowsActiveInPlaceEditors
{
    return NO;
}

- (BOOL)allowsEditingToolView
{
    return YES;
}

- (BOOL)allowsSelection
{
    return NO;
}

- (BOOL)acceptsFirstMouse
{
    return YES;
}

- (void)setupWithView:(id)aView beingRestored:(BOOL)aRestored
{
    [self setView:aView];
}

- (void)setView:(id)aView
{
    _view = aView;
}

- (id)view
{
    return _view;
}

- (BOOL)isAddingObjectToCard
{
    return _isAddingObjectToCard;
}

- (void)addObjectToCard:(id)aCard
{
    _isAddingObjectToCard = YES;
    [[[self view] hyperObject] addHyperChild:aCard];
    _isAddingObjectToCard = NO;
}

- (BOOL)shouldResetToolOnAddObjects
{
    return ![self isAddingObjectToCard];
}

- (BOOL)shouldResetToolOnSelectObjects
{
    return ![self isAddingObjectToCard];
}

- (void)notifyManagerAtomOperationPerformedWithResult:(BOOL)aResult
{
    [[HSToolManager sharedToolManager] atomOperationPerformedWithResult:aResult];
}

- (void)didActivateExplicitly:(BOOL)aExplicitly
{
}

- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly
{
}

- (void)saveChanges
{
}

- (id)primarySettingsIdentifier
{
    return [self toolIdentifier];
}

- (id)settingsIdentifiers
{
    return [NSArray arrayWithObject:[self primarySettingsIdentifier]];
}

- (void)setToolIdentifier:(id)aIdentifier
{
    _toolIdentifier = aIdentifier;
}

- (id)toolIdentifier
{
    return _toolIdentifier;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray array];
}

- (void)dealloc
{
    [_toolIdentifier release];
    [super dealloc];
}

@end
