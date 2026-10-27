#import "HyperStudioPrefix.h"


@interface HSSystemTextView (KeynoteImporting)
+ (BOOL)shouldImportFromKeynoteObject:(id)aObject;
- (void)applyKeynoteGeometry:(id)aGeometry;
- (NSSize)adaptResizingOfKeynoteTextStorage:(id)aStorage toSize:(NSSize)aSize withGeometryBehaviorApplier:(id)aApplier;
- (void)setTextColorForKeynoteObject:(id)aObject;
- (void)importKeynoteOpacity:(CGFloat)aOpacity;
- (void)importFromKeynoteObject:(id)aObject;
@end

