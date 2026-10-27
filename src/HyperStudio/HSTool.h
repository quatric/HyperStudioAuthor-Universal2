#import "HyperStudioPrefix.h"


@interface HSTool : NSObject <EXKeyValueCoding>
{
    HSToolView *_view;
    NSString *_toolIdentifier;
    BOOL _isAddingObjectToCard;
}
- (void)noteCurrentToolSetDidChange;
- (BOOL)preservesActiveInPlaceEditors;
- (BOOL)allowsActiveInPlaceEditors;
- (BOOL)allowsEditingToolView;
- (BOOL)allowsSelection;
- (BOOL)acceptsFirstMouse;
- (void)setupWithView:(id)aView beingRestored:(BOOL)aRestored;
- (void)setView:(id)aView;
- (id)view;
- (BOOL)isAddingObjectToCard;
- (void)addObjectToCard:(id)aCard;
- (BOOL)shouldResetToolOnAddObjects;
- (BOOL)shouldResetToolOnSelectObjects;
- (void)notifyManagerAtomOperationPerformedWithResult:(BOOL)aResult;
- (void)didActivateExplicitly:(BOOL)aExplicitly;
- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly;
- (void)saveChanges;
- (id)primarySettingsIdentifier;
- (id)settingsIdentifiers;
- (void)setToolIdentifier:(id)aIdentifier;
- (id)toolIdentifier;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)dealloc;
@end

