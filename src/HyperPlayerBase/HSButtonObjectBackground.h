#import "HyperPlayerBasePrefix.h"


@interface HSButtonObjectBackground : NSObject <EXKeyValueCoding, HSButtonObjectBackgroundAttributes, HSAttributes, HyperInterface, NSObject, HSButtonObjectBackgroundStyleIdentifierAttribute, HSVisualAttribute, HSUndoableAttribute, HSAttribute>
{
    id _owner;
}
- (id)attributeObservingController;
- (id)buttonType;
- (BOOL)isVisible;
- (void)setSize:(NSSize)aSize;
- (NSSize)size;
- (BOOL)isInDocument;
- (id)undoManager;
- (void)notifyChange:(NSInteger)aChange ofAttributeSet:(id)aSet withUserInfo:(id)aInfo;
- (void)notifyChange:(NSInteger)aChange ofAttribute:(id)aAttribute withUserInfo:(id)aInfo;
- (id)backgroundStyle;
- (id)buttonObject;
- (void)setOwner:(id)aOwner;
- (id)owner;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)initWithOwner:(id)aOwner;
@end

