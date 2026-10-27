#import "HyperStudioPrefix.h"


@interface HSVectorGraphicsObject (KeynoteImporting)
+ (BOOL)shouldImportFromKeynoteObject:(id)aObject;
- (id)registredLineEndingInfoObjectFromKeynoteLineEnd:(id)aEnd;
- (void)importKeynoteStroke:(id)aStroke;
- (void)applyKeynoteGeometry:(id)aGeometry;
- (void)importFromKeynoteObject:(id)aObject;
@end

