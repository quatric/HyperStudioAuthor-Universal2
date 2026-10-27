#import "HyperStudioPrefix.h"


@interface HSCard (KeynoteImporting)
- (BOOL)shouldAssignNextCardAction;
- (void)importKeynoteAngleGradient:(id)aGradient;
- (void)importKeynoteFillColor:(id)aColor fromGraphicStyle:(id)aStyle;
- (void)importKeynoteTexturedFill:(id)aFill;
- (void)applyKeynoteGraphicStyle:(id)aStyle;
- (void)importFromKeynoteObject:(id)aObject;
- (void)addPlayMovieActionToCardForMovieObject:(id)aObject eventType:(id)aType loopMovie:(BOOL)aMovie;
- (void)addDefaultObjectForKeynoteObject:(id)aObject onSlide:(id)aSlide;
@end

