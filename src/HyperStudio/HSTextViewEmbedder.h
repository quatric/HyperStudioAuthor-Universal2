#import "HyperStudioPrefix.h"
#import "HSViewEmbedder.h"


@interface HSTextViewEmbedder : HSViewEmbedder <HSNonOpaqueTextViewDelegate, NSTextViewDelegate, NSTextDelegate, NSObject, HSTextEditorEmbedder, HSRunTimeEditorEmbedder, HyperInterface, HSTextObjectSelectionInterface>
{
    HSNonOpaqueTextView *_textView;
    HSRunTimeEditorUndoManager *_undoManager;
    HSCoreEditorText *_text;
    HSScalingView *_parentView;
    BOOL _supportsGradient;
    NSMutableDictionary *_attributesForSelectedRanges;
}
- (void)textView:(id)aView willInsertText:(id)aText;
- (void)setHyperSelectedRange:(NSRange)aRange;
- (NSRange)hyperSelectedRange;
- (BOOL)textView:(id)aView shouldHandlePerformKeyEquivalentOutsideOfKeyDown:(id)aDown;
- (void)textView:(id)aView hyperColorDidChange:(id)aChange;
- (BOOL)textView:(id)aView shouldHyperChangeColor:(id)aColor;
- (BOOL)textView:(id)aView doCommandBySelector:(SEL)aSelector;
- (id)textView:(id)aView willChangeSelectionFromCharacterRanges:(id)aRanges toCharacterRanges:(id)aRanges2;
- (void)textViewDidChangeSelection:(id)aSelection;
- (void)rememberAttributesForSelectedRangesForTextView:(id)aView;
- (void)clearAttributesForSelectedRanges;
- (id)attributesForSelectedRanges;
- (void)textDidEndEditing:(id)aEditing;
- (void)textDidChange:(id)aChange;
- (id)undoManagerForTextView:(id)aView;
- (void)toggleOutlineInTextView:(id)aView;
- (id)undoManager;
- (void)breakUndoCoalescing;
- (void)removeAllUndoActions;
- (NSRect)borderRect;
- (void)setBorderRect:(NSRect)aRect;
- (BOOL)drawsBorderRect;
- (void)setDrawsBorderRect:(BOOL)aRect;
- (void)applyOriginalTextSize:(NSSize)aSize;
- (void)setScaleFactor:(NSSize)aFactor;
- (NSSize)scaleFactor;
- (id)hyperText;
- (BOOL)makeEmbeddedViewFirstResponder;
- (id)text;
- (id)embeddedView;
- (id)textView;
- (id)createTextView;
- (id)initWithGradientSupport:(BOOL)aSupport;
- (id)init;
- (void)dealloc;
@end

