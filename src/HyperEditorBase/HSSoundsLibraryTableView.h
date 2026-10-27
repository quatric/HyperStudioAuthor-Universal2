#import "HyperEditorBasePrefix.h"


@interface HSSoundsLibraryTableView : NSTableView
{
    NSString *_placeholderString;
}
- (void)drawRect:(NSRect)aRect;
- (void)drawPlaceholderStringInRect:(NSRect)aRect;
- (void)drawGridInClipRect:(NSRect)aRect;
- (void)drawBackgroundInClipRect:(NSRect)aRect;
- (BOOL)shouldDrawPlaceholderString;
- (void)setPlaceholderString:(id)aString;
- (id)placeholderString;
- (BOOL)sendAction:(SEL)aAction to:(id)aTo;
- (void)keyDown:(id)aDown;
- (BOOL)acceptsFirstMouse:(id)aMouse;
- (void)awakeFromNib;
- (void)copy:(id)aCopy;
- (void)paste:(id)aPaste;
- (void)delete:(id)aDelete;
- (void)cut:(id)aCut;
- (BOOL)validateUserInterfaceItem:(id)aItem;
- (void)dealloc;
@end

