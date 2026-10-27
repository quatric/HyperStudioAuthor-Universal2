#import "HyperPlayerBasePrefix.h"


@interface HSTextPortionSerialization : NSObject <EXKeyValueCoding>
{
    NSAttributedString *_attributedString;
    NSDictionary *_attributesDictionary;
}
+ (BOOL)writeAttributesDictionary:(id)aDictionary toPasteboard:(id)aPasteboard type:(id)aType;
+ (BOOL)writeAttributedString:(id)aString toPasteboard:(id)aPasteboard type:(id)aType;
+ (id)attributesDictionaryWithPasteboard:(id)aPasteboard type:(id)aType;
+ (id)attributedStringWithPasteboard:(id)aPasteboard type:(id)aType;
+ (id)textPortionWithPasteboard:(id)aPasteboard type:(id)aType;
- (BOOL)writeToPasteboard:(id)aPasteboard type:(id)aType;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)attributesDictionary;
- (void)setAttributesDictionary:(id)aDictionary;
- (id)attributedString;
- (void)setAttributedString:(id)aString;
- (void)dealloc;
@end

@interface HSNonOpaqueTextView : NSTextView
{
    BOOL _inited;
    BOOL _neverDrawsBackground;
    NSSize _scaleFactor;
    BOOL _scrollsHorizontally;
    NSImage *_clippedImage;
    BOOL _drawsBorderRect;
    NSRect _borderRect;
    NSColor *_borderRectColor;
    float _borderRectThickness;
    float _horizontalScrollPosition;
    BOOL _isWithinDefaultKeyDownImplementation;
    BOOL _isRotatableText;
}
+ (id)nativelySerializedAttributedStringWithPasteboard:(id)aPasteboard;
+ (id)applyHyperFontAttributes:(id)aAttributes toDictionary:(id)aDictionary;
+ (id)hyperNonFontAttributes;
- (void)insertText:(id)aText;
- (void)setConstrainedFrameSize:(NSSize)aSize;
- (void)modifyFont:(id)aFont;
- (void)pasteFont:(id)aFont;
- (BOOL)readSelectionFromPasteboard:(id)aPasteboard type:(id)aType;
- (BOOL)performInsertionOfString:(id)aString;
- (BOOL)showAlert;
- (id)preferredPasteboardTypeFromArray:(id)aArray restrictedToTypesFromArray:(id)aArray2;
- (BOOL)writeSelectionToPasteboard:(id)aPasteboard type:(id)aType;
- (BOOL)writeSelectionToPasteboard:(id)aPasteboard types:(id)aTypes;
- (id)acceptableDragTypes;
- (id)readablePasteboardTypes;
- (id)writablePasteboardTypes;
- (void)outline:(id)aOutline;
- (void)performFindPanelAction:(id)aAction;
- (void)ignoreSpelling:(id)aSpelling;
- (void)changeSpelling:(id)aSpelling;
- (void)createImageFromVisibleText;
- (void)setRotatableText:(BOOL)aText;
- (BOOL)isRotatableText;
- (void)setScrollsHorizontally:(BOOL)aHorizontally;
- (BOOL)scrollsHorizontally;
- (BOOL)validateUserInterfaceItem:(id)aItem;
- (id)hyperEnclosingScrollView;
- (void)setHorizontalScrollPosition:(CGFloat)aPosition;
- (CGFloat)hyperHorizontalScrollPosition;
- (void)hyperSafeSetScrollPosition:(CGFloat)aPosition;
- (CGFloat)hyperScrollPosition;
- (void)hyperSafeSetSelectedRange:(NSRange)aRange;
- (void)changeAttributes:(id)aAttributes;
- (void)changeColor:(id)aColor;
- (void)changeFont:(id)aFont;
- (void)changeDocumentBackgroundColor:(id)aColor;
- (CGFloat)borderRectThickness;
- (void)setBorderRectThickness:(CGFloat)aThickness;
- (id)borderRectColor;
- (void)setBorderRectColor:(id)aColor;
- (NSRect)borderRect;
- (void)setBorderRect:(NSRect)aRect;
- (BOOL)drawsBorderRect;
- (void)setDrawsBorderRect:(BOOL)aRect;
- (NSSize)scaleFactor;
- (void)setScaleFactor:(NSSize)aFactor;
- (void)continuousSpellCheckingDidChange:(id)aChange;
- (void)toggleContinuousSpellChecking:(id)aChecking;
- (void)setNeverDrawsBackground:(BOOL)aBackground;
- (BOOL)neverDrawsBackground;
- (BOOL)isOpaque;
- (BOOL)performKeyEquivalent:(id)aEquivalent;
- (void)keyDown:(id)aDown;
- (void)mouseDown:(id)aDown;
- (void)setPostsBoundsChangedNotifications:(BOOL)aNotifications;
- (void)drawRect:(NSRect)aRect;
- (NSRect)containerRect;
- (void)dealloc;
- (void)onceInit;
- (BOOL)becomeFirstResponder;
- (id)initWithCoder:(id)aCoder;
- (void)encodeWithCoder:(id)aCoder;
- (id)initWithFrame:(NSRect)aFrame textContainer:(id)aContainer;
+ (id)defaultMenu;
@end

