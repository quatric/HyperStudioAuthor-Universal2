#import "HyperStudioPrefix.h"


@interface HSUserObject (KeynoteImporting)
+ (BOOL)shouldImportFromKeynoteObject:(id)aObject;
- (void)importKeynoteStroke:(id)aStroke;
- (void)importKeynoteShadow:(id)aShadow;
- (void)importKeynoteTexturedFill:(id)aFill;
- (void)importKeynoteAngleGradient:(id)aGradient;
- (void)importKeynoteFillColor:(id)aColor fromGraphicStyle:(id)aStyle;
- (void)importKeynoteOpacity:(CGFloat)aOpacity;
- (void)applyKeynoteGraphicStyle:(id)aStyle;
- (void)importFromKeynoteObject:(id)aObject;
@end

