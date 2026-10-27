#import "HyperStudioPrefix.h"


@interface HSObjectKnobsCanvasLayer : HSCanvasItemsSublayer
{
    id<HSAttributes> _hyperObject;
    id<HSNodeAttributes> _node;
    id<HSKnobsProvider> _knobsProvider;
    NSMutableArray *_knobs;
    NSEProtocolSet *_observedAttributes;
    HSSelectionKnob *_trackingKnob;
    id _delegate;
}
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent;
- (id)allAttributesAffectingKnobs;
- (void)updateObservedAttributesWithSet:(id)aSet;
- (void)updateNotificationsObservingWithOldAttributes:(id)aAttributes newAttributes:(id)aAttributes2;
- (void)didFinishTrackingKnob:(id)aKnob;
- (void)willStartTrackingKnob:(id)aKnob;
- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (id)knobs;
- (void)updateKnobs;
- (void)rebuildKnobs;
- (NSUInteger)indexOfKnob:(id)aKnob;
- (id)knobAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfKnobs;
- (BOOL)supportsHitTesting;
- (id)canvasItemAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfCanvasItems;
- (id)knobsProvider;
- (void)refreshKnobsProvider;
- (void)setKnobsProvider:(id)aProvider;
- (void)knobProviderDidChange:(id)aChange;
- (void)nodeAttributesDidChange:(id)aChange;
- (id)node;
- (void)setNode:(id)aNode;
- (id)hyperObject;
- (void)setHyperObject:(id)aObject;
- (void)setHyperObject:(id)aObject nodeAttributes:(id)aAttributes;
- (void)dealloc;
@end

