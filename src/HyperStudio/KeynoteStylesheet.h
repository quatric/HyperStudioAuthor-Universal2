#import "HyperStudioPrefix.h"
#import "KeynoteObject.h"


@interface KeynoteStylesheet : KeynoteObject
{
    NSMutableDictionary *_stylesById;
    NSMutableDictionary *_stylesByIdent;
}
- (id)parentStylesheet;
- (id)themeStyleById:(id)aId;
- (id)masterSlideStyleById:(id)aId;
- (id)styleByIdent:(id)aIdent;
- (id)styleById:(id)aId;
- (void)setStylesByIdent:(id)aIdent;
- (id)stylesByIdent;
- (void)setStylesById:(id)aId;
- (id)stylesById;
- (void)addStyle:(id)aStyle;
- (void)didInitFromParser;
- (void)dealloc;
@end

