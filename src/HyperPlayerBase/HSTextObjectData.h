#import "HyperPlayerBasePrefix.h"
#import "HSShadowedObjectData.h"


@interface HSTextObjectData : HSShadowedObjectData <HSCoreTextParent>
{
    HSCoreText *_text;
    NSAttributedString *_deserializedText;
    int _verticalAlignment;
    BOOL _textStorageContainsDummyString;
    BOOL _autosizing;
    BOOL _widthSetByUser;
    BOOL _heightSetByUser;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)setTextBlockVerticalAlignment:(NSInteger)aAlignment;
- (NSInteger)textBlockVerticalAlignment;
- (void)text:(id)aText didChangeTextBlockAttribute:(id)aAttribute withUndoActionName:(id)aName;
- (void)text:(id)aText didChangeAttribute:(id)aAttribute affectingSize:(BOOL)aSize withUndoActionName:(id)aName;
- (void)text:(id)aText didChangeTextWithUndoActionName:(id)aName;
- (id)undoManager;
- (void)setVerticalAlignment:(NSInteger)aAlignment;
- (NSInteger)verticalAlignment;
- (void)setHeightSetByUser:(BOOL)aUser;
- (BOOL)heightSetByUser;
- (void)setWidthSetByUser:(BOOL)aUser;
- (BOOL)widthSetByUser;
- (void)setAutosizing:(BOOL)aAutosizing;
- (BOOL)isAutosizing;
- (void)setTextStorageContainsDummyString:(BOOL)aString;
- (BOOL)textStorageContainsDummyString;
- (void)setDeserializedText:(id)aText;
- (id)deserializedText;
- (void)setText:(id)aText;
- (id)text;
- (void)dealloc;
- (id)init;
@end

