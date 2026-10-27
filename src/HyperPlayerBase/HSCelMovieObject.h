#import "HyperPlayerBasePrefix.h"
#import "HSConcreteCardObject.h"


@interface HSCelMovieObject : HSConcreteCardObject <HSDefaultSizeSubattributes, HSAttributes, HyperInterface, NSObject, HSGeometryBehaviorSubattributes>
{
}
+ (BOOL)isCelAnimationCanBeCreatedAtPath:(id)aPath frameFormat:(id *)aFormat firstFrame:(int *)aFrame framesCount:(unsigned int *)aCount;
+ (id)framesMediaWithImages:(id)aImages;
+ (Class)nodeDataClass;
+ (id)defaultUnitClassNames;
- (void)importLocalPropertiesFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext;
- (BOOL)canBeStoredAsXMLElement;
- (void)storeLocalPropertiesInXMLElementRepresentation:(id)aRepresentation context:(id)aContext;
- (id)XMLElementName;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (id)applyTransparentColorToImageWithMedia:(id)aMedia;
- (BOOL)canMoveVertically;
- (BOOL)canMoveHorizontally;
- (BOOL)canRotate;
- (BOOL)canSkew;
- (BOOL)canFlipVertically;
- (BOOL)canFlipHorizontally;
- (BOOL)canScaleVertically;
- (BOOL)canScaleHorizontally;
- (BOOL)canBreakSizeScaleAspectRatio;
- (BOOL)prefersResizingToScaling;
- (NSSize)defaultSize;
- (id)queryImageObjectHitTester;
- (id)queryEditorHitTester;
- (id)queryInteractiveHitTester;
- (id)queryDefaultHitTester;
- (id)queryNewHyperInterface:(id)aInterface;
- (id)initWithFramesMedia:(id)aMedia precachedFrames:(id)aFrames frameTimeLength:(long long)aLength frameSize:(NSSize)aSize;
- (id)initWithFramesMedia:(id)aMedia frameTimeLength:(long long)aLength frameSize:(NSSize)aSize;
- (id)initWithFramesMedia:(id)aMedia frameTimeLength:(long long)aLength frameSize:(NSSize)aSize cacheFrames:(BOOL)aFrames;
- (id)init;
@end

