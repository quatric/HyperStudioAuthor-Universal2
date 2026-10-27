#import "HyperPlayerBasePrefix.h"
#import "HSTextObjectData.h"


@interface HSHeadlineObjectData : HSTextObjectData <HSGraphicsDelegate, HyperInterface, NSObject>
{
    NSImage *_backgroundThumbnail;
    HSGraphics *_backgroundGraphics;
    NSColor *_outlineColor;
    float _outlineWidth;
    BOOL _outlineEnabled;
}
+ (id)nodeDataKeysToNodeKeysMap;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)undoManagerForGraphics:(id)aGraphics;
- (void)hyperVisualAttributesChanged:(id)aChanged;
- (void)setOutlineEnabled:(BOOL)aEnabled;
- (BOOL)isOutlineEnabled;
- (void)setOutlineWidth:(CGFloat)aWidth;
- (CGFloat)outlineWidth;
- (void)setOutlineColor:(id)aColor;
- (id)outlineColor;
- (void)setBackgroundGraphics:(id)aGraphics;
- (id)backgroundGraphics;
- (void)setBackgroundThumbnail:(id)aThumbnail;
- (id)backgroundThumbnail;
- (void)dealloc;
- (id)init;
@end

