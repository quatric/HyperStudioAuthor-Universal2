#import "HyperStudioPrefix.h"


@interface HSMovieObject (KeynoteImporting)
- (id)mediaFromKeynoteMovieData:(id)aData name:(id)aName type:(id)aType;
- (void)importPlayRangeFromKeynoteObject:(id)aObject;
- (void)chooseAnotherMediaForKeynoteObject:(id)aObject;
- (void)continueImportFromKeynoteObject:(id)aObject;
- (void)importFromKeynoteObject:(id)aObject;
@end

