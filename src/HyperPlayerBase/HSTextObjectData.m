#import "HSTextObjectData.h"

// Data of a text object: the HSCoreText (created lazily from the
// deserialized attributed string) plus sizing flags.
@implementation HSTextObjectData
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraStoringWithCodingContext:aContext]];
    if (![[aContext codingOperation] isEqualToString:@"HSObjectStyleCodingOperation"]) {
        [keys addObject:@"text"];
        [keys addObject:@"widthSetByUser"];
        [keys addObject:@"heightSetByUser"];
    }
    [keys addObject:@"opacity"];
    [keys addObject:@"textBlockVerticalAlignment"];
    return keys;
}
- (void)setTextBlockVerticalAlignment:(NSInteger)aAlignment
{
    [self setVerticalAlignment:aAlignment];
}
- (NSInteger)textBlockVerticalAlignment
{
    return [self verticalAlignment];
}
- (void)text:(id)aText didChangeTextBlockAttribute:(id)aAttribute withUndoActionName:(id)aName
{
    if ([self hasOwner])
        [[[self owner] anyOwningObjectForNodeData:self] text:aText didChangeTextBlockAttribute:aAttribute withUndoActionName:aName];
}
- (void)text:(id)aText didChangeAttribute:(id)aAttribute affectingSize:(BOOL)aSize withUndoActionName:(id)aName
{
    if ([self hasOwner])
        [[[self owner] anyOwningObjectForNodeData:self] text:aText didChangeAttribute:aAttribute affectingSize:aSize withUndoActionName:aName];
}
- (void)text:(id)aText didChangeTextWithUndoActionName:(id)aName
{
    if ([self hasOwner])
        [[[self owner] anyOwningObjectForNodeData:self] text:aText didChangeTextWithUndoActionName:aName];
}
- (id)undoManager
{
    if (![self hasOwner])
        return nil;
    return [[[self owner] anyOwningObjectForNodeData:self] undoManager];
}
- (void)setVerticalAlignment:(NSInteger)aAlignment
{
    _verticalAlignment = (int)aAlignment;
}
- (NSInteger)verticalAlignment
{
    return _verticalAlignment;
}
- (void)setHeightSetByUser:(BOOL)aUser
{
    _heightSetByUser = aUser;
}
- (BOOL)heightSetByUser
{
    return _heightSetByUser;
}
- (void)setWidthSetByUser:(BOOL)aUser
{
    _widthSetByUser = aUser;
}
- (BOOL)widthSetByUser
{
    return _widthSetByUser;
}
- (void)setAutosizing:(BOOL)aAutosizing
{
    _autosizing = aAutosizing;
}
- (BOOL)isAutosizing
{
    return _autosizing;
}
- (void)setTextStorageContainsDummyString:(BOOL)aString
{
    _textStorageContainsDummyString = aString;
}
- (BOOL)textStorageContainsDummyString
{
    return _textStorageContainsDummyString;
}
- (void)setDeserializedText:(id)aText
{
    [aText retain];
    [_deserializedText release];
    _deserializedText = aText;
}
- (id)deserializedText
{
    return _deserializedText;
}
- (void)setText:(id)aText
{
    [_text setParent:nil];
    [aText retain];
    [_text release];
    _text = aText;
    [aText setParent:self];
}
- (id)text
{
    if (_text == nil) {
        HSCoreText *text = _textStorageContainsDummyString
            ? [[HSCoreText alloc] initWithAttributes:nil]
            : [[HSCoreText alloc] initWithAttributedString:_deserializedText];
        [self setText:[text autorelease]];
    }
    return _text;
}
- (void)dealloc
{
    [_deserializedText release];
    [_text setParent:nil];
    [_text release];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self) {
        _textStorageContainsDummyString = NO;
        _autosizing = NO;
    }
    return self;
}
@end
