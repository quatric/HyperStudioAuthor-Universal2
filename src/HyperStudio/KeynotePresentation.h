#import "HyperStudioPrefix.h"
#import "KeynoteObject.h"


@interface KeynotePresentation : KeynoteObject <KeynoteCache, NSObject>
{
    KeynotePackageContent *_content;
    NSMutableDictionary *_stylesByIdent;
    NSMutableDictionary *_styles;
    NSMutableDictionary *_stylesheets;
    NSMutableDictionary *_masterSlides;
    NSMutableDictionary *_cache;
}
- (id)objectOfType:(id)aType inCacheForId:(id)aId;
- (void)addObject:(id)aObject type:(id)aType inCacheForId:(id)aId;
- (NSInteger)soundtrackLoopMode;
- (id)soundtrack;
- (void)setStylesheets:(id)aStylesheets;
- (id)stylesheets;
- (id)masterSlides;
- (void)setStyles:(id)aStyles;
- (id)styles;
- (void)setStylesByIdent:(id)aIdent;
- (id)stylesByIdent;
- (NSSize)size;
- (id)slides;
- (void)setContent:(id)aContent;
- (id)content;
- (void)dealloc;
@end

