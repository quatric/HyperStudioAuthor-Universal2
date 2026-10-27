#import "HyperStudioPrefix.h"
#import "HSFrameManipulationSelectionKnob.h"


@interface HSFrameSelectionKnobSettings : NSObject
{
    NSSize _framePositionFactor;
    int _modifyingEdges;
    NSString *_defaultCursorIdentifier;
}
+ (id)settingsWithModifyingEdges:(NSInteger)aEdges defaultCursorIdentifier:(id)aIdentifier;
+ (void)registerSettings:(id)aSettings forKnobIdentifier:(id)aIdentifier;
+ (id)settingsForKnobIdentifier:(id)aIdentifier;
+ (id)settingsByID;
- (id)defaultCursor;
- (NSSize)framePositionFactor;
- (NSInteger)modifyingEdges;
- (void)dealloc;
- (id)initWithModifyingEdges:(NSInteger)aEdges defaultCursorIdentifier:(id)aIdentifier;
@end

@interface HSFrameSelectionKnob : HSFrameManipulationSelectionKnob
{
    id _knobSettings;
    BOOL _invertsProportionalResizePreference;
}
+ (id)topLeftSelectionKnob;
+ (id)topCenterSelectionKnob;
+ (id)centerLeftSelectionKnob;
+ (id)bottomLeftSelectionKnob;
+ (id)topRightSelectionKnob;
+ (id)bottomCenterSelectionKnob;
+ (id)centerRightSelectionKnob;
+ (id)bottomRightSelectionKnob;
- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inView:(id)aView owner:(id)aOwner;
- (id)createSelectionTrackerForModifierFlags:(NSUInteger)aFlags;
- (id)selectionTrackerForModifierFlags:(NSUInteger)aFlags;
- (NSSize)framePositionFactor;
- (Class)trackerClass;
- (void)setInvertsProportionalResizePreference:(BOOL)aPreference;
- (BOOL)invertsProportionalResizePreference;
- (id)knobSettings;
- (void)dealloc;
- (id)initWithKnobSettings:(id)aSettings;
@end

