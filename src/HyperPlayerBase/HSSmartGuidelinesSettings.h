#import "HyperPlayerBasePrefix.h"


@interface HSSmartGuidelinesSettings : NSObject <EXKeyValueCoding>
{
    NSColor *_smartGuidelineColor;
    BOOL _isSnapToObjectsEnabled;
    NSUndoManager *_undoManager;
}
+ (id)defaultColor;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (BOOL)isSnapToObjectsEnabled;
- (void)setSnapToObjectsEnabled:(BOOL)aEnabled;
- (id)smartGuidelineColor;
- (void)setSmartGuidelineColor:(id)aColor;
- (id)undoManager;
- (void)setUndoManager:(id)aManager;
- (void)resetToDefaults;
- (void)saveToUserDefaults;
- (void)dealloc;
- (id)init;
@end

