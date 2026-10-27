#import "HyperStudioPrefix.h"


@interface HSSelectionCanvasLayer : HSNamedSublayersCanvasLayer
{
    id _selection;
}
+ (id)supportedIdentifiers;
- (void)objectsInSelectionDidChange:(id)aChange;
- (void)objectsInSelectionDidChange;
- (void)selectionDidChange;
- (void)updateWithSelection:(id)aSelection;
- (id)selection;
- (void)contextDidChange;
- (id)enabledSelectedObjectsLayer;
- (id)sublayerFactory;
- (void)dealloc;
- (id)init;
- (id)initWithSupportedIdentifiers:(id)aIdentifiers enabledIdentifiers:(id)aIdentifiers2 sublayerFactory:(id)aFactory;
@end

