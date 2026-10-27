#import "HyperStudioPrefix.h"


@interface HSConcreteCardObject (KeynoteImporting)
+ (id)actionClassNameFromKeynoteHyperlink:(id)aHyperlink;
- (id)actionWithClassName:(id)aName fromKeynoteItem:(id)aItem;
- (id)actionWithClassName:(id)aName fromKeynoteItem:(id)aItem withLink:(id)aLink;
- (void)applyHyperlinkFromKeynoteItem:(id)aItem;
- (void)importLinksFromKeynoteShape:(id)aShape;
- (void)applyKeynoteGeometry:(id)aGeometry;
- (void)importFromKeynoteObject:(id)aObject;
@end

