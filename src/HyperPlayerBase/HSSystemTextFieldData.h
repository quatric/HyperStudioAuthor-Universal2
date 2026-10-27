#import "HyperPlayerBasePrefix.h"
#import "HSSystemObjectData.h"


@interface HSSystemTextFieldData : HSSystemObjectData
{
    unsigned int _borderType;
    NSDictionary *_textFieldBorderTypes;
    NSDictionary *_textFieldSizes;
}
+ (id)nodeDataKeysToNodeKeysMap;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)setEditable:(BOOL)aEditable;
- (BOOL)isEditable;
- (void)setSelectable:(BOOL)aSelectable;
- (BOOL)isSelectable;
- (void)setControlSize:(NSUInteger)aSize;
- (NSUInteger)controlSize;
- (void)setTextAlignment:(NSUInteger)aAlignment;
- (NSUInteger)textAlignment;
- (void)setBezelStyle:(NSUInteger)aStyle;
- (NSUInteger)bezelStyle;
- (void)setBackgroundColor:(id)aColor;
- (id)backgroundColor;
- (void)setTextColor:(id)aColor;
- (id)textColor;
- (void)setFont:(id)aFont;
- (id)font;
- (void)setStringValue:(id)aValue;
- (id)stringValue;
- (void)setPlaceholderString:(id)aString;
- (id)placeholderString;
- (void)setTextFieldSizes:(id)aSizes;
- (id)textFieldSizes;
- (void)setTextFieldBorderTypes:(id)aTypes;
- (id)textFieldBorderTypes;
- (void)setBorderType:(NSUInteger)aType;
- (NSUInteger)borderType;
- (id)systemTextFieldForSetAccessor;
- (id)systemTextFieldForGetAccessor;
- (void)dealloc;
- (id)init;
- (id)templateCocoaView;
@end

