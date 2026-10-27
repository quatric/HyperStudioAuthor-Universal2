#import "HyperPlayerBasePrefix.h"
#import "HSShadowedObject.h"


@interface HSYouTubeObject : HSShadowedObject <HSGeometryBehaviorSubattributes, HSAttributes, HyperInterface, NSObject, HSResizingBehaviorSubattributes, HSYouTubeAttributes, HSYouTubeRectAttribute, HSVisualAttribute, HSUndoableAttribute, HSAttribute, HSYouTubeFrameContentAttribute, HSYouTubeObjectAttributes, HSYouTubeMovieIDAttribute, HSYouTubeMovieURLAttribute, HSYouTubeMovieTitleAttribute, HSYouTubeMovieAuthorAttribute, HSYouTubeMovieDurationAttribute, HSYouTubeMovieSizeAttribute, HSYouTubeInteractiveAttribute, HSYouTubeMovieImageAttribute, HSDefaultSizeSubattributes>
{
    id<HSYouTubeRendering> _youTubeRenderer;
}
+ (Class)nodeDataClass;
+ (id)defaultUnitClassNames;
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (BOOL)hasUnsupportedHTML5FeaturesForDocumentType:(id)aType;
- (id)HTML5UnsupportedFunctionalityDescription;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (void)newImageAvailableInRenderer:(id)aRenderer;
- (void)stopObservingFromRenderer:(id)aRenderer;
- (void)startObservingFromRenderer:(id)aRenderer;
- (void)destroyRenderer;
- (void)setYouTubeMovieImage:(id)aImage;
- (id)youTubeMovieImage;
- (void)setYouTubeMovieSizeAsString:(id)aString;
- (id)youTubeMovieSizeAsString;
- (void)setYouTubeMovieSize:(NSSize)aSize;
- (NSSize)youTubeMovieSize;
- (void)setYouTubeMovieDuration:(double)aDuration;
- (double)youTubeMovieDuration;
- (void)setYouTubeMovieAuthorURL:(id)aURL;
- (id)youTubeMovieAuthorURL;
- (void)setYouTubeMovieAuthor:(id)aAuthor;
- (id)youTubeMovieAuthor;
- (void)setYouTubeMovieTitle:(id)aTitle;
- (id)youTubeMovieTitle;
- (void)setYouTubeMovieWatchURL:(id)aURL;
- (id)youTubeMovieWatchURL;
- (void)setYouTubeMovieURL:(id)aURL;
- (id)youTubeMovieURL;
- (void)setYouTubeMovieID:(id)aID;
- (id)youTubeMovieID;
- (id)youTubeRenderer;
- (NSRect)youTubeRect;
- (BOOL)canMoveVertically;
- (BOOL)canMoveHorizontally;
- (BOOL)canRotate;
- (BOOL)canSkew;
- (BOOL)canFlipVertically;
- (BOOL)canFlipHorizontally;
- (BOOL)canScaleVertically;
- (BOOL)canScaleHorizontally;
- (BOOL)prefersResizingToScaling;
- (BOOL)canResizeVertically;
- (BOOL)canResizeHorizontally;
- (BOOL)canBreakSizeAspectRatio;
- (BOOL)canBreakSizeScaleAspectRatio;
- (NSSize)defaultSize;
- (BOOL)canBeDraggable;
- (BOOL)canBeResizable;
- (BOOL)canBeRotatable;
- (void)reattachRenderer;
- (void)detachRenderer;
- (id)youTubeInteractiveView;
- (id)nameBaseTemplates;
- (id)queryInteractivePlayerItem;
- (id)queryNewHyperInterface:(id)aInterface;
- (void)dealloc;
@end

