#import "HyperStudioPrefix.h"
#import "HSPlaceholderTextView.h"


@interface HSTokenTextView : HSPlaceholderTextView <NSTextStorageDelegate, NSObject>
{
    HSTokenCell *_lastHighlighted;
    int _mouseEnteredCount;
    int _viewTrackingRectTag;
    NSMutableArray *_tokensTrackingRectTags;
}
+ (id)paragraphStyle;
- (id)cellAtPoint:(NSPoint)aPoint;
- (id)allCells;
- (void)textStorageDidProcessEditing:(id)aEditing;
- (void)updateTextStorage;
- (void)setBounds:(NSRect)aBounds;
- (void)setFrame:(NSRect)aFrame;
- (void)viewWillMoveToWindow:(id)aWindow;
- (void)viewDidMoveToWindow;
- (void)setupTrackingRectsForTokens;
- (void)removeTokensTrackingRects;
- (NSRect)frameForTokenCellAtRange:(NSRange)aRange;
- (void)updateTokenRects;
- (BOOL)resignFirstResponder;
- (BOOL)becomeFirstResponder;
- (void)mouseDown:(id)aDown;
- (void)mouseMoved:(id)aMoved;
- (void)mouseExited:(id)aExited;
- (void)mouseEntered:(id)aEntered;
- (id)preferredPasteboardTypeFromArray:(id)aArray restrictedToTypesFromArray:(id)aArray2;
- (BOOL)readSelectionFromPasteboard:(id)aPasteboard type:(id)aType;
- (BOOL)writeSelectionToPasteboard:(id)aPasteboard type:(id)aType;
- (id)writablePasteboardTypes;
- (id)acceptableDragTypes;
- (id)readablePasteboardTypes;
- (void)setTextContainer:(id)aContainer;
- (id)RTFDFromRange:(NSRange)aRange;
- (id)RTFFromRange:(NSRange)aRange;
- (id)attributedStringRepresentationForRange:(NSRange)aRange;
- (id)stringRepresentationForRange:(NSRange)aRange;
- (void)dealloc;
@end

