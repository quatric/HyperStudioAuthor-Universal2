#import "HyperPlayerBasePrefix.h"


@interface HSiPadExportContext : NSObject
{
    NSMutableDictionary *_uidToObjectsMap;
    NSMutableDictionary *_pathDataToMediaMap;
    struct __CFDictionary *_objectToMediaMap;
    NSMutableDictionary *_convertedMediaMap;
    NSMutableDictionary *_prototypeUIDMap;
    BOOL _shouldTerminateExport;
    HSDocument *_document;
    NSMutableArray *_mediaArray;
}
- (void)setPrototypeObjectUID:(id)aUID forGroupUID:(id)aUID2;
- (id)prototypeObjectUIDForGroupUID:(id)aUID;
- (void)setConvertedMedia:(id)aMedia forKey:(id)aKey;
- (id)convertedMediaForKey:(id)aKey;
- (void)setMedia:(id)aMedia forObject:(id)aObject andUID:(id)aUID;
- (id)iPadMediaForImageObject:(id)aObject;
- (id)imageObjectsForMediaUID:(id)aUID;
- (void)setPathMedia:(id)aMedia forData:(id)aData;
- (id)mediaForPathData:(id)aData;
- (void)setShouldTerminateExport:(BOOL)aExport;
- (id)mediaArray;
- (void)addMedia:(id)aMedia;
- (BOOL)shouldTerminateExport;
- (void)dealloc;
- (id)document;
- (id)initWithDocument:(id)aDocument;
@end

